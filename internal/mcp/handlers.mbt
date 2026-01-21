///| MCP Protocol Handlers
/// Implements JSON-RPC methods for Model Context Protocol

///|
/// Handle initialize request
/// Returns server capabilities and version information
pub fn handle_initialize(id : Int) -> String {
  let capabilities = @json.json_object([
    ("tools", @json.json_object([("listChanged", @json.json_bool(true))])),
  ])
  let server_info = @json.json_object([
    ("name", @json.json_string("moonbit-mcp-server")),
    ("version", @json.json_string("0.2.0")),
  ])
  let result = @json.json_object([
    ("protocolVersion", @json.json_string("2024-11-05")),
    ("capabilities", capabilities),
    ("serverInfo", server_info),
  ])
  @json.jsonrpc_success(id, result)
}

///|
/// Handle tools/list request
/// Returns list of available MCP tools
pub fn handle_tools_list(id : Int) -> String {
  // Build search_packages tool schema
  let search_tool_input_schema = @json.json_object([
    ("type", @json.json_string("object")),
    (
      "properties",
      @json.json_object([
        (
          "query",
          @json.json_object([
            ("type", @json.json_string("string")),
            (
              "description",
              @json.json_string("Search query for package name or description"),
            ),
          ]),
        ),
        (
          "limit",
          @json.json_object([
            ("type", @json.json_string("integer")),
            (
              "description",
              @json.json_string("Maximum number of results to return"),
            ),
            ("default", @json.json_number(10)),
          ]),
        ),
      ]),
    ),
    ("required", @json.json_array([@json.json_string("query")])),
  ])
  let search_tool = @json.json_object([
    ("name", @json.json_string("search_packages")),
    (
      "description",
      @json.json_string("Search for MoonBit packages on mooncakes.io"),
    ),
    ("inputSchema", search_tool_input_schema),
  ])
  let tools_array = @json.json_array([search_tool])
  let result = @json.json_object([("tools", tools_array)])
  @json.jsonrpc_success(id, result)
}

///|
/// Handle tools/call request (synchronous version)
/// Executes the requested tool and returns results
pub async fn handle_tools_call(
  id : Int,
  tool_name : String,
  query : String,
) -> String {
  if tool_name == "search_packages" {
    // Execute search
    let packages = @client.search_modules(query, 10)
    let result_text = @client.format_search_results(packages)

    // Build MCP tool response with content array
    let content_item = @json.json_object([
      ("type", @json.json_string("text")),
      ("text", @json.json_string(result_text)),
    ])
    let result = @json.json_object([
      ("content", @json.json_array([content_item])),
    ])
    @json.jsonrpc_success(id, result)
  } else {
    @json.jsonrpc_error(id, -32601, "Tool not found: " + tool_name)
  }
}

///|
/// Handle tools/call request (async version)
/// Executes the requested tool using async HTTP
pub async fn handle_tools_call_async(
  id : Int,
  tool_name : String,
  query : String,
) -> String {
  if tool_name == "search_packages" {
    // Execute async search
    let packages = @client.search_modules(query, 10)
    let result_text = @client.format_search_results(packages)

    // Build MCP tool response
    let content_item = @json.json_object([
      ("type", @json.json_string("text")),
      ("text", @json.json_string(result_text)),
    ])
    let result = @json.json_object([
      ("content", @json.json_array([content_item])),
    ])
    @json.jsonrpc_success(id, result)
  } else {
    @json.jsonrpc_error(id, -32601, "Tool not found: " + tool_name)
  }
}

///|
/// Route request to appropriate handler (synchronous)
pub async fn route_request(request : @json.MCPRequest) -> String {
  match request.method_name {
    "initialize" => handle_initialize(request.id)
    "tools/list" => handle_tools_list(request.id)
    "tools/call" => {
      // Extract tool name and query from params (now using Json type)
      let tool_name = @json.extract_string_from_json(request.params, "name")
      let query = @json.extract_param_argument(request.params, "query")
      match (tool_name, query) {
        (Some(name), Some(q)) => handle_tools_call(request.id, name, q)
        _ =>
          @json.jsonrpc_error(
            request.id,
            -32602,
            "Invalid params: missing name or query",
          )
      }
    }
    _ =>
      @json.jsonrpc_error(
        request.id,
        -32601,
        "Method not found: " + request.method_name,
      )
  }
}

///|
/// Route request to appropriate handler (async)
pub async fn route_request_async(request : @json.MCPRequest) -> String {
  match request.method_name {
    "initialize" => handle_initialize(request.id)
    "tools/list" => handle_tools_list(request.id)
    "tools/call" => {
      // Extract tool name and query from params (now using Json type)
      let tool_name = @json.extract_string_from_json(request.params, "name")
      let query = @json.extract_param_argument(request.params, "query")
      match (tool_name, query) {
        (Some(name), Some(q)) => handle_tools_call_async(request.id, name, q)
        _ =>
          @json.jsonrpc_error(
            request.id,
            -32602,
            "Invalid params: missing name or query",
          )
      }
    }
    _ =>
      @json.jsonrpc_error(
        request.id,
        -32601,
        "Method not found: " + request.method_name,
      )
  }
}
