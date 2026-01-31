#!/bin/bash
# snapshot.sh - Create iteration snapshot
# Usage: ./harness/scripts/snapshot.sh [optional-note]

set -e

# Configuration
HARNESS_DIR="harness"
LOGS_DIR="${HARNESS_DIR}/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ITER_DIR="${LOGS_DIR}/iter_${TIMESTAMP}"

# Create iteration directory
mkdir -p "${ITER_DIR}"

echo "Creating iteration snapshot: ${ITER_DIR}"

# Copy key files
echo "  Copying TASKS.md..."
cp TASKS.md "${ITER_DIR}/TASKS.md" 2>/dev/null || echo "  TASKS.md not found"

echo "  Copying PLAN.md..."
cp PLAN.md "${ITER_DIR}/PLAN.md" 2>/dev/null || echo "  PLAN.md not found"

echo "  Copying EVAL.md..."
cp EVAL.md "${ITER_DIR}/EVAL.md" 2>/dev/null || echo "  EVAL.md not found"

# Capture git state
echo "  Recording git state..."
git log --oneline -20 > "${ITER_DIR}/commits.txt" 2>/dev/null || echo "No git history"
git branch -v > "${ITER_DIR}/branches.txt" 2>/dev/null || echo "No branches"
git status --short > "${ITER_DIR}/status.txt" 2>/dev/null || echo "No status"

# Check for existing verdict
if [ -f "${HARNESS_DIR}/verdict.md" ]; then
    echo "  Moving verdict.md..."
    mv "${HARNESS_DIR}/verdict.md" "${ITER_DIR}/verdict.md"
fi

# Create summary
echo "  Creating summary..."
cat > "${ITER_DIR}/summary.txt" << EOF
Iteration Snapshot
==================
Timestamp: ${TIMESTAMP}
Date: $(date)
Note: ${1:-"No note provided"}

Files captured:
- TASKS.md
- PLAN.md
- EVAL.md
- commits.txt (recent commits)
- branches.txt (branch state)
- status.txt (working tree status)
- verdict.md (if present)
EOF

echo ""
echo "Snapshot complete: ${ITER_DIR}"
echo ""
echo "Contents:"
ls -la "${ITER_DIR}"
