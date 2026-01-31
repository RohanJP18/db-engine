#!/bin/bash
# run_eval.sh - Run evaluation and capture output
# Usage: ./harness/scripts/run_eval.sh

set -e

HARNESS_DIR="harness"
OUTPUT_FILE="${HARNESS_DIR}/eval_output.txt"
VERDICT_FILE="${HARNESS_DIR}/verdict.md"

echo "=========================================="
echo "Running Evaluation"
echo "Date: $(date)"
echo "=========================================="
echo ""

# Capture all output
{
    echo "=== BUILD ==="
    echo ""
    if make build; then
        BUILD_STATUS="PASS"
        echo ""
        echo "Build: PASS"
    else
        BUILD_STATUS="FAIL"
        echo ""
        echo "Build: FAIL"
    fi

    echo ""
    echo "=== TEST ==="
    echo ""
    if make test; then
        TEST_STATUS="PASS"
        echo ""
        echo "Test: PASS"
    else
        TEST_STATUS="FAIL"
        echo ""
        echo "Test: FAIL"
    fi

    echo ""
    echo "=== SUMMARY ==="
    echo "Build: ${BUILD_STATUS}"
    echo "Test: ${TEST_STATUS}"

    if [ "${BUILD_STATUS}" = "PASS" ] && [ "${TEST_STATUS}" = "PASS" ]; then
        OVERALL="PASS"
    else
        OVERALL="FAIL"
    fi

    echo "Overall: ${OVERALL}"

} 2>&1 | tee "${OUTPUT_FILE}"

# Determine final status
BUILD_STATUS=$(grep "^Build: " "${OUTPUT_FILE}" | tail -1 | cut -d' ' -f2)
TEST_STATUS=$(grep "^Test: " "${OUTPUT_FILE}" | tail -1 | cut -d' ' -f2)

if [ "${BUILD_STATUS}" = "PASS" ] && [ "${TEST_STATUS}" = "PASS" ]; then
    OVERALL="PASS"
else
    OVERALL="FAIL"
fi

# Create verdict template
cat > "${VERDICT_FILE}" << EOF
# Iteration Verdict

**Date:** $(date +"%Y-%m-%d %H:%M")
**Evaluated Commits:** $(git log --oneline -1 2>/dev/null || echo "N/A")

## Evaluation Results

| Check | Status |
|-------|--------|
| Build | ${BUILD_STATUS} |
| Test  | ${TEST_STATUS} |
| **Overall** | **${OVERALL}** |

## Task Verdicts

<!-- Judge: Fill in per-task verdicts below -->

### [DB-XXX] Task Title
- **Verdict:** PENDING
- **Acceptance Check:**
- **Result:**
- **Notes:**

## Overall Result

**${OVERALL}**

## Rework Instructions

<!-- If FAIL, provide specific feedback -->

---
*Full evaluation output saved to: ${OUTPUT_FILE}*
EOF

echo ""
echo "=========================================="
echo "Evaluation Complete: ${OVERALL}"
echo "=========================================="
echo ""
echo "Output saved to: ${OUTPUT_FILE}"
echo "Verdict template: ${VERDICT_FILE}"
echo ""
echo "Next steps:"
if [ "${OVERALL}" = "PASS" ]; then
    echo "  1. Judge reviews and fills in verdict.md"
    echo "  2. Run ./harness/scripts/snapshot.sh"
    echo "  3. Human merges agent/judge -> main"
else
    echo "  1. Judge identifies failing tasks"
    echo "  2. Mark tasks as REWORK in TASKS.md"
    echo "  3. Workers fix issues"
    echo "  4. Re-run evaluation"
fi
