# Empirical State

Snapshot: 2026-09-16

## Repository

Canonical technical repository:

`GuilBotler/market-sedimentation-coffee`

Default branch observed: `main`.

## Existing technical structure

The repository currently contains at least:
- `R/`
- `scripts/`
- `tests/`
- `data-raw/`
- `data/`
- `archive/`
- `docs/`
- `_targets.R`
- `_quarto.yml`
- `index.qmd`
- `README.md`
- `market-sedimentation-coffee.Rproj`

## Recent reproducibility/data work already present in Git history

Recent commits include work on:
- common 80–90 score windows;
- country-separated dashboard panels;
- validated V2 sample counts;
- separating reported process shares from title-inferred process shares;
- offline V2 rebuild from raw cache;
- missing-score sentinel handling;
- descriptive-statistics warnings;
- dashboard analytical-input tests.

These should be treated as existing technical work, not rediscovered from scratch.

## Empirical unit and current branch logic

The current experimentation branch should focus on producer/process experimentation and market selection rather than treating price regressions as the main research question.

Price/score regressions remain useful diagnostics and potentially publishable descriptive results, but they are not by themselves evidence of the producer mechanism.

## Required next data audit

Produce by country and year:
- process-information coverage;
- direct vs institutionally inferred process information;
- first appearance of process/innovation categories;
- relative price;
- relative score;
- reappearance;
- process diversity;
- process concentration;
- number of relevant lots/entries;
- whether a process category is integrated into the main competition or has a dedicated experimental category.

## Required provenance fields

Each derived process observation should be traceable to one of:
- `direct_lot`
- `event_rule`
- `institutional_regime`
- `constructed`
- `missing`

## Stop condition before causal regressions

Do not lock event windows or causal specifications until:
1. coverage is audited;
2. first appearances are checked manually for false novelty;
3. changes in publication practice are separated from changes in economic behavior;
4. candidate comparison groups are documented.
