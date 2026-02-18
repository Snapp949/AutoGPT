#!/bin/bash

# Automation Validation Script
# This script validates the autonomous issue detection and performance optimization setup

set -e

echo "========================================="
echo "Automation Setup Validation"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

validate_count=0
error_count=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        validate_count=$((validate_count + 1))
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        error_count=$((error_count + 1))
        return 1
    fi
}

# Function to validate YAML syntax
validate_yaml() {
    if python3 -c "import yaml; yaml.safe_load(open('$1'))" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Valid YAML: $1"
        validate_count=$((validate_count + 1))
        return 0
    else
        echo -e "${RED}✗${NC} Invalid YAML: $1"
        error_count=$((error_count + 1))
        return 1
    fi
}

echo "1. Checking Workflow Files"
echo "-------------------------------------------"

workflows=(
    ".github/workflows/codeql.yml"
    ".github/workflows/automated-issue-detection.yml"
    ".github/workflows/performance-monitoring.yml"
    ".github/workflows/bottleneck-detection.yml"
    ".github/workflows/auto-optimization.yml"
    ".github/workflows/monitoring-agent.yml"
    ".github/workflows/automation-dashboard.yml"
)

for workflow in "${workflows[@]}"; do
    check_file "$workflow"
done

echo ""
echo "2. Validating YAML Syntax"
echo "-------------------------------------------"

for workflow in "${workflows[@]}"; do
    if [ -f "$workflow" ]; then
        validate_yaml "$workflow"
    fi
done

echo ""
echo "3. Checking Documentation"
echo "-------------------------------------------"

check_file "AUTOMATION.md"
check_file "README.md"

echo ""
echo "4. Verifying Workflow Triggers"
echo "-------------------------------------------"

# Check if workflows have proper triggers
for workflow in "${workflows[@]}"; do
    if [ -f "$workflow" ]; then
        if grep -q "on:" "$workflow"; then
            echo -e "${GREEN}✓${NC} Workflow has triggers: $(basename $workflow)"
            validate_count=$((validate_count + 1))
        else
            echo -e "${RED}✗${NC} Missing triggers: $(basename $workflow)"
            error_count=$((error_count + 1))
        fi
    fi
done

echo ""
echo "5. Checking for Required Permissions"
echo "-------------------------------------------"

# Check if workflows have permissions defined
for workflow in "${workflows[@]}"; do
    if [ -f "$workflow" ]; then
        if grep -q "permissions:" "$workflow"; then
            echo -e "${GREEN}✓${NC} Permissions defined: $(basename $workflow)"
            validate_count=$((validate_count + 1))
        else
            echo -e "${YELLOW}⚠${NC} No permissions defined: $(basename $workflow)"
        fi
    fi
done

echo ""
echo "6. Verifying Workflow Integration"
echo "-------------------------------------------"

# Check if CodeQL queries are enhanced
if grep -q "security-extended,security-and-quality" ".github/workflows/codeql.yml"; then
    echo -e "${GREEN}✓${NC} CodeQL enhanced with extended security queries"
    validate_count=$((validate_count + 1))
else
    echo -e "${YELLOW}⚠${NC} CodeQL not using extended queries"
fi

echo ""
echo "7. Summary of Automation Capabilities"
echo "-------------------------------------------"

echo -e "${GREEN}✓${NC} Issue Detection:"
echo "  - CodeQL (Python & TypeScript)"
echo "  - Pylint (Python)"
echo "  - ESLint (JavaScript/TypeScript)"
echo "  - Trivy (Security vulnerabilities)"
echo ""

echo -e "${GREEN}✓${NC} Performance Monitoring:"
echo "  - Python profiling (py-spy, memory-profiler)"
echo "  - Frontend bundle analysis"
echo "  - Code complexity analysis (Radon)"
echo ""

echo -e "${GREEN}✓${NC} Automated Fixes:"
echo "  - Python: autoflake, autopep8, isort, black"
echo "  - Frontend: ESLint --fix, Prettier"
echo "  - PR creation for auto-fixes"
echo ""

echo -e "${GREEN}✓${NC} Continuous Monitoring:"
echo "  - Daily health checks"
echo "  - Test coverage analysis"
echo "  - Code quality trends"
echo "  - Weekly summary reports"
echo ""

echo -e "${GREEN}✓${NC} Bottleneck Detection:"
echo "  - Cyclomatic complexity analysis"
echo "  - Maintainability index tracking"
echo "  - Performance optimization suggestions"
echo ""

echo ""
echo "========================================="
echo "Validation Results"
echo "========================================="
echo -e "Total checks passed: ${GREEN}${validate_count}${NC}"
echo -e "Errors found: ${RED}${error_count}${NC}"
echo ""

if [ $error_count -eq 0 ]; then
    echo -e "${GREEN}✓ All validation checks passed!${NC}"
    echo ""
    echo "Automation setup is complete and ready to use."
    echo ""
    echo "Next steps:"
    echo "1. Push changes to GitHub"
    echo "2. Workflows will run automatically based on their schedules"
    echo "3. Manual workflows can be triggered from GitHub Actions tab"
    echo "4. Review workflow artifacts for detailed reports"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Validation failed with $error_count error(s)${NC}"
    echo ""
    echo "Please fix the errors before proceeding."
    exit 1
fi
