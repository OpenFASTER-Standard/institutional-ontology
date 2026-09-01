# Institutional Ontology

Part of [OpenFASTER](https://openfaster.org), alongside
[`spec`](https://github.com/OpenFASTER-Standard/spec) and
[`riptide`](https://github.com/OpenFASTER-Standard/riptide).

A controlled vocabulary of formal/administrative ("institutional," in Searle's
sense of institutional facts and status functions) concepts, built to give
independent schemas a shared, stable set of things to point at instead of
re-deriving equivalence between them pairwise.

The first concrete domain is German tax reporting: aligning MiKaDiv
(`mikadiv-vib`) and KaFE, whose Excel templates are generated from real XSD
schemas in [`spec`](https://github.com/OpenFASTER-Standard/spec) via
`mapping.py`. That's the grounding, not the ceiling — the ontology itself is
meant to be domain-agnostic.

Licensed [CC BY 4.0](LICENSE), matching the rest of OpenFASTER.

## Model

Built on real OBO Foundry practice (ROBOT + BFO + IAO + SSSOM), **without**
registering as an OBO Foundry member ontology — own IRI namespace
(`https://purl.openfaster.org/io/`), tooling/conventions only.
**`purl.openfaster.org` is live**, self-hosted (not w3id.org — kept as our
own domain; see
[`OpenFASTER-Standard/purl`](https://github.com/OpenFASTER-Standard/purl)
for the redirect service itself, one dedicated repo/Vercel deployment for
the whole org, not nested in this one). Whole-file redirects are
version-pinned to a tagged release (never `main`); term redirects
(`/io/IO_0000001`) go to a self-hosted
[WIDOCO](https://github.com/dgarijo/Widoco)-generated docs page. Every choice
below is grounded in how real, currently-maintained ontologies actually do
this, not invented for this project.

- **Formalism:** OWL, not SKOS. Built on
  [BFO](https://basic-formal-ontology.org/) (Basic Formal Ontology) as the
  upper ontology and [IAO](https://github.com/information-artifact-ontology/IAO)
  (Information Artifact Ontology) for document/identifier/information-content
  classes — both imported as small, pinned subsets (`robot extract`,
  `--method BOT`), not copied wholesale. Real precedent for this exact
  pattern in a non-biological domain: the
  [Informed Consent Ontology](https://github.com/ICO-ontology/ICO), a
  registered OBO Foundry ontology modeling consent forms/governing policies
  on the same BFO-backbone-plus-selective-import pattern.
- **Unit:** an `owl:Class`, one per concept (e.g. `IO:0000001`), subclassed
  under the closest-fitting imported BFO/IAO category — currently
  `IAO:0000030` (information content entity) for both existing concepts;
  expect more specific subclassing (e.g. under `BFO:0000023` Role for
  institutional-status concepts like "creditor" or "tax resident") as the
  ontology grows.
- **Labels:** exactly one `rdfs:label` per class (OBO Foundry Principle 12 —
  more than one breaks `robot report`'s `multiple_labels` check and OBO-format
  translation). Additional-language labels go on `IAO:0000118` ("alternative
  label"), not a second `rdfs:label`.
- **Definitions vs. evidence — three distinct IAO annotation properties, not
  one:**
  - `IAO:0000115` ("definition") — the actual short Aristotelian definition.
  - `IAO:0000116` ("editor note") — the long researched justification prose
    (XSD quotes, handbook citations, reasoning for why this is `exactMatch`
    not two separate concepts, etc.). Confirmed real, idiomatic usage for
    exactly this in IAO's own release file.
  - `IAO:0000119` ("definition source") — where the definition/mapping
    actually came from (which XSD element, which handbook section).
- **IDs:** opaque, `IO:` prefix, 7-digit zero-padded, sequential
  (`IO:0000001`, ...), one global registry across all future domains, never
  recycled — mirrors Gene Ontology's `GO:0008150` convention. Checked live
  against the OBO Foundry registry — `IO` is not taken. Solo-curator project
  for now, so no formal `idranges.owl` file yet (real ODK convention for
  preventing curator ID collisions) — add one if/when a second curator joins.
  Current highest ID in use: check `src/ontology/institutional-ontology-edit.ofn`.
- **Cross-schema mapping:**
  [SSSOM](https://mapping-commons.github.io/sssom/) (Simple Standard for
  Sharing Ontology Mappings) — `mappings/*.sssom.tsv`, a real TSV-plus-
  commented-YAML-header format, `predicate_id` populated with real SKOS
  predicates (`skos:exactMatch`; confirmed this is genuinely how SSSOM
  expects it, not a hack). One row per (concept, external field) pair — the
  same concept can and does have multiple mapping rows (e.g. `IO:0000001`
  maps to three separate XSD elements: MiKaDiv's `IndividualPersonType.
  FirstName` and KaFE's `NatP_Struct.Vorname` and `Ansprechperson_Struct.
  Vorname`, since KaFE defines the same real-world field on two different
  structs). No `closeMatch`/`broadMatch`/`narrowMatch`/`relatedMatch` — if a
  field doesn't cleanly match an existing concept, that's a signal to
  research further, not a reason to hedge with a fuzzy relation.
- **Concept-to-concept relationships** (e.g. "Steuer-IdNr is the German
  realization of the general TIN concept"): not yet built. Plain
  `broader`/`narrower` is explicitly ruled out as contentless. In real OWL
  this doesn't need a bespoke reified relation at all — it's ordinary
  subsumption with a class restriction (`SteuerIdNr ⊑ TIN ⊓
  (appliesInJurisdiction value Germany)`), reasoner-checkable. No existing
  ontology was found using exactly this pattern — first real test of it is
  future work, not yet a concept in this repo.

## Files

- `src/ontology/institutional-ontology-edit.ofn` — the hand-authored source
  (OWL Functional Syntax — diff-friendly per OBO community convention;
  RDF/XML and Turtle are explicitly avoided for hand-editing). This is what
  a curator actually edits.
- `src/ontology/catalog-v001.xml` — XML catalog redirecting the BFO/IAO
  import IRIs to the local pinned modules below (standard OWL/Protégé
  mechanism — avoids needing network access to build, and pins exact
  versions).
- `src/ontology/imports/{bfo,iao}_import.owl` — pinned BFO/IAO term subsets
  (`scripts/refresh-imports.sh` regenerates these via `robot extract`).
- `mappings/*.sssom.tsv` — SSSOM mapping sets (schema field → concept).
- `scripts/build.sh` — merges the editors' file + imports into
  `build/institutional-ontology.owl` (gitignored scratch — the QC report and
  reasoner output live here too), runs `robot report` (fails on any ERROR)
  and `robot reason` (ELK, consistency check), then copies the result to
  `./institutional-ontology.owl` at the repo root. That root copy **is**
  committed — real ODK/OBO convention is to commit the actual release
  product, not just the source, so a git tag gives
  [`purl.openfaster.org`](https://purl.openfaster.org) a stable
  `raw.githubusercontent.com` URL to redirect to.
- `scripts/refresh-imports.sh` — regenerates the pinned BFO/IAO import
  modules when a newly-referenced term needs pulling in.
- `data/field-inventory.json` — the working checklist this is built from:
  every real (non-linking-key) field across MiKaDiv's and KaFE's Excel
  templates, deduplicated within each schema, each tagged `pending` or
  `assigned` (+ which concept ID it resolved to). This is our own project
  tracking, not part of the ontology's canonical format. Tracked at
  Excel-template-column granularity (multiple columns can point at the same
  real XSD element reused across sheets — e.g. KaFE's `NatP_Struct.Vorname`
  backs three different template columns); `mappings/*.sssom.tsv` is
  correctly deduplicated at the XSD-element level instead, since that's the
  real external resource being mapped, not each of its template aliases.

## Adding a concept

**No GUI ontology editor, ever — hand-edit `institutional-ontology-edit.ofn`
directly in a plain text editor, and use `scripts/build.sh` (ROBOT) for
everything else.** This isn't a fallback for lacking Protégé — investigated
deeply and confirmed: Protégé (v4/5, its real architecture) is a thin GUI
directly on the OWL API, the same library ROBOT itself uses. Every core
curator action reduces to the identical axiom type hand-writing produces
(`Declaration` → `OWLDeclarationAxiom`, `AnnotationAssertion` →
`OWLAnnotationAssertionAxiom`, `SubClassOf` → `OWLSubClassOfAxiom`) — there's
no separate GUI-only data model being bypassed. Concretely, per action:

- **Writing axioms** — hand-edit, per the template below. Verified
  empirically (not assumed): running the file through the OWL API's own
  functional-syntax writer (`robot convert --format ofn`, the same machinery
  Protégé's Save uses internally) is semantically lossless (`robot diff`
  confirms 0 real axioms lost) but **textually rewrites the entire file** —
  every CURIE (`IO:0000001`, `IAO:0000115`) expanded to a full bracketed
  IRI, annotations reordered alphabetically instead of our intentional
  label→altLabel→definition→evidence→source order, declarations regrouped
  to the top. That's exactly the diff-unfriendliness OWL Functional Syntax
  was chosen over RDF/XML/Turtle to avoid — so this file is never machine
  round-tripped, by any tool, ever.
- **Finding the right superclass to subclass under** — browse
  [`/io/docs/`](https://purl.openfaster.org/io/docs/) (this repo's own
  WIDOCO output). Not a downgrade from Protégé's class-hierarchy tree: real
  OBO curators standardly use a generated term browser for exactly this
  (Ontobee, "the default browser for OBO" per OBO Academy's own docs) rather
  than Protégé's tree view — a generated docs page *is* the normal way this
  is done.
- **Consistency checking** — `scripts/build.sh`'s `robot reason` (ELK by
  default, same reasoner engine Protégé's Reasoner menu would use — ELK/
  HermiT/Whelk all ship as standalone OWL-API-usable artifacts, not
  GUI-exclusive plugins).
- **Quality/pitfall checking** — `scripts/build.sh`'s `robot report` (the
  CLI-native equivalent of a GUI pitfall-scanner like OOPS!).

Copy this block, change the ID/labels/text, and append it before the closing
`)`:

```
# ============================================================= #
# IO:00000NN -- <English label> / <German label>
# ============================================================= #
Declaration(Class(IO:00000NN))
AnnotationAssertion(rdfs:label IO:00000NN "<English label>"@en)
AnnotationAssertion(IAO:0000118 IO:00000NN "<German label>"@de)
AnnotationAssertion(IAO:0000115 IO:00000NN "<short Aristotelian definition>"@en)
AnnotationAssertion(IAO:0000116 IO:00000NN "<full researched justification -- XSD quotes, handbook citations, reasoning>"@en)
AnnotationAssertion(IAO:0000119 IO:00000NN "<citation: which XSD element(s), which handbook section(s)>"@en)
SubClassOf(IO:00000NN <closest-fitting imported BFO/IAO class>)
```

Next available ID: check the file for the highest `IO:` number in use, add
one — no `idranges.owl` yet (solo curator, no real collision risk; add one
for real if a second curator joins). Then add the corresponding row(s) to
`mappings/mikadiv-kafe.sssom.tsv` (one row per distinct external XSD
element, `skos:exactMatch` unless the research genuinely doesn't support an
exact match — see the existing rows' `comment` field for the evidence-citing
style), and mark the field(s) `assigned` in `data/field-inventory.json`.
Run `scripts/build.sh` before committing — it only reads the source and
writes to `build/`/the release copy, so it's always safe to run.

## Building

```
export ROBOT_CMD="java -jar /path/to/robot.jar"   # or just `robot` if on PATH
./scripts/build.sh
```

## Process (deliberately slow, by design)

Every field-to-concept match is verified against the real XSD (`openfaster-spec`)
and, where relevant, the official Kommunikationshandbücher — not inferred
from field names or descriptions alone. At ~339 candidate fields, this spans
far more than one sitting; `data/field-inventory.json` is the persistent
checklist tracking that.
