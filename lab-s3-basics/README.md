# Lab: S3 Basics

**Topic:** Amazon S3 — bucket creation, versioning, seed data upload

## What this lab does
Creates an S3 bucket (named with your account ID so it's globally unique),
enables versioning, and uploads anything in `seed/` on each restore.

## Start a new session

```bash
# In AWS CloudShell:
git clone https://github.com/kunleoladiran/pluralsight-labs.git
cd pluralsight-labs/lab-s3-basics
chmod +x setup.sh save-session.sh
./setup.sh
```

## End a session

```bash
./save-session.sh "describe what you did and what's next"
```

## Resources created
- `aws_s3_bucket` — `pluralsight-lab-<account-id>`
- `aws_s3_bucket_versioning` — versioning enabled

---
## Session notes
<!-- save-session.sh appends here automatically -->

---
## Session note — 2026-11-02 22:24
Created S3 bucket with versioning - testing save/restore loop

---
## Session note — 2026-11-02 22:25
Created S3 bucket with versioning - testing save/restore loop
