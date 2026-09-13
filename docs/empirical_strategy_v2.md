# Empirical strategy V2

## Research mechanism

The project treats market sedimentation as a dynamic process with two margins.
First, a producer or producer organization invests enough in quality to enter a
selective competition and auction. Second, conditional on participation, the
producer specializes through process, variety, or their combination. External
shocks may affect entry, while repeated shocks and past specialty premiums may
reinforce specialization.

This mechanism generates three distinct empirical objects:

1. **Entry into the observed differentiated market:** competition entries and
   auction participation relative to national coffee production.
2. **Specialization within that market:** process and variety composition among
   unique competition entries.
3. **Market validation:** prices, lots, weights, and professional buyers in the
   auction stage.

ACE finalists are a selected, high-quality population. Selection is part of the
economic object, but results cannot be generalized to all farms or all coffee
produced in a country.

## Units and measurement

- A **competition entry** represents the coffee submitted and classified in the
  competition. It is the unit for producer-side process and variety choices.
- An **auction lot** is the sale unit. One entry may become multiple lots (for
  example 1A and 1B). Prices, weights, values, and buyers belong to this level.
- **Country-year-program** is the principal aggregation for descriptive and
  shock analysis. COE is the main group; National Winners (NW) is a within-event
  comparison group where available.
- Entry-lot matching is required only when assigning buyer or price outcomes to
  entry attributes. Unmatched observations remain usable in their own panels.
- Missing values remain missing. In particular, an unreported process or buyer
  is never coded as zero participation.

## Current data architecture and verified V2 coverage

The repository preserves four linked but analytically separate layers:

| Layer | Unit | Main information |
|---|---|---|
| Competition | entry | process, variety, score, rank, producer, region |
| Auction | lot | price, weight, total value, professional buyer |
| Integrated | entry-lot | attribute premiums and buyer-attribute matching |
| External | country-year/month | output, trade, commodity prices, climate and shocks |

The local V2 audit recovered 213 of 214 registered source pages; Thailand 2022
returned HTTP 404. The competition panel has 5,446 unique entries in 204 events
and the auction panel has 6,373 unique lots in 213 events. Coverage spans 17
origins and 1999-2025. No duplicate entry IDs, duplicate lot IDs, or process-share
sums different from one were found in the reported audit.

Process measurement is heterogeneous and must not be pooled blindly:

- 2,214 entries contain a row-level reported process;
- 599 entries belong to explicitly named Brazilian Natural or Pulped Natural
  events and receive an event-restriction indicator;
- 2,633 entries have no reported process.

Row-level process coverage is effectively complete from 2018 onward except for
the missing 2020 competition layer and isolated missing values. Historical
event-title classifications describe institutional eligibility, not an
individual producer choice, and therefore form a separate historical analysis.

## Descriptive analysis before estimation

For each country-year-program, report:

- event, entry, lot, and buyer counts;
- coverage rates for process, variety, score, price, and buyer;
- process shares calculated from unique entries;
- variety shares and process-variety combinations;
- Shannon entropy and effective number of process categories;
- mean, sample variance, median, minimum, and maximum of scores and prices;
- total auction weight and value, weighted price, buyer concentration, and
  buyer recurrence;
- results separately for COE and NW.

Entry expansion should be normalized by national production:

`entry_rate_ct = ACE entries_ct / national production_ct`.

Without this denominator, more entries could merely reflect a larger crop or a
change in the capacity and rules of the competition.

## Specialty premium

For auction lot i in country c and year t:

`premium_ict = log(auction price_ict) - log(commercial benchmark_t)`.

Complementary measures are the price ratio and a residual premium after
controlling for score, rank, lot size, process, variety, program, and event.
Arabica and Robusta benchmarks should be chosen according to the origin and
species represented. The premium measures the distance from commercial coffee;
it is not itself an exogenous shock.

## Shock map

The shock panel should record event date, exposure window, spatial reach,
intensity, source, expected economic channel, and whether treatment timing was
specified before inspecting auction outcomes. Candidate shocks include:

- rainfall, drought, temperature, frost, and hurricanes;
- coffee leaf rust and other phytosanitary events;
- earthquakes and infrastructure destruction;
- international Arabica and Robusta price shocks;
- exchange-rate, freight, conflict, and trade-policy shocks;
- institutional entry of ACE, certifications, training programs, competitions,
  and information infrastructure.

Weather and geological shocks are the most credible exogenous candidates.
International prices are external to an individual producer but may be
endogenous to production in large origins such as Brazil. Institutional and
information events are likely endogenous and require pre-trend analysis and
careful comparison groups.

## Estimation sequence

The equations are initially estimated separately because process is chosen
before the auction. A simultaneous system is not justified until a defensible
contemporaneous feedback channel and instruments are established.

### Extensive margin: entry

`entry_rate_ct = country FE + year FE + beta shock_ct + gamma controls_ct + error_ct`.

Outcomes include number of competition entries, entry rate per national output,
number of events, and auction weight. Competition capacity and rule changes
must be controlled or explicitly treated as measurement changes.

### Intensive margin: specialization

`process_share_pct = country-process FE + year FE + beta_p shock_ct + gamma controls_ct + error_pct`.

Because process shares are compositional, estimation should use a fractional or
compositional model, or omit an explicit reference category. Event studies test
anticipation, immediate response, and persistence.

### Market validation and reinforcement

`log(price_ict) = event FE + process + variety + flexible score + log(weight) + error_ict`.

The dynamic reinforcement hypothesis adds lagged specialty premium and lagged
buyer demand to the process equation. It predicts that an initial shock expands
entry and later shocks, conditional on prior market validation, produce greater
specialization. This is a distributed-lag mechanism, not a contemporaneous
simultaneous equation.

## Complementary supply and demand data

Global A/AA/AAA quantities cannot be constructed as a coherent series because
these labels are not a uniform international quality standard. The defensible
complements are national coffee production, Arabica/Robusta output and exports,
export unit values, certified volumes where consistently defined, auction
weight, buyer counts, and entry rates.

Variety innovation can be represented by documented release year, first auction
appearance, adoption share, cross-origin diffusion, and persistence. The World
Coffee Research catalog is a useful registry but not a complete annual census
of all national releases.

Panama Geisha is treated as a diffusion and demonstration case. Best of Panama
auctions permit measurement before and after the 2004 market breakthrough,
followed by diffusion across countries and interaction with Natural, Washed,
and Experimental processes. The 2004 event is economically important but not
automatically exogenous.

## Identification limits and falsification

Evidence for the proposed mechanism weakens if shocks do not precede entry,
pre-trends differ systematically, process changes reflect only missing-data
composition, premiums disappear after basic quality controls, categories fail
to persist, or estimates depend on one country or record lot. Buyer absence
before 2018 is predominantly missing reporting and cannot be interpreted as
zero demand.

The causal analysis begins only after producing a country-year coverage matrix,
freezing the process taxonomy, documenting competition rule changes, attaching
external denominators, and preregistering each shock window and comparison set.
