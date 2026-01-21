///|
/// MCP Server Core
/// Generic server that works with any transport
pub struct MCPServer {
  name : String
  version : String
  registry : ToolRegistry
}

///|
pub fn MCPServer::new(name : String, version : String) -> MCPServer {
  { name, version, registry: ToolRegistry::new() }
}

///|
pub fn MCPServer::register_tool(
  self : MCPServer,
  name : String,
  description : String,
  input_schema : Json,
  handler : async (Json) -> Result[ToolResult, MCPError],
) -> Unit {
  self.registry.register(name, description, input_schema, handler)
}

///|
fn handle_initialize(server : MCPServer, id : Int) -> String {
  let tools_cap = json_object([("listChanged", json_bool(true))])
  let capabilities = json_object([("tools", tools_cap)])
  let server_info = json_object([
    ("name", json_string(server.name)),
    ("version", json_string(server.version)),
  ])
  let result = json_object([
    ("protocolVersion", json_string("2025-06-18")),
    ("capabilities", capabilities),
    ("serverInfo", server_info),
  ])
  jsonrpc_success(id, result)
}

///|
fn handle_tools_list(server : MCPServer, id : Int) -> String {
  let tools = server.registry.list_tools()
  let tool_jsons = tools.map(fn(tool) {
    json_object([
      ("name", json_string(tool.name)),
      ("description", json_string(tool.description)),
      ("inputSchema", tool.input_schema.stringify()),
    ])
  })
  let result = json_object([("tools", json_array(tool_jsons))])
  jsonrpc_success(id, result)
}

///|
async fn handle_tools_call(
  server : MCPServer,
  id : Int,
  params : Json,
) -> String {
  let tool_name = extract_string_from_json(params, "name")
  match tool_name {
    None => jsonrpc_error(id, -32602, "Missing 'name' parameter")
    Some(name) => {
      let arguments = if params is Object(obj) {
        obj.get("arguments").unwrap_or(null)
      } else {
        null
      }
      match server.registry.call_tool(name, arguments) {
        Ok(tool_result) => {
          let content_items = tool_result.content.map(fn(item) {
            match item {
              Text(text) =>
                json_object([
                  ("type", json_string("text")),
                  ("text", json_string(text)),
                ])
              Image(data, mime_type~) =>
                json_object([
                  ("type", json_string("image")),
                  ("data", json_string(data)),
                  ("mimeType", json_string(mime_type)),
                ])
              Resource(uri) =>
                json_object([
                  ("type", json_string("resource")),
                  ("uri", json_string(uri)),
                ])
            }
          })
          let result = json_object([
            ("content", json_array(content_items)),
            ("isError", json_bool(tool_result.is_error)),
          ])
          jsonrpc_success(id, result)
        }
        Err(e) => jsonrpc_error(id, e.to_error_code(), e.message())
      }
    }
  }
}

///|
pub async fn MCPServer::handle_request(
  self : MCPServer,
  request_json : String,
) -> String {
  let parsed = @json.parse(request_json) catch {
    _ => return jsonrpc_error(0, -32700, "Parse error")
  }
  match JsonRpcRequest::from_json(parsed) {
    Err(e) => jsonrpc_error(0, e.to_error_code(), e.message())
    Ok(request) =>
      match request.method_name {
        "initialize" => handle_initialize(self, request.id)
        "tools/list" => handle_tools_list(self, request.id)
        "tools/call" => handle_tools_call(self, request.id, request.params)
        _ =>
          jsonrpc_error(
            request.id,
            -32601,
            "Method not found: " + request.method_name,
          )
      }
  }
}

///|
pub async fn MCPServer::run(
  self : MCPServer,
  transport : AnyTransport,
) -> Unit raise TransportError {
  while true {
    match transport.receive() {
      None => {
        transport.close()
        break
      }
      Some(message) => {
        let response = self.handle_request(message) catch {
          _ => jsonrpc_error(0, -32603, "Internal server error")
        }
        transport.send(response)
      }
    }
  }
}
