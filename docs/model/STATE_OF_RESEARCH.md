# State of Research

Last migration snapshot: 2026-09-16

## Central research question

How do persistent memory, heterogeneous information costs and verifiable signals transform process differences into durable demand segments, and when does that segmentation generate sufficient incentives for producer upgrading?

## Core object

The project studies **market sedimentation**: the process by which productive differences that are initially difficult to observe become recognized, priced and reproduced over time by producers, buyers and consumers.

The object is not any single case such as:
- the 1999 Colombian earthquake;
- equipment-loan business models;
- the internet;
- a Cup of Excellence price premium.

These are applications, mechanisms, institutions or empirical settings subordinate to the central question.

## Current causal architecture

1. Production processes generate heterogeneous attributes.
2. Information is incomplete and costly.
3. Consumers and buyers form decision representations under persistent/stochastic memory and heterogeneous information costs.
4. Institutions can transform process attributes into credible, learnable signals.
5. Recognition and repeated market rewards change expected returns to producer upgrading/experimentation.
6. Producer responses feed back into the distribution of observable product/process types.
7. Repeated learning, transactions and producer response can sediment durable market segments.

## Demand side

The stochastic-memory model provides the demand microfoundation.

Key ideas already developed:
- heterogeneous consumers do not perceive the same product identically;
- memory and information acquisition affect the decision-relevant representation of quality;
- consumers choose what is best for them conditional on their learned representation and local optimum;
- low information does **not** mean an intrinsic preference for inferior quality;
- information infrastructure can reduce the cost of recognizing quality differences.

## Supply side

The producer chooses whether differentiated production / process experimentation is worthwhile given:
- expected market reward;
- costs of adoption / experimentation / verification;
- production constraints and shocks;
- uncertainty about whether the market can recognize the resulting difference.

The supply extension must remain parsimonious. Do not create a new parameter for every historical case.

## Institutional bridge

Certification, traceability, training, auctions, evaluators, reputation, specialized buyers and market channels can make quality/process differences recognizable and credible.

The institution does not automatically create quality. It changes the informational environment in which quality can be identified, trusted and rewarded.

## Current empirical emphasis

The active empirical branch studies **experimentation and producer response**, not merely auction price premia.

The observable sequence currently prioritized is:

**appearance → remuneration → reproduction**

The empirical question is whether experimentally differentiated processes that receive visible recognition/reward subsequently become more frequently reproduced among selected lots and/or spread across the relevant specialty market.

## Historical shocks

Shocks remain useful as:
- motivating cases;
- sources of exogenous or quasi-exogenous variation where identification is defensible;
- comparative applications.

The 1999 Colombia earthquake is not the thesis by itself.

## What is not yet closed

- exact econometric specification for the experimentation branch;
- final operational definition of reproduction/diffusion;
- final event windows;
- external specialty-market data used to validate expansion beyond COE;
- which shocks have sufficiently good timing/exposure data for causal designs;
- exact mapping between the theoretical producer decision and available empirical proxies.

## Demand–supply interface audit

The interface between the canonical demand model and the coevolutionary producer mechanism has been audited against both canonical theoretical documents.

### Established interface

- `M_it` is the individual stochastic consumer memory state.
- `F_t(M)` is the distribution of memory states across consumers.
- The coevolutionary mechanism explicitly delegates consumer choice to the previously developed stochastic-memory preference model.
- Aggregate demand in both formulations is obtained by integrating memory-dependent choice probabilities over `F_t(M)`.

### Still requiring formal compatibility

- the individual memory transition `K_i / Phi_i` and the aggregate transition kernel `T`;
- the generalization from binary demand `s_H` to multi-offer demand `D_t(a)`;
- the mapping from productive attributes `x = h(v,r,omega)` to consumer-observed information `X_t`;
- the role of individual observability `q_iat = Q(x_a, M_it)` in the consumer choice rule;
- the derivation of multi-offer choice probabilities over the offer set `O_t`;
- the mapping from producer distribution `n_t(a)` to the effective offer set `O_t`.

### Still open on the producer side

- the behavioral closure of the transition kernel `R`;
- the candidate probabilistic adoption rule `R^A`;
- parameter `eta` in the candidate adoption rule;
- price determination and competition;
- producer expectation formation;
- capacity constraints and fixed costs;
- entry and exit;
- single main productive combination versus portfolio representation.

