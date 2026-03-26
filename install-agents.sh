#!/bin/bash

# iOS Claude Code Agents — Install Script
# Run from the root of your Xcode project:
#   chmod +x install-agents.sh && ./install-agents.sh

set -e

AGENTS_DIR=".claude/agents"

echo "📦 Installing iOS Claude Code agents..."
mkdir -p "$AGENTS_DIR"

# Copy all agent files
for file in agents/*.md; do
  filename=$(basename "$file")
  # Strip the numeric prefix (e.g. 01-) for cleaner agent names
  target_name=$(echo "$filename" | sed 's/^[0-9]*-//')
  cp "$file" "$AGENTS_DIR/$target_name"
  echo "  ✅ Installed: $target_name"
done

echo ""
echo "🎉 All agents installed to $AGENTS_DIR"
echo ""
echo "Available agents:"
echo "  • swift-developer       — Feature implementation (MVVM, SwiftUI, async/await)"
echo "  • ios-architect         — Architecture decisions, module design"
echo "  • code-reviewer         — MVVM compliance, memory, concurrency review"
echo "  • test-engineer         — XCTest, Swift Testing, mock generation"
echo "  • security-auditor      — Keychain, Firebase, ATS, privacy review"
echo "  • ui-ux-reviewer        — HIG compliance, accessibility, Dark Mode"
echo "  • appstore-preflight    — Rejection risk scan before submission"
echo "  • documentation-writer  — DocC, README, ADRs"
echo ""
echo "Usage in Claude Code:"
echo "  > Use the swift-developer agent to implement the login screen"
echo "  > Have the code-reviewer agent review the AuthViewModel"
echo "  > Run the appstore-preflight agent before submitting"
