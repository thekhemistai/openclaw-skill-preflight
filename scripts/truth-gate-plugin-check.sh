#!/bin/bash

# truth-gate-plugin-check.sh
# Deterministic verification that skill-preflight is publication-ready
# Part of truth-gates-protocol: https://github.com/thekhemistai/openclaw/memory/protocols/truth-gates-protocol.md

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "🔍 skill-preflight Plugin Truth Gate Check"
echo "=========================================="
echo ""

# Check 1: Required files exist
echo "✓ Check 1: Required files"
required_files=(
  "package.json"
  "openclaw.plugin.json"
  "SKILL.md"
  "README.md"
  "ROADMAP.md"
  "CONTRIBUTING.md"
  "LICENSE"
  "dist/index.js"
  ".gitignore"
)

for file in "${required_files[@]}"; do
  if [ -f "$PLUGIN_DIR/$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (MISSING)"
    ((ERRORS++))
  fi
done
echo ""

# Check 2: Git repository initialized
echo "✓ Check 2: Git repository"
if [ -d "$PLUGIN_DIR/.git" ]; then
  commit_count=$(cd "$PLUGIN_DIR" && git rev-list --count HEAD 2>/dev/null || echo "0")
  echo "  ✅ Git initialized with $commit_count commit(s)"
  if [ "$commit_count" -ge 2 ]; then
    echo "  ✅ Multiple commits found (publication ready)"
  else
    echo "  ⚠️  Only $commit_count commit(s) - consider more meaningful history"
    ((WARNINGS++))
  fi
else
  echo "  ❌ Git not initialized"
  ((ERRORS++))
fi
echo ""

# Check 3: Package metadata
echo "✓ Check 3: Package metadata (package.json)"
if command -v jq &> /dev/null; then
  name=$(jq -r '.name' "$PLUGIN_DIR/package.json" 2>/dev/null || echo "MISSING")
  version=$(jq -r '.version' "$PLUGIN_DIR/package.json" 2>/dev/null || echo "MISSING")
  main=$(jq -r '.main' "$PLUGIN_DIR/package.json" 2>/dev/null || echo "MISSING")

  echo "  Name: $name"
  echo "  Version: $version"
  echo "  Main: $main"

  if [[ "$name" == "@thekhemistai/skill-preflight" ]]; then
    echo "  ✅ Scoped package name correct"
  else
    echo "  ❌ Package name should be @thekhemistai/skill-preflight (got: $name)"
    ((ERRORS++))
  fi

  if [[ "$version" == "1.0.0" ]]; then
    echo "  ✅ Version 1.0.0"
  else
    echo "  ⚠️  Version is $version (expected 1.0.0 for initial release)"
    ((WARNINGS++))
  fi

  if [[ "$main" == "dist/index.js" ]]; then
    echo "  ✅ Main entry point correct"
  else
    echo "  ❌ Main should be dist/index.js (got: $main)"
    ((ERRORS++))
  fi
else
  echo "  ⚠️  jq not available, skipping JSON validation"
  ((WARNINGS++))
fi
echo ""

# Check 4: Plugin manifest
echo "✓ Check 4: Plugin manifest (openclaw.plugin.json)"
if command -v jq &> /dev/null; then
  plugin_id=$(jq -r '.id' "$PLUGIN_DIR/openclaw.plugin.json" 2>/dev/null || echo "MISSING")
  plugin_name=$(jq -r '.name' "$PLUGIN_DIR/openclaw.plugin.json" 2>/dev/null || echo "MISSING")

  echo "  ID: $plugin_id"
  echo "  Name: $plugin_name"

  if [[ "$plugin_id" == "skill-preflight" ]]; then
    echo "  ✅ Plugin ID correct"
  else
    echo "  ❌ Plugin ID should be skill-preflight (got: $plugin_id)"
    ((ERRORS++))
  fi
fi
echo ""

# Check 5: No secrets in files
echo "✓ Check 5: Security - No hardcoded secrets"
secret_patterns=(
  "PRIVATE_KEY"
  "API_KEY"
  "SECRET"
  "PASSWORD"
  "TOKEN"
)

secrets_found=0
for pattern in "${secret_patterns[@]}"; do
  # Check in dist, ignore dist/node_modules
  if grep -r "$pattern" "$PLUGIN_DIR" --include="*.js" --include="*.json" --include="*.md" 2>/dev/null | grep -v "node_modules" | grep -v ".git" > /dev/null; then
    echo "  ⚠️  Pattern '$pattern' found - verify it's not a real secret"
    ((WARNINGS++))
    ((secrets_found++))
  fi
done

if [ $secrets_found -eq 0 ]; then
  echo "  ✅ No obvious secret patterns found"
fi
echo ""

# Check 6: Ollama availability
echo "✓ Check 6: Runtime - Ollama availability"
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
  echo "  ✅ Ollama is running on localhost:11434"

  if curl -s http://localhost:11434/api/tags | grep -q "nomic-embed-text"; then
    echo "  ✅ nomic-embed-text model is available"
  else
    echo "  ⚠️  nomic-embed-text not found - plugin requires this model"
    echo "     Install with: ollama pull nomic-embed-text"
    ((WARNINGS++))
  fi
else
  echo "  ℹ️  Ollama not running - plugin requires it at runtime"
  echo "     Start Ollama with: ollama serve"
fi
echo ""

# Check 7: Compiled code exists
echo "✓ Check 7: Compiled code"
if [ -f "$PLUGIN_DIR/dist/index.js" ]; then
  file_size=$(wc -c < "$PLUGIN_DIR/dist/index.js")
  if [ "$file_size" -gt 5000 ]; then
    echo "  ✅ dist/index.js exists ($file_size bytes)"
  else
    echo "  ❌ dist/index.js seems too small ($file_size bytes)"
    ((ERRORS++))
  fi
else
  echo "  ❌ dist/index.js not found"
  ((ERRORS++))
fi
echo ""

# Check 8: Documentation quality
echo "✓ Check 8: Documentation"
doc_files=(
  "SKILL.md"
  "README.md"
  "ROADMAP.md"
  "CONTRIBUTING.md"
)

for file in "${doc_files[@]}"; do
  if [ -f "$PLUGIN_DIR/$file" ]; then
    words=$(wc -w < "$PLUGIN_DIR/$file")
    echo "  ✅ $file ($words words)"
  fi
done
echo ""

# Summary
echo "=========================================="
echo "📊 Truth Gate Results"
echo ""
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
  if [ $WARNINGS -eq 0 ]; then
    echo "✅ PASS — Plugin is publication-ready"
    exit 0
  else
    echo "⚠️  PASS (with warnings) — Fix warnings before publishing"
    exit 0
  fi
else
  echo "❌ FAIL — Fix $ERRORS error(s) before publishing"
  exit 1
fi
