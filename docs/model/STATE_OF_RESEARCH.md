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

### Next theoretical task

Construct the minimum mathematical generalization required to move from the binary demand model `{H,L}` to a choice over differentiated offers `a = (v,r)`, preserving the existing stochastic-memory mechanism and introducing no new structural parameters.
