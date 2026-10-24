#!/usr/bin/env python3
"""Deterministic backend tests; no live interfaces, devices, or state are touched."""

import importlib.util
import json
from pathlib import Path
import re
import subprocess
import unittest
from unittest.mock import call, patch
from xml.etree import ElementTree


spec = importlib.util.spec_from_file_location("throughput", Path(__file__).with_name("throughput.py"))
throughput = importlib.util.module_from_spec(spec)
spec.loader.exec_module(throughput)


def visible_text(markup):
    return "".join(ElementTree.fromstring(f"<root>{markup}</root>").itertext())


def compact_text(markup):
    return " ".join(visible_text(markup).split())


PRESENTATION_VALUES = [0, 1, 9, 9.9, 10, 99.9, 100, 999, 999.4, 999.5] + [
    number * scale
    for scale in (1000, 1_000_000, 1_000_000_000)
    for number in (0, 1, 9.9, 9.94, 9.95, 9.96, 10, 99.4, 99.9, 100,
                   999.4, 999.5, 999.9, 999.94, 999.95, 1000)
] + [10**18]


def presentation_sample(mode, value, name="eth0"):
    with patch.object(throughput, "default_interface", return_value=name), patch.object(
        throughput, "selected_disks", return_value=[name, "sda"]
    ), patch.object(throughput, "network_counters", return_value=(0, 0)) as network, patch.object(
        throughput, "disk_counters", return_value=(0, 0)
    ) as disk, patch.object(throughput.time, "monotonic", return_value=0) as clock:
        sampler = throughput.Sampler(mode)
        sampler.sample()
        network.return_value = disk.return_value = (value, value)
        clock.return_value = 1
        return sampler.sample()


class DiscoveryTests(unittest.TestCase):
    def test_decimal_units(self):
        for value, expected in (
            (0, "0 B/s"), (512, "512 B/s"), (999, "999 B/s"),
            (1000, "1.0 kB/s"), (1250, "1.2 kB/s"),
            (1_200_000, "1.2 MB/s"), (1_200_000_000, "1.2 GB/s"),
        ):
            with self.subTest(value=value):
                self.assertEqual(throughput.format_rate(value), expected)

    def test_rounded_unit_boundaries_and_display_cap(self):
        for value, expected in (
            (999.4, "999 B/s"), (999.5, "1.0 kB/s"),
            (999_940, "999.9 kB/s"), (999_960, "1.0 MB/s"),
            (999_940_000, "999.9 MB/s"), (999_960_000, "1.0 GB/s"),
            (999_940_000_000, "999.9 GB/s"), (999_960_000_000, "999.9 GB/s"),
            (10**18, "999.9 GB/s"),
        ):
            with self.subTest(value=value):
                self.assertEqual(throughput.format_rate(value), expected)

    def test_default_route_lowest_metric_not_all_interfaces(self):
        routes = [
            {"dev": "eth0", "metric": 100}, {"dev": "tun0", "metric": 5},
            {"dev": "down0", "metric": 0, "flags": ["linkdown"]},
            {"type": "blackhole", "metric": 0},
        ]
        with patch.object(throughput, "json_command", return_value=routes) as command:
            self.assertEqual(throughput.default_interface(), "tun0")
            command.assert_called_once_with("ip", "-j", "-4", "route", "show", "default")

    def test_ipv6_fallback_and_no_route(self):
        for ipv4 in ([], None):
            with self.subTest(ipv4=ipv4), patch.object(
                throughput, "json_command", side_effect=[ipv4, [{"dev": "wlan0"}]]
            ) as command:
                self.assertEqual(throughput.default_interface(), "wlan0")
                self.assertEqual(command.call_args, call("ip", "-j", "-6", "route", "show", "default"))
        with patch.object(throughput, "json_command", return_value=[]):
            self.assertIsNone(throughput.default_interface())

    def test_root_partition_selects_whole_root_disk_not_external_or_boot(self):
        tree = {"blockdevices": [{"kname": "nvme0n1p2", "type": "part", "children": [
            {"kname": "nvme0n1", "type": "disk"},
        ]}]}
        with patch.dict(throughput.os.environ, {}, clear=True), patch.object(
            throughput, "command", return_value="/dev/nvme0n1p2[/@]\n"
        ) as findmnt, patch.object(throughput, "json_command", return_value=tree) as lsblk:
            self.assertEqual(throughput.selected_disks(), ["nvme0n1"])
            findmnt.assert_called_once_with("findmnt", "-n", "-o", "SOURCE", "--target", "/")
            lsblk.assert_called_once_with(
                "lsblk", "--inverse", "--json", "--output", "KNAME,TYPE", "--", "/dev/nvme0n1p2"
            )

    def test_root_multiple_physical_parents_deduplicated(self):
        disk = {"kname": "sda", "type": "disk"}
        tree = {"blockdevices": [{"kname": "dm-0", "type": "crypt", "children": [
            {"kname": "md0", "type": "raid1", "children": [
                {"kname": "sda2", "type": "part", "children": [disk]},
                {"kname": "sdb2", "type": "part", "children": [{"kname": "sdb", "type": "disk"}]},
                disk,
            ]},
        ]}]}
        with patch.dict(throughput.os.environ, {}, clear=True), patch.object(
            throughput, "command", return_value="/dev/mapper/root\n"
        ), patch.object(throughput, "json_command", return_value=tree):
            self.assertEqual(throughput.selected_disks(), ["sda", "sdb"])

    def test_override_exact_names_partitions_deduplication_and_invalid_names(self):
        for override, expected in (
            ("sda nvme0n1", ["sda", "nvme0n1"]),
            ("sda1 nvme0n1p2 dm-0 md0 sda1", ["sda1", "nvme0n1p2", "dm-0", "md0"]),
            ("/dev/sda ../sda . .. -sda sda;id sda$(id) sda/../sdb", []),
            ("/dev/sda sdb2", ["sdb2"]), ("", []),
        ):
            with self.subTest(override=override), patch.dict(
                throughput.os.environ, {"WAYBAR_DISKS": override}, clear=True
            ), patch.object(throughput, "command") as command:
                self.assertEqual(throughput.selected_disks(), expected)
                command.assert_not_called()

    def test_missing_root_and_commands(self):
        with patch.dict(throughput.os.environ, {}, clear=True), patch.object(
            throughput, "command", return_value="overlay\n"
        ):
            self.assertEqual(throughput.selected_disks(), [])
        for error in (FileNotFoundError(), subprocess.TimeoutExpired("ip", 1),
                      subprocess.CalledProcessError(1, "ip")):
            with self.subTest(error=error), patch.object(throughput.subprocess, "run", side_effect=error):
                self.assertIsNone(throughput.json_command("ip"))


