# Contributing to smart-i18n

Thanks for considering a contribution! Here's how you can help.

## Ways to Contribute

### Add a Framework Adapter

The plugin's strength is framework coverage. If your stack isn't supported or the detection could be better:

1. Add detection logic to `skills/smart-i18n/scripts/detect.sh`
2. Document the adapter in `skills/smart-i18n/references/adapters.md` — detection signals, code patterns, init steps, interpolation format
3. Update the SKILL.md extract workflow if the framework has a unique replacement pattern
4. Test with a real project using that framework

### Improve String Detection

The scan heuristic is good but not perfect. If you find false positives or missed strings:

1. Open an issue describing the string, the context, and whether it should be flagged or not
2. If you have a fix, update the scoring rules in the SCAN section of `skills/smart-i18n/SKILL.md`

### Share Translation Glossaries

Domain-specific glossaries help maintain translation consistency. If you've built a glossary for a specific domain (e-commerce, fintech, healthcare, etc.):

1. Format it as a JSON object: `{ "term": { "locale": "translation" } }`
2. Open a PR adding it to a `glossaries/` directory (create it if needed)
3. Include the domain and target locales in the PR description

### Improve Language Rules

The translation quality guidelines in `skills/smart-i18n/references/translation.md` can always be more comprehensive. Native speakers are especially welcome to:

- Add missing languages
- Correct or refine existing rules
- Add common pitfall examples

## Pull Request Guidelines

- Keep PRs focused — one adapter, one fix, one improvement per PR
- Test your changes against a real project if possible
- Update the CHANGELOG.md with your changes
- Follow the existing file structure and naming conventions

## Questions?

Open an issue. I'll get back to you.
