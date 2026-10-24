#!/usr/bin/env python3
"""Continuous Waybar JSON for default-route network and selected block devices."""

import argparse
from html import escape
import json
import os
from pathlib import Path
import re
import subprocess
import time


DEVICE_NAME = re.compile(r"[A-Za-z0-9][A-Za-z0-9_-]*\Z")


def command(*args):
    try:
        return subprocess.run(
            args, check=True, capture_output=True, text=True, timeout=1
        ).stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def json_command(*args):
    try:
        return json.loads(command(*args))
    except ValueError:
        return None


def format_rate(value):
    for unit in ("B/s", "kB/s", "MB/s", "GB/s"):
        # Promote rounded boundaries too: never let 1000 spill into a cell.
        number = f"{value:.0f}" if unit == "B/s" else f"{value:.1f}"
        if float(number) < 1000:
            return f"{number} {unit}"
        if unit == "GB/s":
            return "999.9 GB/s"  # Cap implausible rates instead of widening the bar.
        value /= 1000


def rate_markup(rate, label, color):
    number, unit = rate.split()
    color = color if float(number) else "#9399b2"
    # Compact bar precision; the tooltip retains format_rate's extra decimal.
    value = float(number)
    number = f"{value:.0f}" if unit == "B/s" or value >= 10 else f"{value:.1f}"
    if float(number) >= 1000:
        if unit == "GB/s":
            number = "999"
        else:
            units = ("B/s", "kB/s", "MB/s", "GB/s")
            unit = units[units.index(unit) + 1]
            number = "1.0"
    # NBSP preserves both leading numeric and trailing unit padding in GTK.
    number = f"{number:>3}".replace(" ", "\u00a0")
    unit = f"{unit:<4}".replace(" ", "\u00a0")
    return (
        f'<span foreground="{color}">{escape(label)}{number}</span>'
        f'<span foreground="#9399b2" font_desc="11px">{unit}</span>'
    )


def default_interface():
    # Select one route/interface, never sum physical and tunnel traffic together.
    for family in ("-4", "-6"):
        routes = json_command("ip", "-j", family, "route", "show", "default")
        if not isinstance(routes, list):
            continue
        routes = [
            route for route in routes
            if route.get("dev") and route.get("type", "unicast") == "unicast"
            and not {"dead", "linkdown"}.intersection(route.get("flags", []))
        ]
        if routes:
            name = min(routes, key=lambda route: route.get("metric", 0))["dev"]
            if name not in (".", "..") and "/" not in name and "\0" not in name:
                return name
    return None


def network_counters(name):
    device = Path("/sys/class/net") / name
    try:
        if (device / "operstate").read_text().strip() in (
            "down", "notpresent", "lowerlayerdown",
        ):
            return None
        try:
            if (device / "carrier").read_text().strip() == "0":
                return None
        except OSError:
            pass  # Some virtual interfaces do not expose carrier state.
        counters = tuple(
            int((device / "statistics" / field).read_text())
            for field in ("rx_bytes", "tx_bytes")
        )
        return counters if min(counters) >= 0 else None
    except (OSError, ValueError):
        return None


def selected_disks():
    if "WAYBAR_DISKS" in os.environ:
        return list(dict.fromkeys(
            name for name in os.environ["WAYBAR_DISKS"].split()
            if DEVICE_NAME.fullmatch(name)
        ))

    # Follow the actual root source upwards (including dm/RAID parents), not /boot.
    source = command("findmnt", "-n", "-o", "SOURCE", "--target", "/").strip()
    source = source.split("[", 1)[0]  # findmnt may append a btrfs subvolume.
    if not source.startswith("/dev/"):
        return []
    tree = json_command("lsblk", "--inverse", "--json", "--output", "KNAME,TYPE", "--", source)
    if not isinstance(tree, dict):
        return []
    disks = []

    def visit(nodes):
        for node in nodes:
            name = node.get("kname", "")
            if node.get("type") == "disk" and DEVICE_NAME.fullmatch(name):
                if name not in disks:
                    disks.append(name)
            visit(node.get("children", []))

    visit(tree.get("blockdevices", []))
    return disks


def disk_counters(name):
    try:
        fields = (Path("/sys/class/block") / name / "stat").read_text().split()
        # Linux block statistics always count 512-byte sectors, not logical blocks.
        counters = (int(fields[2]) * 512, int(fields[6]) * 512)
        return counters if min(counters) >= 0 else None
    except (OSError, ValueError, IndexError):
        return None


class Sampler:
    def __init__(self, mode):
        self.mode = mode
        self.previous = {}

    def sample(self):
        if self.mode == "network":
            interface = default_interface()
            names = [interface] if interface else []
            read_counters = network_counters
        else:
            names = selected_disks()
            read_counters = disk_counters

        current = {}
        rates = {}
        for name in names:
            counters = read_counters(name)
            if counters is None:
                continue
            now = time.monotonic()
            previous = self.previous.get(name)
            rate = (0, 0)
            if previous is not None:
                then, old = previous
                elapsed = now - then
                if elapsed > 0 and all(new >= before for new, before in zip(counters, old)):
                    rate = tuple((new - before) / elapsed for new, before in zip(counters, old))
            current[name] = (now, counters)
            rates[name] = tuple(format_rate(value) for value in rate)
        # Forget absent devices immediately; a reappearance starts a fresh baseline.
        self.previous = current

        if not rates:
            return {"text": "", "tooltip": "Throughput unavailable", "class": "unavailable"}
        if self.mode == "network":
            rx, tx = rates[interface]
            text = (
                '<span foreground="#9399b2" font_desc="11px">net</span>\u2009'
                f'{rate_markup(rx, "↓", "#89b4fa")}\u2009{rate_markup(tx, "↑", "#cba6f7")}'
            )
            tooltip = f"Default-route interface: {escape(interface)}\nReceive: {rx}\nTransmit: {tx}"
        else:
            text = '\u2009<span foreground="#6c7086" font_desc="11px">│</span>\u2009'.join(
                f'<span foreground="#9399b2" font_desc="11px">{escape(name)}</span>\u2009'
                f'{rate_markup(read, "R", "#89b4fa")}\u2009{rate_markup(write, "W", "#cba6f7")}'
                for name, (read, write) in rates.items()
            )
            tooltip = "Block device I/O\n" + "\n".join(
                f"/dev/{escape(name)}: read {read}, write {write}" for name, (read, write) in rates.items()
            )
        text = f'<span font_family="JetBrainsMono Nerd Font">{text}</span>'
        return {"text": text, "tooltip": tooltip, "class": "normal"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("network", "disks"))
    sampler = Sampler(parser.parse_args().mode)
    try:
        while True:
            started = time.monotonic()
            print(json.dumps(sampler.sample(), ensure_ascii=False), flush=True)
            time.sleep(max(0, 2 - (time.monotonic() - started)))
    except (KeyboardInterrupt, BrokenPipeError):
        pass


if __name__ == "__main__":
    main()