class CounterTests(unittest.TestCase):
    def test_network_rx_tx_bytes(self):
        with patch.object(Path, "read_text", side_effect=["up\n", "1\n", "12345\n", "6789\n"]):
            self.assertEqual(throughput.network_counters("eth0"), (12345, 6789))

    def test_network_disconnected_missing_and_malformed(self):
        for reads in (["down\n"], ["up\n", "0\n"], [FileNotFoundError()],
                      ["up", "1", "bad"], ["up", "1", "-1", "0"]):
            with self.subTest(reads=reads), patch.object(Path, "read_text", side_effect=reads):
                self.assertIsNone(throughput.network_counters("eth0"))

    def test_virtual_network_without_carrier(self):
        with patch.object(Path, "read_text", side_effect=["unknown", OSError(), "5", "7"]):
            self.assertEqual(throughput.network_counters("tun0"), (5, 7))

    def test_disk_read_write_use_512_byte_sectors(self):
        # Read/write request counts and timings must not be mistaken for sectors.
        with patch.object(Path, "read_text", return_value="7 8 100 9 10 11 200 12 0 0 0"):
            self.assertEqual(throughput.disk_counters("nvme0n1"), (51_200, 102_400))

    def test_disk_missing_short_or_malformed_stats(self):
        for content in ("", "1 2 3", "0 0 nope 0 0 0 7", "0 0 -1 0 0 0 7", FileNotFoundError()):
            with self.subTest(content=content), patch.object(
                Path, "read_text", side_effect=[content]
            ):
                self.assertIsNone(throughput.disk_counters("sda"))


