# Market Sedimentation in Specialty Coffee

This repository studies a broad question:

> What causes market differentiation?

Cup of Excellence (COE) and National Winner (NW) auction data are used to examine when observable product differences become economically actionable, command persistent premiums, attract specialized buyers, and reproduce across auction cycles.

## Empirical boundary

Public COE data describe selected competition finalists. They can identify differentiation **within the specialty frontier**, but cannot by themselves identify the transition of the entire coffee market from a low-quality pooling equilibrium. Claims about that transition require a second comparison layer: COE versus NW near the qualification threshold and, later, conventional-market or producer-submission data.

## Research layers

1. **Specialty-market sedimentation** — process, variety, origin and sensory signals become persistent organizers of prices and buyer matching.
2. **Market-frontier transition** — COE/NW outcomes and conventional benchmarks locate the boundary between standardized and differentiated trade.
3. **Mechanism extensions** — buyer learning, repeated participation, education infrastructure and information shocks are introduced only after the descriptive facts are established.

The international coffee price is a benchmark and premium denominator, not the primary instrumental variable for auction prices.

## Repository structure

```text
R/                         Collection, harmonization, metrics and models
data-raw/source_registry.csv  Auditable list of source pages
data/processed/            Generated analytical data
docs/                      Empirical strategy and data dictionary
index.qmd                  Quarto dashboard
_targets.R                 Reproducible pipeline
.github/workflows/         Dashboard publication on push
```

## Current expansion

The validated pilot began with Brazil 2024. The source registry now covers 66 candidate country–year events from 2020 through 2025 across Brazil, Colombia, Costa Rica, Ecuador, El Salvador, Ethiopia, Guatemala, Honduras, Indonesia, Mexico, Nicaragua, Peru, Taiwan and Thailand. Each event is admitted only if its published competition and auction tables pass the same validation contract. Failed pages remain visible in `source_audit.csv` with an exclusion reason.

The dashboard also retrieves monthly World Bank prices for Arabica, Robusta and cocoa. Wine is represented separately by the U.S. winery producer price index from BLS/FRED because wine has no homogeneous global spot price comparable to those commodities.

## Run locally

Install R, Quarto and the packages listed in `install.R`, then run:

```r
source("install.R")
targets::tar_make()
```

Render the dashboard:

```bash
quarto render
```

Raw HTML snapshots are not committed. Collection runs on demand when the source registry or parser changes, and every attempted event is audited. The dashboard is rebuilt on GitHub when the repository changes.

## Validated baseline

The Brazil 2024 extraction passes the parser, join and value-reconciliation checks. It contains 38 auction lots representing 35 competition entries, with 37 reported bids. Three winning entries were divided into A/B sale lots; the analytical table preserves both the sale-unit `lot_id` and the underlying `entry_id`.

The initial five-event baseline contains 186 auction lots representing 175 competition entries across Brazil, Costa Rica, El Salvador and Ethiopia in 2023–2024. The expanded refresh adds every additional event that satisfies the contract; sample size and exclusions are reported by the dashboard rather than assumed in advance.

The evidence remains descriptive. More years make persistence measurable, but do not by themselves establish causal premiums or the sufficient conditions for market sedimentation.
