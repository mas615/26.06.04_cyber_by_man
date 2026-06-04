# Behavior Discovery

Use this when the user asks which behavior is selected, what the goal is, or asks for a full wave scan.

## Current Behavior Check

Use CDP to read the visible page:

```powershell
$project = "<project-root>"
node "$project\tools\chrome_cdp\cdp_eval.js" --match "app.grayswan.ai" --expr "(()=>{const text=document.body?.innerText||''; return {title:document.title,url:location.href,text:text.slice(0,4000)};})()"
```

Look for:

```text
Wave 1
Behavior name
Earth Capybara Legendary
Behavior Criteria
```

## Criteria Panel

The Behavior Criteria content often exists only after the panel is opened. If the user says it appears only after toggling:

1. Select the behavior.
2. Click Save if the UI requires it.
3. Close and reopen `Behavior Criteria`.
4. Extract the panel text through CDP.

Generic extraction:

```powershell
node "$project\tools\chrome_cdp\cdp_eval.js" --match "app.grayswan.ai" --expr "(async()=>{const btn=Array.from(document.querySelectorAll('button')).find(b=>(b.innerText||'').trim()==='Behavior Criteria'); if(btn && btn.getAttribute('aria-expanded')!=='true') btn.click(); await new Promise(r=>setTimeout(r,700)); const text=document.body?.innerText||''; const idx=text.indexOf('CRITERIA'); return {url:location.href,criteriaVisible:idx>=0,aroundCriteria:idx>=0?text.slice(Math.max(0,idx-1600),idx+1800):text.slice(-4000)};})()"
```

## Full Wave Scan

If this project has the helper script, use it:

```powershell
node "$project\tools\chrome_cdp\collect_behavior_details.js"
```

For each behavior, save:

```text
behavior_catalog/waveN/NN_slug/01_original_goal.md
behavior_catalog/waveN/NN_slug/02_analysis.md
```

`01_original_goal.md` should preserve the original visible text:

- behavior name
- wave
- overview
- criteria
- any visible scoring/task text

`02_analysis.md` should separate:

- objective in plain language
- required proof artifacts
- likely difficulty
- likely block-sensitive terms observed so far
- unknowns to verify

## Selecting A Behavior

If `tools/chrome_cdp/select_behavior.js` exists:

```powershell
node "$project\tools\chrome_cdp\select_behavior.js" --wave 2 --behavior "ImageTragick"
```

After selection, verify the page again. Do not assume a behavior switch worked until the visible page or criteria panel confirms it.

## Important Interpretation Rules

- The right-side criteria panel tells the human what the judge wants. It may not be visible to the model unless the platform injects it elsewhere.
- The selected behavior still appears to affect platform filtering, even if the chat prompt is generic.
- Do not infer success from a normal model response. Success requires a judge submission and matching criteria.
- If there are no submissions, the page may show `No submissions found, try submitting a jailbreak!`; that only means no judged attempt exists yet.