class SamplingTests(unittest.TestCase):
    def setUp(self):
        self.route = self.enterContext(patch.object(throughput, "default_interface", return_value="eth0"))
        self.network = self.enterContext(patch.object(throughput, "network_counters"))
        self.disks = self.enterContext(patch.object(throughput, "selected_disks", return_value=["nvme0n1"]))
        self.disk = self.enterContext(patch.object(throughput, "disk_counters"))
        self.clock = self.enterContext(patch.object(throughput.time, "monotonic", return_value=0))

    def test_network_first_idle_and_real_elapsed_rx_tx(self):
        sampler = throughput.Sampler("network")
        self.network.return_value = (10**12, 10**12)
        self.assertEqual(compact_text(sampler.sample()["text"]), "net ↓ 0B/s ↑ 0B/s")
        self.clock.return_value = 2.5
        self.network.return_value = (10**12 + 3_000_000, 10**12 + 2500)
        result = sampler.sample()
        self.assertEqual(compact_text(result["text"]), "net ↓1.2MB/s ↑1.0kB/s")
        self.assertEqual(result["class"], "normal")
        self.assertIn("eth0", result["tooltip"])
        self.clock.return_value = 4.5
        self.assertEqual(compact_text(sampler.sample()["text"]), "net ↓ 0B/s ↑ 0B/s")

    def test_reset_wrap_and_nonpositive_elapsed_rebaseline(self):
        for next_time, counters in ((2, (0, 2000)), (2, (2000, 0)), (0, (2000, 2000))):
            with self.subTest(next_time=next_time, counters=counters):
                sampler = throughput.Sampler("network")
                self.clock.return_value = 0
                self.network.return_value = (1000, 1000)
                sampler.sample()
                self.clock.return_value = next_time
                self.network.return_value = counters
                self.assertEqual(compact_text(sampler.sample()["text"]), "net ↓ 0B/s ↑ 0B/s")
                self.clock.return_value = next_time + 1
                self.network.return_value = tuple(value + 500 for value in counters)
                self.assertEqual(compact_text(sampler.sample()["text"]), "net ↓500B/s ↑500B/s")

    def test_default_route_switch_never_reuses_old_interface_baseline(self):
        sampler = throughput.Sampler("network")
        self.network.return_value = (1000, 2000)
        sampler.sample()
        for interface in ("tun0", "eth0"):
            self.clock.return_value += 2
            self.route.return_value = interface
            self.network.return_value = (10**12, 10**12)
            result = sampler.sample()
            self.assertEqual(compact_text(result["text"]), "net ↓ 0B/s ↑ 0B/s")
            self.assertIn(interface, result["tooltip"])

    def test_network_missing_and_reappearing(self):
        for missing_route in (False, True):
            with self.subTest(missing_route=missing_route):
                sampler = throughput.Sampler("network")
                self.route.return_value = "eth0"
                self.network.return_value = (1000, 2000)
                sampler.sample()
                if missing_route:
                    self.route.return_value = None
                else:
                    self.network.return_value = None
                self.assertEqual(sampler.sample()["text"], "")
                self.assertEqual(sampler.previous, {})
                self.route.return_value = "eth0"
                self.network.return_value = (10**12, 10**12)
                self.clock.return_value += 2
                self.assertEqual(compact_text(sampler.sample()["text"]), "net ↓ 0B/s ↑ 0B/s")

    def test_multiple_disks_independent_elapsed_labels_and_rates(self):
        self.disks.return_value = ["nvme0n1", "sda"]
        self.disk.side_effect = [(51200, 102400), (1024, 2048), (2051200, 102400), (3524, 7048)]
        self.clock.side_effect = [0, 0.5, 2, 3]
        sampler = throughput.Sampler("disks")
        self.assertEqual(compact_text(sampler.sample()["text"]), "nvme0n1 R 0B/s W 0B/s │ sda R 0B/s W 0B/s")
        result = sampler.sample()
        self.assertEqual(compact_text(result["text"]), "nvme0n1 R1.0MB/s W 0B/s │ sda R1.0kB/s W2.0kB/s")
        self.assertIn("/dev/nvme0n1", result["tooltip"])
        self.assertIn("/dev/sda", result["tooltip"])

    def test_missing_disk_does_not_reset_other_disk_and_reappears_at_zero(self):
        self.disks.return_value = ["nvme0n1", "sda"]
        sampler = throughput.Sampler("disks")
        self.disk.side_effect = [(0, 0), (0, 0)]
        sampler.sample()
        self.clock.return_value = 2
        self.disk.side_effect = [(2000, 4000), None]
        self.assertEqual(compact_text(sampler.sample()["text"]), "nvme0n1 R1.0kB/s W2.0kB/s")
        self.clock.return_value = 4
        self.disk.side_effect = [(4000, 8000), (10**12, 10**12)]
        self.assertEqual(compact_text(sampler.sample()["text"]), "nvme0n1 R1.0kB/s W2.0kB/s │ sda R 0B/s W 0B/s")
        self.disk.side_effect = [None, None]
        self.assertEqual(sampler.sample()["text"], "")
        self.assertEqual(sampler.previous, {})

    def test_disk_sector_deltas(self):
        sampler = throughput.Sampler("disks")
        self.disk.side_effect = [(100 * 512, 200 * 512), (110 * 512, 220 * 512)]
        sampler.sample()
        self.clock.return_value = 2.5
        self.assertEqual(compact_text(sampler.sample()["text"]), "nvme0n1 R2.0kB/s W4.1kB/s")


