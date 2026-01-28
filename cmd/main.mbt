///|
/// Main Entry Point
/// Handles CLI arguments and starts appropriate server mode
async fn main {
  let args = @sys.get_cli_args()
  let server = @mcp.MCPServer::new("moonbit-docs", "0.2.0")

  // Create application context with caches
  let app_context = @cache.AppContext::new()

  // Register all tools using NEW Tool Trait API
  server.register_trait_tool(@tools.SearchPackagesTool::new(app_context))
  server.register_trait_tool(@tools.GetPackageInfoTool::{  })
  server.register_trait_tool(@tools.GetPackageStructureTool::{  })
  server.register_trait_tool(@tools.QuerySymbolsTool::{  })
  // NEW: Enhanced tools
  server.register_trait_tool(@tools.ListCategoriesTool::{  })
  server.register_trait_tool(@tools.ClearCacheTool::new(app_context))

  // Use task group for concurrency
  @async.with_task_group(async fn(group) {
    // Default to STDIO mode
    if args.length() <= 1 {
      run_stdio_mode(server)
      return
    }
    match args[1] {
      "server" => run_http_mode(server, group)
      _ => run_stdio_mode(server)
    }
  })
}

///|
async fn run_stdio_mode(server : @mcp.MCPServer) -> Unit {
  @stdio.stderr.write("Starting MoonBit MCP Server (STDIO mode)...\n")
  let transport = @mcp.StdioTransport::new()
  server.run(@mcp.AnyTransport::Stdio(transport)) catch {
    e => @stdio.stderr.write("Server error: " + e.to_string() + "\n")
  }
}

///|
async fn run_http_mode(
  server : @mcp.MCPServer,
  group : @async.TaskGroup[Unit],
) -> Unit {
  @stdio.stderr.write("Starting MoonBit MCP Server (HTTP mode)...\n")
  let transport = @mcp.HttpTransport::new(port=4240)
  @stdio.stderr.write("Starting HTTP server listener...\n")
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
  @async.sleep(500)
  @stdio.stderr.write("[HTTP] Starting MCP server loop...\n")
  server.run(@mcp.AnyTransport::Http(transport)) catch {
    e => @stdio.stderr.write("[HTTP] Server error: " + e.to_string() + "\n")
  }
}
