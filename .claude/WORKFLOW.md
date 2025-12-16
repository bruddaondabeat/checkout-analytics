# Multi-Agent Workflow

**Project:** Checkout Analytics Stack
**Philosophy:** Clean separation of concerns, minimal overhead

---

## The 3-Tool Stack

```
┌─────────────────────────────────────┐
│  CLAUDE SONNET 4.5 (Strategic)      │  ← This conversation
│  "Should I build this? How?"        │
└─────────────┬───────────────────────┘
              │
              ↓
┌─────────────────────────────────────┐
│  CLAUDE CODE CLI (Execution)        │  ← Terminal: `claude-code`
│  "Build this feature"               │
└─────────────┬───────────────────────┘
              │
              ↓
┌─────────────────────────────────────┐
│  GITHUB COPILOT (Autocomplete)      │  ← VS Code (passive)
│  (runs automatically)               │
└─────────────────────────────────────┘
```

**Optional 4th Tool:** Gemini for learning ("explain window functions") - NOT for code generation

**Eliminated:** Grok (redundant), multiple decision-makers (causes thrash)

---

## Tool Responsibilities

### 1. Claude (This Conversation)
**When to use:**
- Sprint planning and prioritization
- Architectural decisions
- Code review and feedback
- Interview preparation
- "Is this the right approach?" questions

**Examples:**
- "Should I build staging or intermediate layer first?"
- "Review my SQL style - is this following standards?"
- "How should I present this in Round 3?"

**Don't use for:**
- Writing individual SQL models (use Claude Code CLI)
- Autocomplete/boilerplate (use Copilot)

---

### 2. Claude Code CLI
**When to use:**
- Multi-file code generation
- dbt model creation
- Debugging compilation errors
- Refactoring across files
- "Build this specific thing" tasks

**Examples:**
```bash
# In terminal
claude-code

# Then prompt
"Create stg_stripe__transactions.sql following the CTE pattern in README.md"
"Debug this dbt compilation error"
"Refactor all staging models to use consistent naming"
```

**Don't use for:**
- Strategic decisions (ask main Claude first)
- Learning concepts (use Gemini or main Claude)

---

### 3. GitHub Copilot
**When to use:**
- Automatically (always on in VS Code)
- SQL autocomplete as you type
- Boilerplate generation
- Pattern repetition

**Examples:**
- Type `with source as (` → Copilot suggests rest of CTE
- Type column names → Copilot suggests similar columns
- Tab to accept suggestions

**Don't use for:**
- Doesn't require "use" - it's passive
- Accept good suggestions, ignore bad ones

---

### 4. Gemini (Optional Learning Tool)
**When to use:**
- Learning new concepts ("explain dbt materializations")
- Alternative explanations ("I don't get window functions")
- Quick lookups ("Snowflake syntax for dates")

**Don't use for:**
- Code generation (use Claude Code CLI)
- Architectural decisions (use main Claude)
- Creating dbt models (use Claude Code CLI)

**Why not Grok?**
- Redundant with Claude + Gemini
- Too many opinions = decision paralysis
- Keep it simple

---

## Context Files (Shared State)

### 1. README.md
**Purpose:** Project overview, stack, standards
**Updated by:** Humans (manual edits)
**Read by:** All agents
**When to read:** First time in project, when standards change

### 2. .claude/AGENT_CONTEXT.md
**Purpose:** Current sprint state, active tasks, recent changes
**Updated by:** Agents after completing tasks
**Read by:** All agents at start of session
**When to read:** Every time you start work

### 3. .claude/WORKFLOW.md (this file)
**Purpose:** How to use the multi-agent system
**Updated by:** Humans (manual edits)
**Read by:** Agents when first joining project
**When to read:** When unsure which tool to use

---

## Update Protocol

**When you complete a task:**

1. **Update AGENT_CONTEXT.md:**
   - Move task from "Active" to "Completed"
   - Update "Last Updated" timestamp
   - Add to "Recent Changes"
   - Note next action

2. **Backup conversation state:**
   - Add key decisions to `.claude/CONVERSATION_BACKUPS.md`
   - Include prompts used, decisions made, next steps
   - Do this every hour or after major milestones

3. **Commit to git:**
   ```bash
   # VS Code GUI: Cmd+Shift+G → Stage → Commit
   # Or terminal:
   git add .
   git commit -m "feat: add stg_stripe__transactions model

   - Created staging model with CTE pattern
   - Converts cents to USD, adds is_approved boolean
   - Added tests: unique, not_null

   🤖 Generated with Claude Code"
   ```

4. **Log any blockers:**
   - Add to "Questions for Human" section
   - Note in "Blocker" field

5. **Hand off clearly:**
   - Update "Next Action" so next agent knows what to do
   - Save backup prompt in CONVERSATION_BACKUPS.md
   - Close terminal/session cleanly

---

## Session Start Protocol

**When you start a new work session:**

1. **Read context files (in order):**
   - README.md (if first time, or if standards changed)
   - .claude/AGENT_CONTEXT.md (always)

2. **Check git status:**
   ```bash
   cd /Users/sov-t/checkout-analytics
   git status
   git log -1  # See what was last done
   ```

3. **Identify next action:**
   - Check "Active Tasks" in AGENT_CONTEXT.md
   - Check "Next Action" field
   - Start working

4. **Choose the right tool:**
   - Strategic question → Ask main Claude
   - Build something → Use Claude Code CLI
   - Learn concept → Use Gemini (optional)
   - Code autocomplete → Let Copilot do it

---

## Anti-Patterns (Don't Do This)

❌ **Asking multiple agents the same question**
- Creates conflicting advice
- Wastes time
- Choose ONE agent per question type

❌ **Using Claude Code CLI for strategy**
- It's for execution, not planning
- Ask main Claude for "should I" questions first

❌ **Over-documenting**
- Don't create docs per agent
- README + AGENT_CONTEXT is enough

❌ **Context duplication**
- Don't paste full README into every prompt
- Agents can read files - just reference them

❌ **Decision paralysis**
- Pick a tool, execute, adjust if needed
- Better to try and pivot than to plan forever

---

## Example Workflow (Day 2: Staging Layer)

**Morning session:**

1. **Open terminal, start main Claude:**
   ```
   You: "Read .claude/AGENT_CONTEXT.md and tell me what I should work on today"
   Claude: "You're on Day 2. Next actions: Load data to Snowflake, build staging models"
   ```

2. **Load data (manual, in Snowflake UI or SnowSQL)**

3. **Build staging model (switch to Claude Code CLI):**
   ```bash
   claude-code

   # Then prompt:
   "Create models/staging/stripe/stg_stripe__transactions.sql using the CTE pattern from README.md. Clean and rename columns from the Stripe schema."
   ```

4. **Test the model:**
   ```bash
   dbt run --select stg_stripe__transactions
   dbt test --select stg_stripe__transactions
   ```

5. **Review with main Claude:**
   ```
   You: [paste the SQL you generated]
   "Does this follow our coding standards? Any improvements?"
   Claude: [reviews, suggests changes]
   ```

6. **Update context:**
   - Edit .claude/AGENT_CONTEXT.md
   - Move task from Active to Completed
   - Commit and push

**Afternoon session:** Repeat for `stg_stripe__merchants`

---

## The Goal

**Keep it simple. Three tools:**
1. Main Claude = Strategy
2. Claude Code CLI = Execution
3. Copilot = Autocomplete

**Two files:**
1. README.md = Project overview
2. AGENT_CONTEXT.md = Current state

**One workflow:**
1. Read context
2. Execute task
3. Update context
4. Commit

**Don't overthink it. Ship fast.**