class PresentationTests(unittest.TestCase):
    def test_compact_precision_and_rounded_boundaries(self):
        for value, expected in (
            (0, "R  0B/s "), (9, "R  9B/s "), (999, "R999B/s "),
            (999.5, "R1.0kB/s"), (1000, "R1.0kB/s"), (9900, "R9.9kB/s"),
            (9940, "R9.9kB/s"), (9960, "R 10kB/s"), (10_000, "R 10kB/s"),
            (99_400, "R 99kB/s"), (99_900, "R100kB/s"), (100_000, "R100kB/s"),
            (999_400, "R999kB/s"), (999_500, "R1.0MB/s"),
            (999_400_000, "R999MB/s"), (999_500_000, "R1.0GB/s"),
            (999_500_000_000, "R999GB/s"), (10**18, "R999GB/s"),
        ):
            with self.subTest(value=value):
                markup = throughput.rate_markup(throughput.format_rate(value), "R", "#89b4fa")
                self.assertEqual(visible_text(markup).replace("\u00a0", " "), expected)

    def test_fixed_numeric_and_unit_slots_including_idle_and_json_roundtrip(self):
        for value in PRESENTATION_VALUES:
            rate = throughput.format_rate(value)
            for label in ("↓", "↑", "R", "W"):
                with self.subTest(value=value, label=label):
                    markup = throughput.rate_markup(rate, label, "#89b4fa")
                    text = visible_text(json.loads(json.dumps(markup)))
                    self.assertEqual(len(text), 8)
                    self.assertEqual(text[0], label)
                    number = text[1:4].lstrip("\u00a0")
                    self.assertRegex(number, r"^(?:\d{1,3}|\d\.\d)$")
                    self.assertEqual(text[1:4], number.rjust(3, "\u00a0"))
                    self.assertLess(float(number), 1000)
                    unit = text[4:8].rstrip("\u00a0")
                    self.assertIn(unit, ("B/s", "kB/s", "MB/s", "GB/s"))
                    self.assertEqual(text[4:8], unit.ljust(4, "\u00a0"))

    def test_complete_labels_lengths_and_column_positions_stay_fixed(self):
        for mode, name, labels in (
            ("network", "eth0", ("net", "↓", "↑")),
            ("disks", "nvme0n1", ("nvme0n1", "R", "W", "│", "sda")),
        ):
            baseline = visible_text(presentation_sample(mode, 0, name)["text"])
            for value in PRESENTATION_VALUES:
                with self.subTest(mode=mode, value=value):
                    result = json.loads(json.dumps(presentation_sample(mode, value, name)))
                    text = visible_text(result["text"])
                    self.assertEqual(len(text), len(baseline))
                    for label in labels:
                        self.assertEqual(text.index(label), baseline.index(label))
                    root = ElementTree.fromstring(result["text"])
                    self.assertEqual(root.attrib["font_family"], "JetBrainsMono Nerd Font")
                    self.assertIn(throughput.format_rate(value), result["tooltip"])
                    self.assertNotIn("<span", result["tooltip"])
                    self.assertNotIn("\u00a0", result["tooltip"])

    def test_direction_accents_quiet_units_and_idle_without_warning_thresholds(self):
        for label, color in (("↓", "#89b4fa"), ("R", "#89b4fa"),
                             ("↑", "#cba6f7"), ("W", "#cba6f7")):
            for value in (0, 1, 10**12):
                with self.subTest(label=label, value=value):
                    markup = throughput.rate_markup(throughput.format_rate(value), label, color)
                    spans = ElementTree.fromstring(f"<root>{markup}</root>").findall("span")
                    self.assertEqual(spans[0].attrib["foreground"], color if value else "#9399b2")
                    self.assertEqual(spans[1].attrib["foreground"], "#9399b2")

    def test_dynamic_names_are_escaped_and_tooltips_show_plain_names(self):
        name = 'eth<&"\'><b>0</b>'
        for mode in ("network", "disks"):
            with self.subTest(mode=mode):
                result = presentation_sample(mode, 1000, name)
                tooltip = visible_text(result["tooltip"])
                self.assertIn(name, tooltip)
                self.assertNotIn("<b>", result["tooltip"])
                self.assertNotIn("<span", result["tooltip"])
                if mode == "disks":
                    self.assertIn(name, visible_text(result["text"]))
                    self.assertNotIn("<b>", result["text"])
                    self.assertIn("&lt;", result["text"])


