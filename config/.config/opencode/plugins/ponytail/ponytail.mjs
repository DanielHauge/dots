import { mkdir, readFile, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const MODES = new Set(["off", "lite", "full", "ultra"]);
const statePath = join(
  process.env.XDG_CONFIG_HOME || join(homedir(), ".config"),
  "opencode",
  ".ponytail-active",
);

function normalizeMode(value) {
  const mode = String(value || "").trim().toLowerCase();
  return MODES.has(mode) ? mode : undefined;
}

async function readMode() {
  try {
    return normalizeMode(await readFile(statePath, "utf8")) || "full";
  } catch {
    return "full";
  }
}

async function writeMode(mode) {
  await mkdir(dirname(statePath), { recursive: true });
  await writeFile(statePath, mode, "utf8");
}

function requestedMode(text) {
  for (const token of String(text || "").toLowerCase().match(/\b[a-z]+\b/g) || []) {
    if (MODES.has(token)) return token;
  }
}

function instructions(mode) {
  const core = [
    "Ponytail: favor the smallest change that satisfies the explicit request.",
    "Apply YAGNI: do not add speculative features, abstractions, configuration, or boilerplate.",
    "Before adding code or a dependency, prefer deletion, the standard library, native platform features, or an already-installed dependency.",
    "Keep code direct and local; introduce an abstraction only when the current requirement genuinely needs it.",
    "Do not trade away safety, data integrity, accessibility, or explicit requirements for minimalism.",
  ];

  if (mode === "lite") return core.slice(0, 2).join("\n");
  if (mode === "ultra") {
    return [
      ...core,
      "For each nontrivial addition, state why it is needed now and remove anything that does not serve that need.",
      "When reviewing, name concrete deletions or simpler replacements rather than proposing a framework.",
    ].join("\n");
  }
  return core.join("\n");
}

function promptOptions(invocation) {
  const prompt = invocation?.prompt || {};
  const delivery = invocation?.delivery ?? prompt.delivery;
  return {
    ...(prompt.parts ? { parts: prompt.parts } : {}),
    ...(prompt.files ? { files: prompt.files } : {}),
    ...(delivery ? { delivery } : {}),
  };
}

async function submit(ctx, invocation, text) {
  await ctx.session.prompt({
    sessionID: invocation?.sessionID,
    text,
    ...promptOptions(invocation),
  });
}

export default {
  id: "ponytail",
  async setup(ctx) {
    await ctx.session.hook("context", async (event) => {
      const mode = await readMode();
      if (mode !== "off") {
        event.system.push({ type: "text", text: instructions(mode) });
      }
    });

    await ctx.command.transform((commands) => {
      commands.add({
        name: "ponytail",
        description: "Set Ponytail mode: off, lite, full, or ultra",
        execute: async (invocation) => {
          const mode = requestedMode(invocation?.prompt?.text) || await readMode();
          await writeMode(mode);
          await submit(ctx, invocation, `Ponytail mode is now ${mode}. Keep the next response concise and follow that mode.`);
        },
      });

      commands.add({
        name: "ponytail-review",
        description: "Review the working diff for over-engineering",
        execute: async (invocation) => {
          await submit(
            ctx,
            invocation,
            "Review the current working diff for over-engineering only. Apply Ponytail: identify dead or speculative code, unnecessary abstractions, avoidable dependencies, and places where stdlib/native features or less code suffice. Give concise, actionable findings; do not compromise safety, data integrity, accessibility, or explicit requirements. If nothing should be cut, say: Lean already. Ship.",
          );
        },
      });
    });
  },
};
