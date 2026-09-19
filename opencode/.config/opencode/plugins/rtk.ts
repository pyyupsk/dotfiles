import { execFile } from "node:child_process"
import { promisify } from "node:util"

const execFileAsync = promisify(execFile)

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.

async function rewriteCommand(command: string): Promise<string | undefined> {
  // `rtk rewrite` prints replacement to stdout and exits non-zero when
  // a rewrite applies, so stdout must be read on success and on error.
  const read = (stdout: unknown) => {
    const rewritten = String(stdout ?? "").trim()
    return rewritten && rewritten !== command ? rewritten : undefined
  }
  try {
    const { stdout } = await execFileAsync("rtk", ["rewrite", command])
    return read(stdout)
  } catch (error) {
    return read((error as { stdout?: unknown })?.stdout)
  }
}

export default {
  id: "rtk",
  async setup(ctx) {
    try {
      await execFileAsync("rtk", ["--version"])
    } catch {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", async (event) => {
      const tool = String(event.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const args = event.input
      if (!args || typeof args !== "object") return

      const command = (args as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return

      const rewritten = await rewriteCommand(command)
      if (rewritten) {
        ;(args as Record<string, unknown>).command = rewritten
      }
    })
  },
}
