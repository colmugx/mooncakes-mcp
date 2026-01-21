///|
/// Main Entry Point
/// Handles CLI arguments and starts appropriate server mode
async fn main {
  let args = @sys.get_cli_args()

  // Use task group for concurrency
  @async.with_task_group(async fn(group) {
    // Default to STDIO mode
    if args.length() <= 1 {
      run_stdio_mode()
      return
    }
    match args[1] {
      "server" => run_http_mode(group)
      _ => run_stdio_mode()
    }
  })
}

///|
async fn run_stdio_mode() -> Unit {
  @stdio.stderr.write("Starting MoonBit MCP Server (STDIO mode)...\n")

  // Create transport
  let transport = @sdk.StdioTransport::new()

  // Create server
  let server = @sdk.MCPServer::new("moonbit-docs", "0.2.0")

  // Register tools
  server.register_tool(
    "search_packages", "Search for MoonBit packages", @tools.search_packages_schema,
    @tools.search_packages_handler,
  )
  server.register_tool(
    "get_package_info", "Get package metadata and README", @tools.get_package_info_schema,
    @tools.get_package_info_handler,
  )
  server.register_tool(
    "get_package_structure", "Get package module tree structure", @tools.get_package_structure_schema,
    @tools.get_package_structure_handler,
  )
  server.register_tool(
    "query_symbols", "Query types/values/traits in a package", @tools.query_symbols_schema,
    @tools.query_symbols_handler,
  )

  // Run server
  server.run(Stdio(transport)) catch {
    e => @stdio.stderr.write("Server error: " + e.to_string() + "\n")
  }
}

///|
async fn run_http_mode(group : @async.TaskGroup[Unit]) -> Unit {
  @stdio.stderr.write("Starting MoonBit MCP Server (HTTP mode)...\n")

  // Create transport
  let transport = @sdk.HttpTransport::new(port=4240)

  // Create server
  let server = @sdk.MCPServer::new("moonbit-docs", "0.2.0")

  // Register tools
  server.register_tool(
    "search_packages", "Search for MoonBit packages", @tools.search_packages_schema,
    @tools.search_packages_handler,
  )
  server.register_tool(
    "get_package_info", "Get package metadata and README", @tools.get_package_info_schema,
    @tools.get_package_info_handler,
  )
  server.register_tool(
    "get_package_structure", "Get package module tree structure", @tools.get_package_structure_schema,
    @tools.get_package_structure_handler,
  )
  server.register_tool(
    "query_symbols", "Query types/values/traits in a package", @tools.query_symbols_schema,
    @tools.query_symbols_handler,
  )

  // Run server - spawn BOTH transport.start() and server.run() concurrently
  @stdio.stderr.write("Starting HTTP server listener...\n")

  // Spawn HTTP server listener in background
  group.spawn_bg(async fn() {
    @stdio.stderr.write("[HTTP] Spawn_bg: Starting transport.start()\n")
    try {
      transport.start()
      @stdio.stderr.write("[HTTP] Transport started successfully\n")
    } catch {
      e => {
        @stdio.stderr.write("[HTTP] Transport error: " + e.to_string() + "\n")
        abort("HTTP transport failed")
      }
    }
  })

  // Give the HTTP server time to bind to port
  @async.sleep(500)
  @stdio.stderr.write("[HTTP] Starting MCP server loop...\n")

  // Run MCP server loop in foreground  
  server.run(Http(transport)) catch {
    e => @stdio.stderr.write("[HTTP] Server error: " + e.to_string() + "\n")
  }
}
