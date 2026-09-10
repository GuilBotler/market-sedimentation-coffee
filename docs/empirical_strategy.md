# Empirical strategy

## Research question

**What causes market differentiation?**

The empirical task is to determine when heterogeneity becomes economically actionable and when the resulting segments persist. Auction data do not observe individual consumer memory directly. They reveal its market-level consequences through attribute premiums, repeated buyer choices, new product categories and the persistence of those patterns.

## Unit of observation and sample

The core unit is a lot offered in a country-year-program auction. `program` separates Cup of Excellence (COE) and National Winner (NW). The public historical panel will be assembled event by event from ACE pages. The Brazil 2024 event is the extraction and validation pilot; expansion occurs only after table classification and lot joins are reliable.

The selected sample must never be described as the whole coffee market. COE and NW lots have already passed multiple quality screens.

## Outcomes

Primary outcomes:

- log final bid in USD/lb;
- log relative premium: `log(final_bid_usd_lb / benchmark_usd_lb)`;
- total lot value in USD;
- probability that a process, variety or producer appears again;
- buyer–attribute matching and buyer specialization.

The conventional coffee series is a benchmark/control and a relative-premium denominator. It is not the main instrument because its exclusion restriction for COE auction prices is not credible.

## Observable implications of sedimentation

Sedimentation is not synonymous with a rising average price. It requires several observable components.

1. **Breadth:** more than one attribute-defined segment has positive mass. Measure effective variety/process counts using the exponential of Shannon entropy, alongside raw shares.
2. **Recognition:** process, variety, origin or description explains auction value beyond score, rank, lot size and auction conditions. Measure incremental partial R-squared and estimated premiums.
3. **Separation:** attribute-defined groups occupy persistently different regions of the conditional price distribution. Measure between-group residual variance and distribution overlap.
4. **Matching:** repeat buyers systematically choose particular attributes rather than purchasing randomly from the available set. Measure buyer-level location quotients, entropy and buyer-by-attribute interactions.
5. **Reproduction:** categories, premiums and buyer matches recur across years. Measure survival, re-entry, Jaccard similarity, coefficient stability and transition matrices.
6. **Innovation:** a new process or variety moves from first appearance to repeated positive market share and economically viable value. A first appearance alone is experimentation, not sedimentation.

No single index will be treated as proof. A transparent scorecard will report the components separately before any composite index is considered.

## Baseline price model

For lot `i` in auction `a`:

\[
\log(P_{ia}/B_a) = f(Score_{ia}) + \beta X_{ia} + \gamma \log(Weight_{ia})
+ \alpha_a + \varepsilon_{ia},
\]

where `B_a` is the international benchmark near the auction date, `f(score)` is initially a restricted spline, `X` contains process, variety and other observable signals, and `alpha_a` is an auction fixed effect. Standard errors will be clustered at the auction level once the number of clusters is adequate; with few auctions, randomization or wild-cluster inference will be reported.

Model sequence:

1. score, rank and lot size;
2. add process and variety;
3. add region/origin and sensory descriptors when consistently available;
4. add repeat-producer and buyer-market measures;
5. interact attributes with calendar time and market maturity.

The increment in fit and out-of-sample prediction from each block measures whether the market prices increasingly detailed distinctions. Coefficients remain descriptive unless a separate identification design is credible.

## Semi-pooling at the specialty boundary

Public data permit two progressively stronger tests.

### COE versus NW comparison

Compare lots around the score threshold while controlling flexibly for score and event. This estimates the discontinuity associated with category assignment only if near-threshold lots are observed on both sides, the assignment rule is stable and manipulation/selection tests are satisfactory. Separate auction venues and missing unsuccessful lots are explicit threats.

### Conventional-market comparison

Normalize auction prices by an international benchmark and later add farmgate or non-COE specialty transactions where available. This locates the specialty frontier but does not by itself establish a causal transition out of low-quality pooling.

## Innovation analysis

A process label is canonicalized but the original text is retained. For each country and globally, define:

- first observed appearance;
- adoption share among listed lots;
- score-conditional price premium;
- number and concentration of buyers;
- persistence for the next one, two and three observed auctions;
- diffusion to other origins.

An innovation is classified as market-sedimented only when it has positive repeated supply, a non-transitory buyer base and value sufficient to survive after conditioning on score and scarcity. The precise threshold will be pre-specified after the pilot reveals sample sizes.

## Buyer learning and memory-dependent demand

Auction data cannot identify individual memory states. The defensible bridge to the model is indirect:

- repeated buyer participation provides a revealed history of exposure;
- increasing attribute specificity in subsequent purchases is consistent with learning;
- heterogeneous buyer trajectories are consistent with different local optima;
- persistence of distinct trajectories is consistent with sedimented segmentation.

These patterns do not uniquely prove the memory mechanism. Direct identification requires buyer interviews, click/bid histories or an experiment. The dashboard must distinguish evidence consistent with the mechanism from causal evidence for it.

## Later identification modules

- A threshold design around COE/NW status, conditional on adequate support and stable rules.
- Event studies around information or education expansions, with pre-trends and matched controls.
- Text trends predicting later premiums, evaluated out of sample.
- Wine as a benchmark/placebo for general premiumization or connoisseurship trends, not as the main instrument.

These modules enter only after the historical panel and measurement layer are validated.

## Validation and falsification

The differentiation account is weakened if:

- attribute breadth rises but conditional premiums and buyer matching do not;
- apparent innovation premiums disappear after controlling for score, scarcity and lot size;
- categories appear once and do not recur;
- buyer specialization is no stronger than a permutation benchmark conditional on availability;
- results depend on one country, one record price or inconsistent table formats;
- out-of-sample models do not improve when detailed attributes are added.

