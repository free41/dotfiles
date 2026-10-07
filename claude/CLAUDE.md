# Global Claude Code Instructions

- always uv and/or uvx for running python
- use ruff for formatting and ty for type checking python
- put project plans in a local repo directory like ./plans or other suitable directory instead of in ~/.claude
- when requesting to run bash or python commands, always describe the reason for running commands
- read markdown files with the Read tool, never with shell commands. To find headings or sections in long documents, use grep
- avoid making scratchpad python scripts. Prefer using the project dir for one off scritps in ./scripts or other suitable directlry. 
- always add a table of contents to the top of plans. Put the status of each line item in the plan. Update the status as progress is made.
- in general, explain the direction you are going in before doing. Align on the plan direction before doing. The user is highly annoyed when you start getting your hands dirty before aligning on a direction. It is fine to do exploration, analysis, etc.  
- Ask to make commits at intervals that make sense. Break up larger commits into multiple commits.
