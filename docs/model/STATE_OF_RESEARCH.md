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


### Internal demand-model issue identified

Before generalizing binary choice `{H,L}` to a multi-offer set `O_t`, the binary demand model itself requires clarification.

The current formulation contains:

- a deterministic conditional choice rule:
  `A_it* = argmax_{a in {H,L}} E[U_i(a,q) | M_it]`,
  with `H` chosen when `Delta U_i(M_it) > 0` and `L` otherwise;

- an aggregate formulation using conditional choice probabilities:
  `s_H = integral Pr(A_i = H | M) dF_t(M)`.

The canonical demand document does not explicitly identify the source of non-degenerate choice randomness conditional on `M`.

Therefore, the interpretation of `Pr(A_i = H | M)` must be clarified before a multi-offer probability vector is constructed.

No additional random-utility shock, logit rule, taste shock or new stochastic-choice parameter has been accepted.


### Next theoretical task

Construct the minimum mathematical generalization required to move from the binary demand model `{H,L}` to a choice over differentiated offers `a = (v,r)`, preserving the existing stochastic-memory mechanism and introducing no new structural parameters.

### Binary demand model: unresolved meaning of memory-conditioned beliefs

The binary demand model has been audited internally.

The current formulation is underdetermined rather than necessarily contradictory.

The written individual choice rule is deterministic conditional on the current memory state:

`A_it* = argmax_{a in {H,L}} E[U_i(a,q) | M_it]`.

The explicitly modeled consumer heterogeneity (`beta_i`, `lambda_i`, `C_i`, `delta_i`, initial conditions and stochastic encoding) primarily affects the formation and distribution of memory states.

However, the model does not formally specify:

- how `E[q_H - q_L | M]` is constructed;
- whether that conditional expectation is common across consumers or consumer-specific;
- whether the same state label `M` has common semantic content across individuals;
- the relation between the Information Bottleneck relevance variable `Y` and product quality `q`;
- the formal meaning of `F^H` and `F^L`;
- the joint population structure needed to interpret `Pr(A = H | M)` as a non-degenerate population conditional probability.

Therefore, exact overlap between high- and low-quality choosers at the same memory state cannot currently be derived from the written equations.

No additional taste heterogeneity, random-utility shock, logit/probit rule or stochastic-choice parameter has been accepted.

The next theoretical decision is to clarify the economic meaning of the memory state `M` and of the conditional belief `E[q | M]`.

### Binary demand model closure

The common-state interpretation of consumer memory has been adopted.

`M` is a common decision-relevant memory state. Individual heterogeneity operates through the process that generates and updates memory states, not through an additional stochastic choice mechanism conditional on the current state.

For the binary model, define:

`g(M) = E[q_H - q_L | M]`

and

`Delta U(M) = g(M) - (p_H - p_L)`.

The choice rule is:

- choose `H` if `Delta U(M) > 0`;
- choose `L` otherwise.

Thus:

`R_H = {M : Delta U(M) > 0}`

`R_L = {M : Delta U(M) <= 0}`

and aggregate demand is:

`s_H = F_t(R_H)`.

The conditional probability `Pr(A = H | M)` is therefore degenerate under the binary canonical model.

### Revised market-fragmentation interpretation

Semi-separation requires positive mass in both choice regions:

`0 < F_t(R_H) < 1`.

The previously written exact-overlap condition between H- and L-choosers is not compatible with deterministic choice conditional on a common memory state and will be removed from the formal model.

Quasi-pooling is provisionally understood as the absence of a separating gap in memory space around the differentiation threshold.

The exact regularity conditions required for quasi-pooling still need to be formally established.

The four original fragmentation mechanisms remain:
- memory affects choice;
- memory is persistent;
- the choice rule is nonlinear;
- updating costs are heterogeneous.
