# How to Resume Your Claude Code Session

## 🎯 Problem
Claude Code GUI doesn't automatically show past conversations from your project folder. The "Past Conversations" panel only shows chats stored in VS Code's internal cache, which can be lost.

## ✅ Solution
Use the **context files** in this folder ([.claude/](./.)) to resume any time.

---

## 📋 Step-by-Step: Resume a Session

### When Opening a New Chat Window

1. **Open this file:** [.claude/CONVERSATION_BACKUPS.md](./CONVERSATION_BACKUPS.md)

2. **Copy the "Universal Resume Prompt"** (at the top of that file)

3. **Paste it into your new Claude Code chat**

4. **Claude will:**
   - Read [AGENT_CONTEXT.md](./AGENT_CONTEXT.md) to see what's done
   - Tell you what tasks are completed
   - Tell you what to work on next
   - Wait for your instructions

### Example Resume Message

```
Resuming checkout-analytics project (Checkout.com interview prep).

IMPORTANT: Read these files FIRST to get full context:
1. .claude/AGENT_CONTEXT.md (current state, completed tasks, next actions)
2. README.md (project overview, coding standards)
3. .claude/WORKFLOW.md (workflow guide)

After reading, tell me:
- What tasks are completed
- What's currently in progress
- What should we work on next

Then wait for my instructions.
```

---

## 📁 What Each Context File Does

| File | Purpose |
|------|---------|
| [AGENT_CONTEXT.md](./AGENT_CONTEXT.md) | **Current project state** - completed tasks, active tasks, next actions |
| [CONVERSATION_BACKUPS.md](./CONVERSATION_BACKUPS.md) | **Session summaries** - what happened in each work session |
| [WORKFLOW.md](./WORKFLOW.md) | **How to work** - coding standards, dbt patterns, interview context |
| [HOW_TO_RESUME.md](./HOW_TO_RESUME.md) | **This file** - instructions for resuming chats |

---

## 🔄 Keeping Backups Fresh

### After Each Major Milestone

Tell Claude:
```
Update AGENT_CONTEXT.md - I just finished [task name]
```

Claude will:
1. Update the completed tasks list
2. Move items from "Active" to "Completed"
3. Note next actions
4. Commit the changes to Git

### End of Work Session

Tell Claude:
```
End of session. Update CONVERSATION_BACKUPS.md with what we accomplished today.
```

Claude will:
1. Summarize the session
2. Add it to CONVERSATION_BACKUPS.md
3. Commit and push to GitHub

---

## 💡 Pro Tips

### Tip 1: Always Keep Git Synced
After updating context files:
```bash
git add .claude/
git commit -m "docs: Update context after [task]"
git push
```

This ensures your backups are on GitHub, not just local.

### Tip 2: Use the Universal Prompt
Don't try to summarize what you did - just use the Universal Resume Prompt. Claude will read all the context files and know exactly where you are.

### Tip 3: Test Resuming
Every few days, close VS Code completely and test resuming with the prompt. This ensures your backup system is working.

---

## ✅ Your Backup Safety Net

**3 Layers of Protection:**

1. **Local files** → [.claude/](./) folder has all context
2. **GitHub remote** → `git push` backs up to github.com/bruddaondabeat/checkout-analytics
3. **Claude reads context** → Any new chat can pick up where you left off

**Even if:**
- VS Code crashes ✅
- You switch computers ✅
- Chat history gets cleared ✅
- Extension cache is lost ✅

**You can always resume** by pasting the Universal Resume Prompt!

---

## 🧪 Test It Now

Want to verify it works?

1. Open a **new Claude Code chat tab** (click the + icon)
2. Paste the Universal Resume Prompt from [CONVERSATION_BACKUPS.md](./CONVERSATION_BACKUPS.md)
3. See Claude immediately know the project state

Try it! It works every time.
