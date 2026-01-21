///| Core MCP Protocol Types
/// Defines data structures for the Model Context Protocol
/// Based on the MCP specification: https://modelcontextprotocol.io/docs

///|
/// MCP Server Information
/// Returned during the initialize handshake
pub struct ServerInfo {
  /// Server name (e.g., "moonbit-doc-mcp")
  name : String
  /// Server version (semver format)
  version : String
} derive(Show, Eq)

///|
/// Server capabilities
/// Indicates which MCP features the server supports
pub struct ServerCapabilities {
  /// Tool support configuration
  tools : ToolCapabilities?
  /// Resource support configuration
  resources : ResourceCapabilities?
  /// Prompt support configuration
  prompts : PromptCapabilities?
} derive(Show, Eq)

///|
/// Tool capabilities
pub struct ToolCapabilities {
  /// Whether the server will send tools/list_changed notifications
  list_changed : Bool
} derive(Show, Eq)

///|
/// Resource capabilities
pub struct ResourceCapabilities {
  /// Whether resources can be subscribed to
  subscribe : Bool
  /// Whether the server will send resources/list_changed notifications
  list_changed : Bool
} derive(Show, Eq)

///|
/// Prompt capabilities
pub struct PromptCapabilities {
  /// Whether the server will send prompts/list_changed notifications
  list_changed : Bool
} derive(Show, Eq)

///|
/// Tool definition
/// Describes a tool that the MCP server provides
pub struct ToolDefinition {
  /// Unique tool name (e.g., "search_packages")
  name : String
  /// Human-readable description
  description : String
  /// JSON Schema for input parameters
  input_schema : Json
} derive(Show, Eq)

///|
/// Tool execution result
/// Returned after executing a tool
pub struct ToolResult {
  /// Content items (text, image, etc.)
  content : Array[ContentItem]
  /// Whether this is an error result
  is_error : Bool
} derive(Show, Eq)

///|
/// Content item in tool results
/// Can be text, image, or resource reference
pub enum ContentItem {
  /// Plain text content
  Text(String)
  /// Image content (base64 encoded)
  Image(String, mime_type~ : String)
  /// Resource reference
  Resource(String)
} derive(Show, Eq)

///|
/// Helper: Create a successful text result
pub fn ToolResult::success(text : String) -> ToolResult {
  { content: [Text(text)], is_error: false }
}

///|
/// Helper: Create an error result
pub fn ToolResult::error(message : String) -> ToolResult {
  { content: [Text(message)], is_error: true }
}

///|
/// JSON-RPC 2.0 Request
/// Incoming message from client
pub struct JsonRpcRequest {
  /// JSON-RPC version (always "2.0")
  jsonrpc : String
  /// Request ID (for matching response)
  id : Int
  /// Method name (e.g., "initialize", "tools/call")
  method_name : String
  /// Method parameters
  params : Json
} derive(Show, Eq)

///|
/// JSON-RPC 2.0 Response
/// Outgoing message to client
pub struct JsonRpcResponse {
  /// JSON-RPC version (always "2.0")
  jsonrpc : String
  /// Request ID (matches incoming request)
  id : Int
  /// Result (if success) or error (if failure)
  result : Result[Json, JsonRpcError]
} derive(Show, Eq)

///|
/// JSON-RPC 2.0 Error object
pub struct JsonRpcError {
  /// Error code (e.g., -32601 for method not found)
  code : Int
  /// Error message
  message : String
  /// Optional additional data
  data : Json?
} derive(Show, Eq)

///|
/// Prompt argument definition
pub struct PromptArgument {
  name : String
  description : String?
  required : Bool?
} derive(Show, Eq)

///|
/// Prompt definition
pub struct Prompt {
  name : String
  description : String?
  arguments : Array[PromptArgument]?
} derive(Show, Eq)

///|
/// Prompt message
pub struct PromptMessage {
  role : String
  content : ContentItem
} derive(Show, Eq)

///|
/// Result of prompts/get
pub struct GetPromptResult {
  description : String?
  messages : Array[PromptMessage]
} derive(Show, Eq)

///|
/// Helper: Convert Json to JsonRpcRequest
pub fn JsonRpcRequest::from_json(
  json : Json,
) -> Result[JsonRpcRequest, MCPError] {
  if json is Object(obj) {
    // Extract jsonrpc version
    let jsonrpc = match obj.get("jsonrpc") {
      Some(String("2.0")) => "2.0"
      _ => return Err(InvalidRequest("Missing or invalid 'jsonrpc' field"))
    }

    // Extract id
    let id = match obj.get("id") {
      Some(Number(n, ..)) => n.to_int()
      _ => return Err(InvalidRequest("Missing or invalid 'id' field"))
    }

    // Extract method
    let method_name = match obj.get("method") {
      Some(String(m)) => m
      _ => return Err(InvalidRequest("Missing or invalid 'method' field"))
    }

    // Extract params (optional)
    let params = obj.get("params").unwrap_or(null)
    Ok({ jsonrpc, id, method_name, params })
  } else {
    Err(InvalidRequest("Request must be a JSON object"))
  }
}
