# Multi-AI Handoff Protocol

## At the start of any serious session

Give the AI:

1. `STATE_OF_RESEARCH.md`
2. `DECISIONS.md`
3. relevant task-specific canonical documents
4. a precise task

Then include:

> Treat DECISIONS.md as authoritative. Do not reopen accepted decisions unless I explicitly ask. If you detect a contradiction, report it instead of silently resolving it. Any new mechanism, parameter, interpretation or empirical definition must be labeled PROPOSAL — NOT YET ACCEPTED.

## During a session

Maintain three categories:

### VERIFIED
Directly supported by canonical document, repository output or checked external source.

### INFERENCE
Reasonable interpretation that follows from verified material but is not explicitly stated.

### PROPOSAL — NOT YET ACCEPTED
New theory, variable, specification, interpretation or organizational change.

Never mix the three.

## At the end of a session

Ask the AI to return only:

### Decisions proposed for acceptance
Short items.

### Research-state changes
What changed relative to `STATE_OF_RESEARCH.md`.

### Repository changes required
File + purpose, not speculative code unless requested.

### Open questions
Unresolved only.

The researcher decides what is accepted.

## Updating canonical state

1. Update Git/code first when the decision concerns data/code.
2. Update `DECISIONS.md` when a conceptual/empirical decision is accepted.
3. Update `STATE_OF_RESEARCH.md`.
4. Commit both changes with an informative Git message.
5. Re-upload/update the canonical files in Claude/NotebookLM if needed.

This prevents chat history from becoming the only memory.

## Symbol discipline

Before integrating equations from different project documents:

1. Check `SYMBOL_DICTIONARY.md`.
2. Do not identify two objects only because they use the same symbol.
3. Do not rename or merge economic objects silently.
4. Any unresolved notation conflict must be reported before formal derivation.

## Audit correction rule

When a secondary AI audit contradicts an interpretation made by another AI:

1. return to the canonical source;
2. preserve the source-supported interpretation;
3. record the rejected interpretation explicitly if it could contaminate later work;
4. do not propagate the rejected interpretation into `STATE_OF_RESEARCH.md` or `DECISIONS.md`.
