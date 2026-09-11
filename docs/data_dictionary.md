# Data dictionary and validation contract

## Core analytical table: `auction_lots`

| Variable | Type | Definition |
|---|---:|---|
| `lot_id` | character | Stable identifier for the auction sale unit |
| `entry_id` | character | Stable identifier for the underlying competition entry; shared by split lots such as 1A/1B |
| `split_lot` | logical | Whether the auction lot is an A/B split of one competition entry |
| `country` | character | Producing country |
| `year` | integer | Competition/auction year |
| `program` | character | `COE`, `NW`, or explicit pilot program |
| `process_group` | character | Page section such as Natural, Experimental or Washed + Honey |
| `rank` | character | Published rank; retained as text because values may contain A/B or symbols |
| `entry_rank` | character | Normalized rank used to identify the underlying entry; A/B suffix and symbols removed |
| `score` | double | Published jury score |
| `farm` | character | Farm or washing-station name |
| `producer` | character | Farmer or representative, when published |
| `process` | character | Published process text, preserved without replacement |
| `process_family` | character | Transparent analytical taxonomy: Washed, Natural, Honey/pulped natural, Experimental, grouped Natural/Honey, or Not reported |
| `process_classification_source` | character | Whether the taxonomy uses the reported process, the ACE table heading, or no published classification |
| `variety` | character | Published variety text; multi-variety lots remain explicit |
| `region` | character | Published region |
| `weight_lb` | double | Auction lot weight in pounds |
| `final_bid_usd_lb` | double | Final bid in USD per pound |
| `total_value_usd` | double | Published or validated total lot value |
| `buyer` | character | Published company/buying-group string |
| `auction_result_status` | character | `reported`, `not_reported`, or `partial`; does not infer that an unreported result is an unsold lot |
| `source_url` | character | Exact ACE page used |

## Provenance fields added during scaling

Every extracted record should also retain `accessed_at`, table number, original column names, raw numeric strings and a source-page content hash. Normalized process, variety, farm and buyer fields must never replace the raw strings.

## Hard validation rules

- country, year, program, rank, score and source URL cannot be missing;
- score must fall within a plausible published range of 0–100;
- final bid and weight must be strictly positive when auction results exist;
- `abs(total_value - weight * final_bid)` must be within a documented rounding tolerance;
- lot keys must be unique within event/program/process group;
- competition-to-auction joins must be one-to-one or explicitly reviewed;
- unmatched lots and duplicate keys must stop the pipeline, not be silently dropped;
- all locale-dependent number parsing must be tested with both comma-decimal and dot-decimal examples.

## Selection flags

The analytical table will distinguish:

- competition finalist observed;
- auction result observed;
- sold/unsold/missing outcome;
- COE versus NW;
- duplicated split lots such as `1A` and `1B`;
- manually reviewed joins.

This prevents a missing bid from being coded automatically as zero.

## External benchmark table

`commodity_prices.csv` stores a long monthly table with `date`, `year`, `month`, `series`, `value`, `unit`, `market_scope`, and `source_url`.

- Arabica, Robusta and cocoa are World Bank Pink Sheet prices in USD/kg.
- Wine is the BLS/FRED U.S. winery producer price index (December 1998 = 100), not a global commodity spot price.
- The dashboard rebases all four series to a common 2020 average only for visual comparison. Raw units remain available and are never treated as interchangeable price levels.

## Source audit table

`source_audit.csv` records every registered country–year, its inclusion status, lot and entry counts, reported bids, elapsed collection time, and the exact failure message when an event does not satisfy the contract.