try:
    import gi
    gi.require_version("Pango", "1.0")
    gi.require_version("PangoCairo", "1.0")
    from gi.repository import Pango, PangoCairo
except (ImportError, ValueError):
    Pango = PangoCairo = None


@unittest.skipUnless(PangoCairo, "Optional local Pango renderer unavailable")
class PangoPresentationTests(unittest.TestCase):
    def test_pango_decodes_dynamic_names_without_treating_them_as_markup(self):
        name = 'eth<&"\'><b>0</b>'
        for mode in ("network", "disks"):
            with self.subTest(mode=mode):
                result = presentation_sample(mode, 1000, name)
                valid, _, tooltip, _ = Pango.parse_markup(result["tooltip"], -1, "\0")
                self.assertTrue(valid)
                self.assertIn(name, tooltip)
                valid, _, text, _ = Pango.parse_markup(result["text"], -1, "\0")
                self.assertTrue(valid)
                if mode == "disks":
                    self.assertIn(name, text)

    def test_offscreen_rendered_widths_and_column_positions(self):
        # PangoCairo's font map needs no GTK window, panel, or display connection.
        layout = Pango.Layout.new(PangoCairo.FontMap.get_default().create_context())
        font = Pango.FontDescription.from_string("JetBrainsMono Nerd Font")
        font.set_absolute_size(13 * Pango.SCALE)
        layout.set_font_description(font)
        for mode, name, labels in (
            ("network", "eth0", ("↓", "↑")),
            ("disks", "nvme0n1", ("R", "W", "│", "sda")),
        ):
            baseline = None
            for value in PRESENTATION_VALUES:
                with self.subTest(mode=mode, value=value):
                    result = presentation_sample(mode, value, name)
                    # Real Pango parsing checks attributes as well as XML syntax.
                    valid, _, text, _ = Pango.parse_markup(result["text"], -1, "\0")
                    self.assertTrue(valid)
                    layout.set_markup(result["text"], -1)
                    positions = [
                        layout.index_to_pos(len(text[:text.index(label)].encode())).x
                        for label in labels
                    ]
                    # Every numeric/unit slot starts at an identical pixel position.
                    for match in re.finditer(r"[↓↑RW](?=[\d\u00a0])", text):
                        for offset in (1, 4):
                            index = len(text[:match.start() + offset].encode())
                            positions.append(layout.index_to_pos(index).x)
                    measurement = (layout.get_pixel_size(), positions)
                    if baseline is None:
                        baseline = measurement
                    self.assertEqual(measurement, baseline)
                    valid, _, tooltip, _ = Pango.parse_markup(result["tooltip"], -1, "\0")
                    self.assertTrue(valid)
                    self.assertEqual(tooltip, visible_text(result["tooltip"]))


class StreamingTests(unittest.TestCase):
    def test_immediate_flushed_json_then_two_second_cadence(self):
        result = {"text": "", "class": "unavailable"}
        with patch("sys.argv", ["throughput.py", "network"]), patch.object(
            throughput, "Sampler"
        ) as sampler, patch.object(throughput.time, "monotonic", side_effect=[10, 10.25, 12, 12.1]), patch.object(
            throughput.time, "sleep", side_effect=[None, KeyboardInterrupt]
        ) as sleep, patch("builtins.print") as output:
            sampler.return_value.sample.return_value = result
            throughput.main()
            sampler.assert_called_once_with("network")
            self.assertEqual(output.call_count, 2)
            for args, kwargs in output.call_args_list:
                self.assertEqual(json.loads(args[0]), result)
                self.assertEqual(kwargs, {"flush": True})
            self.assertAlmostEqual(sleep.call_args_list[0].args[0], 1.75)
            self.assertAlmostEqual(sleep.call_args_list[1].args[0], 1.9)


if __name__ == "__main__":
    unittest.main()
