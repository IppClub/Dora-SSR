---
name: skill-creator
description: Guide the agent to create a new project skill with correct placement, required metadata, and a practical SKILL.md template.
---

# Skill Creator

Use this skill when the user asks to create a new skill, write a skill, or add guidance for skill authoring.

## Goal

Create a skill that can be auto-discovered by the current project. The required directory structure is:

```text
.agent/skills/<skill-name>/
└── SKILL.md
```

The entry file must be named `SKILL.md`. Do not use any other filename.

## Required Structure

1. The skill must be placed under the project root at `.agent/skills/<skill-name>`.
2. `<skill-name>` should be short, stable, and readable. Prefer kebab-case such as `skill-creator` or `api-review`.
3. The skill entry file must be `.agent/skills/<skill-name>/SKILL.md`.
4. `SKILL.md` must begin with YAML frontmatter.
5. The frontmatter must include at least:
   - `name`
   - `description`
6. Optional field:
   - `always: true`, only add this when the skill should always be active.

## Required Metadata Template

When creating a new skill, start the file with this template before writing the body:

```md
---
name: your-skill-name
description: One-sentence description of when this skill should be used.
---
```

If the skill should always be active, use:

```md
---
name: your-skill-name
description: One-sentence description of when this skill should be used.
always: true
---
```

## Writing Requirements

1. `name` should match the skill's responsibility and stay concise and clear.
2. `description` should explain when the skill should be used. Do not write vague filler text.
3. The body should directly tell the agent:
   - when to trigger this skill
   - which steps to execute
   - which constraints must be followed
   - what final output is expected
4. Prefer executable instructions over general description.
5. If the skill depends on project files, scripts, or directories, state the relative paths and their purpose clearly.

## Recommended Structure

Use this structure for the skill body:

```md
# Skill Name

One sentence explaining what this skill is for.

## When to Use

- Trigger condition 1
- Trigger condition 2

## Steps

1. Describe the first step.
2. Describe the second step.
3. Describe the third step.

## Constraints

- Constraint 1 that must be followed
- Constraint 2 that must be followed

## Output

- Describe the expected files, changes, or result.
```

## Execution Process

When you are actually creating a new skill for the user:

1. Choose the skill name based on its purpose.
2. Create the directory `.agent/skills/<skill-name>`.
3. Create the entry file `.agent/skills/<skill-name>/SKILL.md`.
4. Write the frontmatter first, then the body.
5. Verify that `name` and `description` both exist and are non-empty.
6. Verify that the content clearly defines trigger conditions, steps, and expected output.

## Minimal Example

```md
---
name: api-review
description: Use this skill when the user asks for an API design or contract review.
---

# API Review

Use this skill when the user asks for an API design, contract, or request/response structure review.

## Steps

1. Read the relevant API definitions and call sites.
2. Check naming, consistency, error handling, and compatibility risks.
3. Output findings, risks, and suggested improvements.
```

## Notes

- Do not place the new skill in any other directory.
- Do not rename or omit the `SKILL.md` entry file.
- Do not omit the frontmatter at the top of the file.
- If `name` or `description` is missing, the current project will not recognize it as a valid skill.
