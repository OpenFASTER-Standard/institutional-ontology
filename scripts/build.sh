#!/bin/bash
# Builds the release artifact from src/ontology/institutional-ontology-edit.ofn
# (the hand-authored source) -- source/release separation, per ODK convention.
# Requires: ROBOT (https://robot.obolibrary.org/) on PATH as `robot`, or set
# ROBOT_CMD to an invocation (e.g. `java -jar robot.jar`).
set -euo pipefail

ROBOT_CMD="${ROBOT_CMD:-robot}"
cd "$(dirname "$0")/.."

mkdir -p build

echo "Merging editors' file with BFO/IAO imports..."
$ROBOT_CMD merge \
  --catalog src/ontology/catalog-v001.xml \
  --input src/ontology/institutional-ontology-edit.ofn \
  --output build/institutional-ontology.owl

echo "Running QC report..."
$ROBOT_CMD report \
  --input build/institutional-ontology.owl \
  --output build/institutional-ontology-report.tsv \
  --fail-on ERROR

echo "Checking logical consistency (ELK)..."
$ROBOT_CMD reason \
  --input build/institutional-ontology.owl \
  --reasoner ELK \
  --output build/institutional-ontology-reasoned.owl

echo "Build complete: build/institutional-ontology.owl"
