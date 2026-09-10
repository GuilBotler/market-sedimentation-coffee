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

## First pilot

The first event is Brazil 2024. Its public ACE page reports separate competition and auction tables for Washed + Honey, Natural and Experimental coffees, plus National Winner results. The pilot tests extraction, taxonomy, joins and measurement before scaling to the historical country-year panel.

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

Raw HTML snapshots are not committed. Collection is manual/on-demand in the pilot to avoid unnecessary requests and to keep source changes auditable. The dashboard is rebuilt on GitHub only when the repository changes.

## Pilot status

The Brazil 2024 extraction passes the parser, join and value-reconciliation checks. It contains 38 auction lots representing 35 competition entries, with 37 reported bids. Three winning entries were divided into A/B sale lots; the analytical table preserves both the sale-unit `lot_id` and the underlying `entry_id`.

The pilot is descriptive and covers one event. It validates the measurement architecture but does not yet establish persistence, causal premiums or the conditions for market sedimentation.
