///|
/// MoonBit MCP Server - STDIO Transport
/// Implements Model Context Protocol over standard input/output

///|
/// Main async entry point
async fn main {
  // Log startup to stderr (won't interfere with JSON-RPC on stdout)
  @stdio.stderr.write("MoonBit MCP Server v0.2.0 starting...\n")

  // Main request processing loop
  while true {
    // Read one line (one JSON-RPC request)
    let line_result = @stdio.stdin.read_until("\n")
    match line_result {
      None => {
        // EOF reached, exit gracefully
        @stdio.stderr.write("EOF reached, shutting down\n")
        break
      }
      Some(line_view) => {
        // Convert to String and trim whitespace
        let line = line_view.to_string()
        let request_json = line.trim().to_string()

        // Skip empty lines
        if request_json.is_empty() {
          continue
        }

        // Log incoming request to stderr
        @stdio.stderr.write("Received: " + request_json + "\n")

        // Parse request (using stdlib JSON parser)
        match @json.parse_request(request_json) {
          None => {
            // Invalid JSON-RPC request
            @stdio.stderr.write("Failed to parse request\n")
            let error = @json.jsonrpc_error(0, -32700, "Parse error")
            @stdio.stdout.write(error + "\n")
          }
          Some(req) => {
            // Route to handler and get response
            let response = @mcp.route_request_async(req)

            // Write response to stdout
            @stdio.stdout.write(response + "\n")

            // Log to stderr
            @stdio.stderr.write(
              "Sent response for method: " + req.method_name + "\n",
            )
          }
        }
      }
    }
  }
  @stdio.stderr.write("Server stopped\n")
}
