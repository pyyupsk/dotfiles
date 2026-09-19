---
description: Hand an approved plan to opencode CLI with the best-fit model, then show the diff
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(opencode run:*), Bash(cat ~/.config/opencode/opencode.json)
---

Execute this approved plan using the `opencode` CLI, then report back the diff for review. Do not implement it yourself.

Plan:
$ARGUMENTS

Steps:

1. Run `git status --short` to confirm the working tree is clean before delegating (abort and warn if not).
2. Pick the model. Read `~/.config/opencode/opencode.json` (providers: `opencode`, `ollama-cloud`, `aipass`) and classify the plan:
   - Trivial (single file, renames/moves only, no logic change): cheapest available — an `ollama-cloud` whitelist model, else an `opencode` whitelist model, else `.small_model`.
   - Standard implementation (everything else): `.agent.build.model`, else top-level `.model`.
   - Complex (3+ files, migration, auth/security, or the plan flags risk): `.agent.plan.model`, else `.agent.build.model`.
   Verify the pick exists in its provider: `opencode`/`ollama-cloud` require whitelist membership (free-to-use only); `aipass` requires presence in its `.models` map. Otherwise stop and warn instead of running; never silently substitute another model.
3. Run `opencode run --auto --format default -m "<picked model>" "$ARGUMENTS"` to execute the plan mechanically.
4. Run `git diff` (and `git status --short` for new files) to capture what opencode changed.
5. Show the full diff and the model used to me. Do not commit, stage, or otherwise act on it — I'll review and decide.
