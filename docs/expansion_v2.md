# ACE expansion V2

This package is installed beside V1. It does not overwrite the existing pipeline.

Copy `R/expansion/*` to `R/expansion_v2/`, copy `scripts/run_expansion_v2.R`
to `scripts/`, and copy the test file to `tests/testthat/`.

Run from the repository root:

```r
source("scripts/run_expansion_v2.R")
```

V2 changes:

- Every page has a stable `event_id`; distinct events in the same country-year
  cannot eliminate one another during deduplication.
- Historical process is inferred from the event title only for explicitly named
  Natural or Pulped Natural events. No country-wide process is assumed.
- Auction tables are recognized from bid, price, buyer or value columns and no
  longer require `score`.
- Authoritative raw and processed objects are stored as RDS; CSVs are exports.
- Each downloaded event is cached separately in `data/raw/events_v2`, so an
  interrupted run resumes without downloading completed pages again.
- Event-level process shares are preserved before country-year aggregation.

Do not replace the main `_targets.R` until the V2 audit is reviewed.
