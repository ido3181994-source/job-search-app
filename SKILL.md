---
name: ido-job-search-3x-daily
description: Run Ido Nativ's job search 3x/day (9am, 1pm, 6pm local). Read profile, search sites, score matches, update dashboard, generate tailored CVs.
---

You are running Ido Nativ's recurring job search. Follow these steps precisely.

## Step 1: Read the profile
Read the candidate profile from `D:\CV's\job_search_profile.md` (fall back to `outputs/job_search_profile.md`).

## Step 2: Read existing matches
Read `D:\CV's\job_matches.json`. Note all existing job IDs/URLs — don't re-add. Tier A entries that fail re-verification: only mark removed after 2 consecutive misses (`verify_misses` counter).

## Step 3: Search for active postings (CORRECTED FILTERS)

The user explicitly required only LIVE listings. Source hierarchy:

**Tier A — Trustworthy by default (search hit = active):**
- `site:boards.greenhouse.io` and `site:job-boards.greenhouse.io`
- `site:jobs.lever.co`
- `site:apply.workable.com`
- `site:jobs.ashbyhq.com`
- `site:comeet.com` — Israeli ATS, dominant for Tel Aviv tech. ALWAYS query.
- `site:wellfound.com`
- `site:jobs.smartrecruiters.com`

**Tier B — HTTP-verify required (LinkedIn primary):**
LinkedIn via authenticated Chrome — use `mcp__Claude_in_Chrome__list_connected_browsers` → `select_browser` → `navigate`.

**CORRECTED LinkedIn URLs (broader filters — this fix went 7 results → 29):**

CSM (no work-mode filter, past month, 25km radius, mid+associate):
```
https://www.linkedin.com/jobs/search/?keywords=Customer%20Success%20Manager&location=Tel%20Aviv%20District%2C%20Israel&f_TPR=r2592000&f_E=3%2C4&distance=25
```

AM (same):
```
https://www.linkedin.com/jobs/search/?keywords=Account%20Manager&location=Tel%20Aviv%20District%2C%20Israel&f_TPR=r2592000&f_E=3%2C4&distance=25
```

**DO NOT** add `f_WT=3` (Hybrid only) — it drops on-site Tel Aviv listings the user explicitly accepts. **DO NOT** use `f_TPR=r604800` (past week) — too narrow, prefer `r2592000` (past month). **DO NOT** narrow `location` to "Tel Aviv, Israel" — use "Tel Aviv District, Israel" with `distance=25`.

After navigating, run this JS to extract all listings on the page:
```js
Array.from(document.querySelectorAll('li.scaffold-layout__list-item, li[data-occludable-job-id]')).map(el => {
  const t = el.querySelector('a.job-card-list__title, a.job-card-container__link')?.textContent?.trim() || '';
  const c = el.querySelector('.artdeco-entity-lockup__subtitle')?.textContent?.trim() || '';
  const m = el.querySelector('.artdeco-entity-lockup__caption')?.textContent?.trim() || '';
  return { t: t.replace(/\s+/g,' ').slice(0,80), c, m };
}).filter(x => x.t)
```

Also paginate (`&start=25`, `&start=50`) until results stop.

**Tier C — Banned by default:**
- `alljobs.co.il/Search/UploadSingle.aspx?JobID=...` — HTTP 410 Gone reliably. Skip.
- `drushim.co.il` deep links — same.
- Any `*.co.il/.../JobID=` numeric URLs.

## Step 4: Run a comprehensive query set every run

Always run AT LEAST these:
- LinkedIn CSM + AM via Chrome (the corrected URLs above)
- `site:comeet.com "Customer Success Manager" Tel Aviv`
- `site:comeet.com "Account Manager" Israel`
- `site:boards.greenhouse.io "Customer Success Manager" Tel Aviv`
- `site:boards.greenhouse.io "Account Manager" Tel Aviv`
- `site:apply.workable.com "Customer Success" Israel`
- `site:jobs.ashbyhq.com "Customer Success Manager" Israel`
- `site:wellfound.com "Customer Success Manager" Tel Aviv`

## Step 5: Score each new posting
Apply rubric: Role 40 / Seniority 20 / Location 15 / Skills 15 / Salary 5 / Bonus 5. Threshold: 70.

## Step 6: Re-verify existing matches
For each in `job_matches.json`:
- Tier A → re-search. Missing? increment `verify_misses`. After 2 misses, move to `removed_this_run`.
- Tier B → re-fetch URL. 404/410 → move to `removed_this_run`.

## Step 7: Update job_matches.json
Merge, dedupe by URL, remove dead. Update `last_run`. Cap at 30 highest-scoring.

## Step 8: Generate tailored CVs for new matches
Save to `D:\CV's\IdoNativ_CV_<Company>_<Role>.html` using the styled template (same blue accent as original CV — print-to-PDF ready). Apply no-fabrication rules from `references/cv-tailoring.md`.

## Step 9: Update the mobile app and push to GitHub Pages

Read `C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily\index.html`.

Replace the `const DATA = {...};` block (the single line starting with `const DATA =`) with the current contents of `D:\CV's\job_matches.json`, formatted as:
```
const DATA = <job_matches_json_content>;
```

Write the updated file back to `C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily\index.html`.

Then run these git commands in that directory:
```
cd "C:\Users\USER\Documents\Claude\Scheduled\ido-job-search-3x-daily"
git add index.html
git commit -m "Job search update <last_run timestamp>"
git push origin main
```

The live app will be available at: https://ido3181994-source.github.io/job-search-app

## Step 10: Notify
Concise summary: new matches by score band, dead listings removed, top 3 by score, and any sources you couldn't access.

## Constraints
- NEVER include unverified listings.
- Don't apply on the user's behalf.
- Stay at 70%+ threshold; log lower as `below_threshold`.
- Be transparent about what you couldn't reach.