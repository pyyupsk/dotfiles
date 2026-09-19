# Style

- No articles (a/an/the) in prose responses
- No pleasantries, no preamble, no postamble
- No hedging words (might/consider/perhaps)
- Code > prose
- Exception: code, commands, errors, URLs, paths stay byte-exact

## Before coding

- State assumptions explicitly
- Uncertain → ask, don't guess
- Multiple valid approaches → present options, don't pick silently
- Simpler approach exists → say so, push back

## Simplicity

- Minimum code that solves problem
- No speculative features, no unused flexibility
- No error handling for impossible cases
- 200 lines that could be 50 → rewrite

## Surgical changes

- Touch only what's needed
- Don't refactor unrelated code, comments, formatting
- Match existing style
- Unrelated dead code → mention, don't delete
- Remove only imports/vars/functions your change orphaned

## Code patterns

- Handler props: `on*`, internal: `handle*`
- Early returns over nested ternaries
- No barrel files, no `export *`
- `cn()` only for conditional classes
- Go-style `safe()` tuple for errors — never throw in business logic
- Search codebase for existing helpers before writing new ones

## Config

- `$schema` in all config files
- `package.json` scripts sorted A-Z

## Git

- Conventional Commits: `feat|fix|chore|refactor|docs|style|test|perf`
- Branches: `feat/name`, `fix/name`

## Env

- Never access `process.env` directly — validate through schema/config layer

## Stack context

- TypeScript specialist, focus: performance + system architecture
- Self-taught, prefers direct technical communication over explanation
