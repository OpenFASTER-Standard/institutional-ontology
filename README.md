# Institutional Ontology

A controlled vocabulary of formal/administrative ("institutional," in Searle's
sense of institutional facts and status functions) concepts, built to give
independent schemas a shared, stable set of things to point at instead of
re-deriving equivalence between them pairwise.

The first concrete domain is German tax reporting: aligning
[MiKaDiv](https://internal-gitlab.default.svc.cluster.local/divizend/bulk-platform/platform)
(`mikadiv-vib`) and KaFE, whose Excel templates are generated from real XSD
schemas in `openfaster-spec` via `mapping.py`. That's the grounding, not the
ceiling — the ontology itself is meant to be domain-agnostic.

## Model

- **Formalism:** [SKOS](https://www.w3.org/TR/skos-reference/) (labels +
  loose relations), not OWL. No classes/axioms/reasoner — nothing here needs
  formal inference yet, and GraphSheet's Oxigraph endpoint doesn't run one
  even if it did. See the design conversation (linked from bulk-platform's
  `PROGRESS.md`) for the full reasoning.
- **Unit:** a `Concept` (SKOS's own term) — `prefLabel` per language, no
  `altLabel`/`broader`/`narrower` yet (deferred, see below).
- **IDs:** opaque, `IO:` prefix, 7-digit zero-padded, sequential
  (`IO:0000001`, ...), one global registry across all future domains, never
  recycled. Mirrors Gene Ontology's `GO:0008150` convention and the OBO
  Foundry's collision-avoidance registry pattern. Checked live against the
  OBO Foundry registry (`ontologies.yml`) — `IO` is not taken.
- **Cross-schema mapping:** hub-and-spoke. Domain schema fields map *into*
  Concepts via `exactMatch` only — no `closeMatch`/`broadMatch`/`narrowMatch`/
  `relatedMatch`. If a field doesn't cleanly match an existing Concept, that's
  a signal to research further (real XSD + handbook, not guessing), not a
  reason to hedge with a fuzzy relation. A field with no match simply has no
  mapping — that's real information too.
- **Concept-to-concept relationships:** deferred entirely for now (see
  `data/concepts.json`'s `mappings` per concept — that's schema→concept, not
  concept→concept). When they're designed, plain `broader`/`narrower` is
  explicitly ruled out as contentless ("Steuer-IdNr is more specific than
  TIN" says nothing actionable). The direction under consideration is a
  reified `Realization` relation carrying context + a validation rule
  (general concept, specific concept, context, e.g. `{country: "DE"}`,
  optional validation regex) — grounded in Wikidata's qualifier pattern
  (`P1001`/`P1793`) and the W3C N-ary Relations pattern, not invented from
  scratch. Not yet implemented.

## Files

- `data/concepts.json` — the actual ontology: verified Concepts with their
  `id`, `prefLabel`, and schema mappings.
- `data/field-inventory.json` — the working checklist this is built from:
  every real (non-linking-key) field across MiKaDiv's and KaFE's Excel
  templates, deduplicated within each schema (the same field reused across
  multiple sheets via `mapping.py`'s block helpers counts once), each tagged
  `pending` or `assigned` (+ which `conceptId` it resolved to). Regenerate
  the `pending` rows' source data by re-running the dedup against
  `platform`'s own `crates/adapter-{mikadiv-counterparty,kafe-counterparty}/data/template_metadata.json`
  — this repo doesn't vendor a copy, to avoid drift.

## Process (deliberately slow, by design)

Every field-to-concept match is verified against the real XSD (`openfaster-spec`)
and, where relevant, the official Kommunikationshandbücher — not inferred
from field names or descriptions alone. This is why `field-inventory.json`
exists as a separate, persistent checklist: at ~339 candidate fields, this
spans far more than one sitting.
