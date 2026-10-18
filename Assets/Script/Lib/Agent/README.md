# Agent modules

The root contains the Agent entry points: `DoraAgent` runs coding tasks,
`Session` manages sessions, `Tools` exposes tool operations, and `Utils` provides
shared request, message and model helpers.

- `Config/`: defaults, limits and file patterns; LLM configuration migrations
  and name validation. Keep migration and name validation independent and
  import the specific module needed by each caller.
- `Runtime/`: execution flow, memory, skills, questionnaires, local backend
  processes, task policies and events.
- `Tool/`: tool implementations, registry, input/JSON Schema validation,
  workspace access and tool lifecycle support.
- `Storage/`: persistent task/session data and database helpers.
- `Gen/`: Blockly and music generation.

TypeScript and its generated Lua stay together. Module paths in the native
server, mobile scripts, Studio tooling and Dora-Example tests must follow the
same directory structure. Moving a module does not change its database keys,
configuration format or on-disk user data paths.
