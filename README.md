# Pluralsight Labs

AWS sandbox labs. Each folder is one lab. Resources vanish when the sandbox resets — this repo is what survives.

## Session workflow (30-second version)

| When | Command |
|------|---------|
| Start of session | `export AWS_ACCESS_KEY_ID=... && ./setup.sh` |
| Every 20–30 min | `git add -A && git commit -m "wip" && git push` |
| End of session (3h15m alarm) | `./save-session.sh "what you did and what's next"` |

## Labs

| Folder | Topic | Status |
|--------|-------|--------|
| `_template` | Reusable starter | — |

## Starting a new lab

```bash
cp -r _template my-new-lab
cd my-new-lab
# Edit main.tf, README.md, setup.sh as needed
```
