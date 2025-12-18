# 📖 Agent Guide: How to Use These Handoff Files

**Quick Start:** Read this first to understand which file to read when.

---

## 📂 Handoff File Structure

```
.claude/
├── README_AGENT_GUIDE.md          ← YOU ARE HERE (read this first!)
├── CURRENT_STATE_HANDOFF.md       ← MAIN HANDOFF (read this second)
├── AGENT_CONTEXT.md                ← Historical context (reference as needed)
├── SESSION_SUMMARY.md              ← Today's work summary (Dec 17, 2024)
├── NEXT_AGENT_HANDOFF.md          ← OUTDATED (from Dec 16 - DO NOT USE)
└── WORKFLOW.md                     ← Project conventions (reference as needed)
```

---

## 🎯 Which File Should I Read?

### **Scenario 1: New Agent Starting Fresh**
**Read in this order:**
1. ✅ `README_AGENT_GUIDE.md` (this file - 2 min read)
2. ✅ `CURRENT_STATE_HANDOFF.md` (comprehensive guide - 10 min read)
3. 📌 `SESSION_SUMMARY.md` (what happened today - 5 min read)
4. 📌 `AGENT_CONTEXT.md` (historical reference - skim as needed)

**Skip:**
- ❌ `NEXT_AGENT_HANDOFF.md` (outdated from Dec 16)

---

### **Scenario 2: Resuming Work After a Break**
**Read in this order:**
1. ✅ `CURRENT_STATE_HANDOFF.md` (full current state)
2. 📌 `SESSION_SUMMARY.md` (recent changes)

---

### **Scenario 3: Quick Status Check**
**Read:**
- ✅ `AGENT_CONTEXT.md` - Look at "Current Sprint State" section (first 20 lines)

---

### **Scenario 4: Need Project Conventions**
**Read:**
- ✅ `WORKFLOW.md` - Coding standards, file naming, git workflow

---

## 📋 File Descriptions

### **CURRENT_STATE_HANDOFF.md** ⭐ MOST IMPORTANT
**Length:** ~400 lines
**Purpose:** Complete handoff for next agent
**Contains:**
- ✅ What's been completed (Days 1-4)
- 📋 Remaining work (Days 5-7) with step-by-step instructions
- 💡 Interview talking points and anticipated questions
- 🚨 Known issues and how to explain them
- 📂 Project file structure reference
- 🎯 Success criteria (how to know you're done)

**When to read:** ALWAYS - this is the source of truth

---

### **SESSION_SUMMARY.md**
**Length:** ~200 lines
**Purpose:** Summary of today's work (Dec 17, 2024)
**Contains:**
- ✅ What we accomplished (Tableau dashboard build)
- 🛠 Technical challenges solved
- 💡 Key design decisions made
- 📊 Context usage stats
- 🚀 How to resume work

**When to read:** After reading CURRENT_STATE_HANDOFF to understand recent changes

---

### **AGENT_CONTEXT.md**
**Length:** ~250 lines
**Purpose:** Historical project context
**Contains:**
- 🎯 Current sprint state
- ✅ Completed tasks (running log)
- 🔄 Active tasks
- 📊 Data summary (150k rows, approval rate, etc.)
- 🏗 Architecture plan
- 🎤 Interview context

**When to read:** For historical reference or to understand project evolution

---

### **WORKFLOW.md**
**Length:** ~150 lines
**Purpose:** Project conventions and standards
**Contains:**
- 🧠 Coding standards (CTE-only pattern, snake_case, etc.)
- 📁 File naming conventions
- 🧪 Testing approach
- 📝 Documentation requirements
- 🔀 Git workflow

**When to read:** When writing new code or creating new files

---

### **NEXT_AGENT_HANDOFF.md** ❌ OUTDATED
**Status:** DO NOT USE - replaced by CURRENT_STATE_HANDOFF.md
**Why outdated:** Written on Dec 16 before Tableau dashboard was built
**What's wrong:** Says "BI Tool Integration" is next, but it's already done

---

## ⏱️ Time Budget for Reading

**Minimum (to start work):**
- `README_AGENT_GUIDE.md` (this file): 2 minutes
- `CURRENT_STATE_HANDOFF.md`: 10 minutes
- **Total: 12 minutes**

**Recommended (for full context):**
- `README_AGENT_GUIDE.md`: 2 minutes
- `CURRENT_STATE_HANDOFF.md`: 10 minutes
- `SESSION_SUMMARY.md`: 5 minutes
- Skim `AGENT_CONTEXT.md`: 3 minutes
- **Total: 20 minutes**

---

## 🚀 Quick Start Checklist

Before you start working, make sure you:

- [ ] Read `CURRENT_STATE_HANDOFF.md` (the main handoff doc)
- [ ] Understand what's been completed (Days 1-4)
- [ ] Know what you need to do next (Days 5-7 tasks)
- [ ] Verify environment works:
  ```bash
  cd /Users/sov-t/checkout-analytics
  source .venv/bin/activate
  dbt debug  # Should pass
  ```
- [ ] Check Tableau dashboard is live: https://public.tableau.com/app/profile/tyler.mclaurin/viz/Checkout-Analytics/Dashboard1
- [ ] Review README.md to see updated dashboard section

---

## 📊 Current Project Status (At a Glance)

**Sprint Progress:** Days 1-4 of 7 COMPLETE ✅

**What's Done:**
- ✅ Data models (staging, intermediate, marts)
- ✅ Tableau Executive Dashboard (live on Tableau Public)
- ✅ README documentation (130+ lines of insights)
- ✅ Business metrics identified ($727K recoverable revenue)

**What's Next:**
- ⏳ Generate dbt docs and take screenshots
- ⏳ Run full test suite (`dbt test`)
- 📌 Optional: Create Loom walkthrough video
- 📌 Practice interview talking points

**Interview Readiness:** 🟢 READY TO DEMO NOW
- Dashboard can be shown today
- Business insights documented
- Remaining work is polish, not core functionality

---

## 💡 Pro Tips for Next Agent

1. **Don't skip CURRENT_STATE_HANDOFF.md** - It has everything you need
2. **Verify environment first** - Run `dbt debug` before starting work
3. **Check the Tableau dashboard** - Make sure you can access it
4. **Context is at 88%** - Be concise in your responses
5. **This is for an interview** - Quality > Speed
6. **User has Git agent** - Don't worry about commits
7. **Ask clarifying questions** - User values precision

---

## 📞 Key Resources

**Tableau Dashboard:**
https://public.tableau.com/app/profile/tyler.mclaurin/viz/Checkout-Analytics/Dashboard1

**GitHub Repo:**
https://github.com/bruddaondabeat/checkout-analytics (PRIVATE)

**Project Location:**
`/Users/sov-t/checkout-analytics`

**dbt Profile:**
`~/.dbt/profiles.yml` (profile name: `payment_analytics`)

---

## 🎯 Your First Action

**Step 1:** Read `CURRENT_STATE_HANDOFF.md` now → [Link](.claude/CURRENT_STATE_HANDOFF.md)

**Step 2:** Come back and reference this guide as needed

**Step 3:** Start on Day 5 tasks (dbt docs generation)

---

**Good luck! The project is in great shape and ready for the final sprint.** 🚀
