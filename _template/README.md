# Lab: [Lab Name]

**Course:** [Pluralsight course name]
**Topic:** [e.g. VPC networking, Lambda, RDS, etc.]

## What this lab does
[One paragraph describing the goal]

## Start a new session

```bash
# 1. Export credentials from the Pluralsight panel
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1

# 2. Clone (first time) or pull (returning)
git clone https://github.com/YOUR_USERNAME/pluralsight-labs.git
# OR
git pull

# 3. Bootstrap everything
cd pluralsight-labs/_template   # replace with your lab folder
./setup.sh
```

## End a session

```bash
# Run before the 4-hour timer hits zero (set a 3h15m alarm)
./save-session.sh "describe what you did and what's next"
```

## Architecture
[Diagram or description of resources created by main.tf]

## Manual steps (things that can't be scripted)
- [e.g. IAM console actions, SSO setup, etc.]

---
## Session notes
<!-- save-session.sh appends here automatically -->
