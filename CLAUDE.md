# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a [MoonBit](https://docs.moonbitlang.com) project - a statically typed programming language that compiles to WebAssembly and native backends.

## Essential Commands

### Development Workflow
```bash
# Format code (always run before committing)
moon fmt

# Update package interface files (.mbti) and check for changes
moon info

# Combined check (updates interfaces and formats code)
moon info && moon fmt

# Type check and lint the codebase
moon check

# Run all tests
moon test

# Update test snapshots when behavior changes intentionally
moon test --update

# Analyze test coverage
moon coverage analyze > uncovered.log
```

### Setup
```bash
# Install/update MoonBit dependencies
moon update

# Check MoonBit version
moon version --all
```

## Project Architecture

### Module Structure
- `moon.mod.json` - Module metadata and configuration at the root level
- Each directory contains a `moon.pkg.json` file defining its dependencies
- Packages are imported via their full module path (e.g., `colmugx/moonbit_mcp/internal/server`)
- The `cmd/main` package has `is-main: true` for the entry point

### Build Output
- All build artifacts are in `_build/` (gitignored)
- The `target` symlink points to `_build` for convenience
- `.mbti` files contain generated package interfaces - check diffs to verify public API changes

### File Organization
- Source files: `*.mbt`
- Blackbox tests: `*_test.mbt` (tests external behavior)
- Whitebox tests: `*_wbtest.mbt` (tests internal implementation)
- Deprecated code: consolidate in `deprecated.mbt` files per directory

## Coding Conventions

### Block Style
MoonBit code is organized in blocks separated by `///|`:
```moonbit
///|
fn function_one() { ... }

///|
fn function_two() { ... }
```
Block order is irrelevant - blocks can be refactored independently.

### Testing
- Prefer `inspect` with snapshot testing over `assert_eq` for most cases
- Use `assert_eq` only in loops or where snapshots would vary
- Update snapshots with `moon test --update` when changing behavior
- Run coverage analysis to identify untested code

## GitHub Copilot Integration

The project includes a `.github/workflows/copilot-setup-steps.yml` that:
1. Checks out the code
2. Installs MoonBit via the official installer
3. Runs `moon update` to fetch dependencies

This runs automatically on changes to the workflow file and can be triggered manually via the Actions tab.
