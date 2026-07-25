## What & why

<!-- Link the issue this PR implements. PRs without a challenged issue may be closed. -->

## Checklist

- [ ] All commits are signed off (`git commit -s`, DCO)
- [ ] One concern only in this PR
- [ ] CI is green (form: manifests, Gherkin, structure)

### If this PR touches `plugins/**`, `.claude-plugin/**`, or `.github/workflows/**`

- [ ] **Demonstration by usage** included (conversation excerpt or output)
- [ ] No network calls, external fetch targets, or off-purpose commands introduced
- [ ] No hooks, MCP servers, or agent definitions introduced (not accepted at this stage — see CONTRIBUTING)
- [ ] *(maintainer)* **Adversarial agent review** launched by the maintainer and posted in this PR — an author-posted review has no probative value
- [ ] *(maintainer)* Evaluation harness green **before merge** for generation-skill changes
