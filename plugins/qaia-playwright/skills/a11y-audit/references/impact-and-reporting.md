# Severity filtering, the `incomplete` trap, and what the report may claim

## The four `impact` values, and where the failing line goes

axe-core labels every violation with one of four impacts. The mapping to a build decision:

| `impact` | Meaning in practice | This skill |
|---|---|---|
| `critical` | Blocks the user outright — no alt on a functional image, no label on a required field | **FAIL** |
| `serious` | Severe barrier with difficult workaround — contrast failure, missing form label | **FAIL** |
| `moderate` | Real degradation, workaround exists — heading order skips a level | Report, do not fail |
| `minor` | Annoyance or best-practice drift | Report, do not fail |

**Why the line sits between `serious` and `moderate`, and not elsewhere.** Below it, findings are
frequent, often stylistic, and produce the failure mode that kills accessibility work: a build
red for a skipped heading level, which teaches the team to disable the check. Above it, findings
correspond to a user who cannot complete the task at all. The line is a deliberate trade of
completeness for the check staying switched on — and everything below it is still *reported*, so
nothing is hidden, only un-gated.

**Do not move this line to make a suite green.** Downgrading a `serious` finding to reportable is
the accessibility equivalent of raising a visual-diff tolerance until the test passes. If a
`serious` violation is accepted, it is accepted **by a named human with a reason and a date in
the report**, not by editing the filter.

```js
const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
const blocking = results.violations.filter(v => v.impact === 'critical' || v.impact === 'serious');
const reportable = results.violations.filter(v => v.impact === 'moderate' || v.impact === 'minor');
```

## The `incomplete` trap

`results.incomplete` holds checks axe could not decide — most often contrast it could not compute
because the text sits on an image, a gradient, or a transparent layer.

**These are not passes.** They are the checks most likely to hide a real failure, because
"axe could not compute the background" describes exactly the visually complex places where
contrast tends to be wrong. A run that reports only `violations` reports a green that was never
measured.

List `incomplete` in the report as its own section, resolved by hand against M5 of the manual
pass. Assert `results.passes.length > 0` alongside the readiness locator: it proves the audit
actually saw a rendered screen rather than an empty shell.

## What tags to scan

`['wcag2a','wcag2aa']` is the default and matches the level nearly every regulation references.

- Add `wcag21a` / `wcag21aa` when the applicable standard is WCAG 2.1 (EN 301 549, and therefore
  the European Accessibility Act, reference 2.1 AA). This adds the reflow, orientation and
  non-text-contrast rules — omitting them under an EAA obligation leaves a real gap.
- `best-practice` is **not** WCAG. Useful, but its findings must never be reported as
  non-conformity — mixing them in is how a report loses its credibility with an auditor.

State the exact tag list in the report. "WCAG AA" without the tag list is not reproducible.

## What the report may and may not claim

A green automated run supports exactly one claim:

> No axe-detectable `serious` or `critical` violation on screens A, B, C, with axe-core `<version>`,
> tags `<list>`, on `<date>`.

It does not support "the app is accessible", "screen X is covered", or "WCAG 2.1 AA compliant".
Automated tooling reaches roughly a third of the success criteria; the manual pass extends the
claim but still does not produce a conformance verdict.

**When a regulation was named** (European Accessibility Act, RGAA, Section 508, or a contractual
WCAG commitment), the report says in as many words:

> This audit produces **evidence toward** conformance. It is not a conformance statement. A
> formal declaration (e.g. an accessibility statement or a VPAT) is issued by a human
> accessibility specialist after a full manual audit, on a defined scope and version.

This matters more here than in any other QAIA skill: an over-claimed accessibility report is not
just wrong, it is the artifact an organisation may rely on to declare conformance it does not
have. Under-claim on purpose.
