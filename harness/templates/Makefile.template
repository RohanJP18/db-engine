# Makefile for DB Engine
# Copy this to the db-engine repo root as 'Makefile'

# Compiler settings
CC = gcc
CFLAGS = -Wall -Wextra -Werror -g -std=c11
LDFLAGS =

# Directories
SRC_DIR = src
TEST_DIR = tests
BUILD_DIR = build
BIN_DIR = bin

# Source files (add as implemented)
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Test files
TEST_SRCS = $(wildcard $(TEST_DIR)/*.c)
TEST_BINS = $(TEST_SRCS:$(TEST_DIR)/%.c=$(BIN_DIR)/%)

# Main binary
TARGET = $(BIN_DIR)/db

# Phony targets
.PHONY: all build test lint eval clean help dirs

# Default target
all: build

# Create directories
dirs:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR)

# Build the main binary
build: dirs
	@echo "=== Building DB Engine ==="
	@if [ -z "$(SRCS)" ]; then \
		echo "No source files yet - creating placeholder"; \
		mkdir -p $(SRC_DIR); \
		echo 'int main(void) { return 0; }' > $(SRC_DIR)/main.c; \
	fi
	@if [ -f $(SRC_DIR)/main.c ]; then \
		$(CC) $(CFLAGS) -o $(TARGET) $(SRC_DIR)/*.c $(LDFLAGS) && \
		echo "Build successful: $(TARGET)"; \
	else \
		echo "No main.c found - skipping build"; \
	fi

# Build object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | dirs
	$(CC) $(CFLAGS) -c $< -o $@

# Run tests
test: dirs
	@echo "=== Running Tests ==="
	@if [ -z "$(TEST_SRCS)" ]; then \
		echo "No test files yet - tests pass vacuously"; \
		exit 0; \
	fi
	@failed=0; \
	for test_src in $(TEST_SRCS); do \
		test_name=$$(basename $$test_src .c); \
		echo "Running $$test_name..."; \
		$(CC) $(CFLAGS) -o $(BIN_DIR)/$$test_name $$test_src $(filter-out $(BUILD_DIR)/main.o,$(OBJS)) $(LDFLAGS) 2>/dev/null && \
		$(BIN_DIR)/$$test_name && \
		echo "  PASS: $$test_name" || \
		{ echo "  FAIL: $$test_name"; failed=1; }; \
	done; \
	if [ -f $(TEST_DIR)/run_golden.sh ]; then \
		echo "Running golden tests..."; \
		bash $(TEST_DIR)/run_golden.sh || failed=1; \
	fi; \
	if [ $$failed -eq 0 ]; then \
		echo "All tests passed"; \
	else \
		echo "Some tests failed"; \
		exit 1; \
	fi

# Run linter (optional)
lint:
	@echo "=== Running Linter ==="
	@if command -v cppcheck >/dev/null 2>&1; then \
		cppcheck --error-exitcode=1 --enable=warning $(SRC_DIR)/ 2>/dev/null || true; \
	else \
		echo "cppcheck not installed - skipping lint"; \
	fi

# Full evaluation (Judge uses this)
eval: build test
	@echo ""
	@echo "=== Evaluation Complete ==="

# Clean build artifacts
clean:
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR) $(BIN_DIR)
	@echo "Clean complete"

# Help
help:
	@echo "DB Engine Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make build  - Compile the database engine"
	@echo "  make test   - Run all tests"
	@echo "  make lint   - Run static analysis (optional)"
	@echo "  make eval   - Run build + test (for Judge)"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make help   - Show this help"
	@echo ""
	@echo "Directory structure:"
	@echo "  src/    - Source files (.c)"
	@echo "  tests/  - Test files"
	@echo "  build/  - Object files"
	@echo "  bin/    - Compiled binaries"
