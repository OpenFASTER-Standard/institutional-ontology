#!/bin/bash
# Regenerates src/ontology/imports/{bfo,iao}_import.owl -- the pinned BFO/IAO
# term subsets the editors' file imports (via catalog-v001.xml) -- using
# ROBOT's `extract` (BOT method: seed term(s) + their superclasses).
#
# Add a --term for every BFO/IAO class newly referenced in the editors' file.
# Requires: ROBOT on PATH as `robot`, or set ROBOT_CMD (see build.sh).
set -euo pipefail

ROBOT_CMD="${ROBOT_CMD:-robot}"
cd "$(dirname "$0")/../src/ontology/imports"

echo "Fetching current BFO/IAO releases..."
curl -sL -o /tmp/bfo-full.owl http://purl.obolibrary.org/obo/bfo.owl
curl -sL -o /tmp/iao-full.owl http://purl.obolibrary.org/obo/iao.owl

echo "Extracting BFO subset (Role + ancestors)..."
$ROBOT_CMD extract \
  --input /tmp/bfo-full.owl \
  --method BOT \
  --term BFO:0000023 `# role` \
  --output bfo_import.owl

echo "Extracting IAO subset (information content entity, document, identifier + ancestors)..."
$ROBOT_CMD extract \
  --input /tmp/iao-full.owl \
  --method BOT \
  --term IAO:0000030 `# information content entity` \
  --term IAO:0000310 `# document` \
  --term IAO:0020000 `# identifier` \
  --output iao_import.owl

rm -f /tmp/bfo-full.owl /tmp/iao-full.owl
echo "Done. Review the diff before committing."
