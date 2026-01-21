#!/bin/bash
# MoonBit MCP Server Test Script
# Tests connectivity and basic MCP operations

cd "$(dirname "$0")"

echo "🚀 MoonBit MCP Server - Connectivity Test"
echo "=========================================="
echo ""

# Test 1: Initialize
echo "📝 Test 1: Initialize (handshake)"
RESPONSE=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | moon run cmd/stdio 2>&1 | grep "^{")
if echo "$RESPONSE" | jq -e '.result.serverInfo.name == "moonbit-mcp-server"' > /dev/null 2>&1; then
  echo "✅ PASSED - Server initialized successfully"
  echo "   Version: $(echo "$RESPONSE" | jq -r '.result.serverInfo.version')"
  echo "   Protocol: $(echo "$RESPONSE" | jq -r '.result.protocolVersion')"
else
  echo "❌ FAILED - Initialize failed"
  echo "$RESPONSE"
  exit 1
fi
echo ""

# Test 2: Tools List
echo "📝 Test 2: Tools List (capability check)"
RESPONSE=$(echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | moon run cmd/stdio 2>&1 | grep "^{")
TOOL_COUNT=$(echo "$RESPONSE" | jq '.result.tools | length')
if [ "$TOOL_COUNT" -gt 0 ]; then
  echo "✅ PASSED - Found $TOOL_COUNT tool(s)"
  echo "$RESPONSE" | jq -r '.result.tools[] | "   - \(.name): \(.description)"'
else
  echo "❌ FAILED - No tools found"
  echo "$RESPONSE"
  exit 1
fi
echo ""

# Test 3: Tool Execution
echo "📝 Test 3: Tool Execution (search_packages)"
RESPONSE=$(echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"search_packages","arguments":{"query":"async"}}}' | moon run cmd/stdio 2>&1 | grep "^{")
if echo "$RESPONSE" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
  echo "✅ PASSED - Tool executed successfully"
  RESULT_TEXT=$(echo "$RESPONSE" | jq -r '.result.content[0].text')
  echo "   Results preview:"
  echo "$RESULT_TEXT" | head -3 | sed 's/^/   /'
else
  echo "❌ FAILED - Tool execution failed"
  echo "$RESPONSE"
  exit 1
fi
echo ""

# Test 4: Invalid Method (error handling)
echo "📝 Test 4: Error Handling (invalid method)"
RESPONSE=$(echo '{"jsonrpc":"2.0","id":4,"method":"invalid_method"}' | moon run cmd/stdio 2>&1 | grep "^{")
if echo "$RESPONSE" | jq -e '.error.code == -32601' > /dev/null 2>&1; then
  echo "✅ PASSED - Error handling works"
  echo "   Error: $(echo "$RESPONSE" | jq -r '.error.message')"
else
  echo "❌ FAILED - Expected error response"
  echo "$RESPONSE"
  exit 1
fi
echo ""

echo "=========================================="
echo "✨ All tests passed! Server is ready for use."
echo ""
echo "Next steps:"
echo "  1. Configure Claude Desktop (see CLAUDE_DESKTOP_SETUP.md)"
echo "  2. Restart Claude Desktop"
echo "  3. Test with: 'Search for MoonBit packages about http'"
