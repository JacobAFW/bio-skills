---
name: catch-up
description: >-
  Bring Jacob back up to speed on a project that has gone stale for days or weeks.
  Use when he drops back into a project and asks to "catch me up", "where was I",
  "I've been away", "recap this project", "bring me up to speed", "what's the status
  here", "remind me where this is at", or says a project "went stale / cold". Reads
  the project's own status/memory files, README, git history, and recently-changed
  files, then gives a brief text recap AND renders a clean Cobalt2 HTML artifact:
  the high-level goal, phases taken as one-liners, the most recent phase in more
  detail (the launch-pad for next work), and the next concrete step + blockers.
  Default concise. Does not invent — derives from the files or flags the gap.
---

# catch-up

The orientation aid for coming back to a cold project. Optimised for one thing:
getting Jacob building again fast, without re-reading the whole repo.

## Sources (gather what exists, degrade gracefully)

- `STATUS.md`, `DECISIONS.md`, `MEMORY.md` — the richest signal when present.
- `README.md` / `CLAUDE.md` — for the high-level goal and scope.
- `git log` — recent commits with dates; last activity.
- Recently modified files and logs (by mtime), and any handoff notes
  (`cc_prompt_*`, `*_summary.md`, `drafts/`).

If a source is missing, derive what you can from git + files and say what couldn't
be reconstructed — never fill the gap with a guess.

## Output — two forms, both brief

1. **A short text recap** in chat (default concise, no preamble):
   - **Goal** — what the project is trying to achieve (1–2 lines).
   - **Phases so far** — one line each.
   - **Where you left off** — the substantive centre, NOT one or two lines. Cover
     the most recent work in real detail: what it produced, the headline numbers,
     the key finding/trade-off, the current lean/recommendation, and the caveats to
     carry forward. Include a metrics row (2–3 headline numbers) when the recent
     work has them, and a visual when one genuinely helps. This is what Jacob builds
     off next, so give it the most room.
   - **Resume here** — the next concrete step (and the pipeline steps after it),
     plus blockers with their age.

2. **A Cobalt2 HTML artifact**, always generated, using
   [`reference/catch-up-template.html`](../../reference/catch-up-template.html):
   - Fill the `{{PLACEHOLDERS}}`; **keep the CSS unchanged** so it stays consistent
     with Jacob's dashboards (Cobalt2 family, but cleaner and lighter).
   - Render it as an **inline artifact** — contained to the conversation, regenerated
     each time. Do NOT write it into the project folder unless he asks.
   - Include the optional visual card ONLY when the project has something genuinely
     worth showing (a results figure, a phase timeline, a progress bar). If there's
     nothing visual, delete that card — never a filler chart.

## Guardrails

- **Brief by default.** One line per phase; expand only the most recent work. If he
  wants more, he'll ask.
- **Don't invent.** Numbers, dates, phase names, and next steps come from the files
  or git — flag anything you can't source rather than stating it as fact.
- **Keep the aesthetic fixed.** Fill content, don't restyle; the template's CSS is
  the point of consistency.
- **Artifact, not a file.** Regenerate it live; don't leave stale recap HTML in the
  project unless explicitly asked to save one.