### Notation clarification

`Omega_j(d)` is exclusively a supply-side object in the coevolutionary model, where it denotes expected economic gain conditional on discovery. It has no counterpart in the canonical demand model.

### Binary demand model: current closure

The binary demand model has been re-examined to distinguish three objects that had previously been conflated:

1. the persistent memory / representation state;
2. the stochastic realization of recognition or differentiation conditional on that state;
3. the realized product choice.

The current interpretation is:

`information → memory / representation → stochastic recognition → realized choice`.

`M_it` is a persistent decision-relevant memory / representation state.

The local optima already present in the stochastic-memory model are interpreted as local optima of memory / representation. They are not fixed preferences for particular products and are not fixed realized actions.

Consumers may remain near a local memory optimum for substantial periods while their realized choices vary.

### Stochastic recognition and choice

Preference is not treated as an exogenous primitive taste for high or low quality.

The consumer's effective evaluation of a product depends on the capacity to recognize or differentiate relevant attributes.

That recognition process is stochastic conditional on memory.

Therefore:

- two consumers with the same or similar memory state may make different realized choices;
- the same consumer may make slightly different choices at different times while remaining at the same memory state / local optimum;
- such choice variation does not by itself imply movement between memory states or market segments.

Hence the conditional choice probability

`Pr(A = a | M)`

may be genuinely non-degenerate.

Its stochasticity must be derived from the recognition / differentiation mechanism conditional on memory, not from an ad hoc taste shock, logit/probit error or unrelated random-utility term.

No specific parametric distribution for recognition has yet been accepted.

### Local persistence and transitions

A consumer can remain close to a local memory / representation optimum while generating stochastic realized choices.

A transition between local optima is a more persistent change:

`M_i^(1)* → M_i^(2)*`.

Such a transition changes the consumer's persistent representation / capacity to differentiate and therefore changes the distribution of subsequent choices.

Thus:

- stochastic variation within a local optimum is not itself sedimentation or desedimentation;
- migration between local optima represents a change in the persistent cognitive / informational state;
- sedimentation does not imply immobility.

### Implications for aggregate demand

Aggregate demand continues to depend on the distribution of memory states:

`F_t(M)`,

but `F_t(M)` alone is not sufficient to determine realized demand unless the conditional choice rule is also specified.

For the binary model:

`s_H = integral Pr(A = H | M) dF_t(M)`.

The previously adopted deterministic reduction

`s_H = F_t(R_H)`

is no longer canonical.

The conditional probability `Pr(A = H | M)` must instead be derived from the stochastic recognition mechanism.

### Implications for semi-separation and quasi-pooling

The previous deterministic closure and the associated rejection of overlap are withdrawn.

Under stochastic recognition:

- persistent memory states can generate overlapping realized choices;
- consumers in the same or similar memory states may make different realized choices;
- persistent market segmentation must therefore be distinguished from period-by-period choice realization.

The exact mathematical definitions of semi-separation and quasi-pooling must now be re-derived under this stochastic-recognition interpretation.

No final overlap condition has yet been accepted.

### Current interpretation of market sedimentation

Market sedimentation is provisionally characterized by persistence of multiple local memory / representation states in the population, together with persistent differences in the choice distributions induced by those states.

Consumers may:

- vary their realized choices while remaining within one local optimum;
- remain for long periods near one local optimum;
- occasionally transition from one local optimum to another.

Therefore, sedimentation is a property of persistent distributions of representations and induced choice probabilities, not a requirement that individuals repeatedly choose the same product.

### Next theoretical task

Before generalizing the binary model to multiple offers, formally specify the minimal stochastic-recognition bridge:

`M → recognition / differentiation → Pr(A | M)`.

The derivation must:

- preserve the existing stochastic-memory and local-optimum mechanism;
- introduce no primitive taste heterogeneity;
- introduce no ad hoc random-utility shock;
- avoid choosing a parametric distribution before it is theoretically justified;
- clarify how recognition of product differences enters the existing utility / choice formulation.

Only after this bridge is closed should the model return to the generalization from `{H,L}` to the multi-offer set `O_t`.
