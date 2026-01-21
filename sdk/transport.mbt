///| Transport Abstraction
/// Defines the interface that all MCP transports must implement

///|
/// Transport trait - abstracts communication layer
/// NOTE: This is kept for documentation/interface definition.
/// For dynamic dispatch with async support, we use AnyTransport enum.
pub(open) trait Transport {
  receive(Self) -> String? raise TransportError
  send(Self, String) -> Unit raise TransportError
  send_event(Self, event_type~ : String, data~ : String) -> Unit
  supports_streaming(Self) -> Bool
  close(Self) -> Unit
}

///|
/// Unified Transport Enum
/// Enables async polymorphism since traits don't support async methods well yet
pub(all) enum AnyTransport {
  Stdio(StdioTransport)
  Http(HttpTransport)
}

///|
pub async fn AnyTransport::receive(
  self : AnyTransport,
) -> String? raise TransportError {
  match self {
    Stdio(t) => t.receive()
    Http(t) => t.receive()
  }
}

///|
pub async fn AnyTransport::send(
  self : AnyTransport,
  message : String,
) -> Unit raise TransportError {
  match self {
    Stdio(t) => t.send(message)
    Http(t) => t.send(message)
  }
}

///|
pub async fn AnyTransport::send_event(
  self : AnyTransport,
  event_type~ : String,
  data~ : String,
) -> Unit {
  match self {
    Stdio(t) => t.send_event(event_type~, data~)
    Http(t) => t.send_event(event_type~, data~)
  }
}

///|
pub fn AnyTransport::supports_streaming(self : AnyTransport) -> Bool {
  match self {
    Stdio(t) => t.supports_streaming()
    Http(t) => t.supports_streaming()
  }
}

///|
pub fn AnyTransport::close(self : AnyTransport) -> Unit {
  match self {
    Stdio(t) => t.close()
    Http(t) => t.close()
  }
}

///|
/// Helper: Validate that a string is valid JSON-RPC 2.0
pub fn validate_jsonrpc_message(message : String) -> Result[Unit, MCPError] {
  // Parse to check it's valid JSON
  let json = @json.parse(message) catch {
    _ => return Err(ParseError("Invalid JSON"))
  }

  // Check for required JSON-RPC 2.0 fields
  if json is Object(obj) {
    match obj.get("jsonrpc") {
      Some(String("2.0")) => ()
      _ => return Err(InvalidRequest("Missing or invalid 'jsonrpc' field"))
    }
    let has_method = obj.get("method") is Some(_)
    let has_result = obj.get("result") is Some(_)
    let has_error = obj.get("error") is Some(_)
    if not(has_method || has_result || has_error) {
      return Err(
        InvalidRequest("Must have 'method', 'result', or 'error' field"),
      )
    }
    Ok(())
  } else {
    Err(InvalidRequest("JSON-RPC message must be an object"))
  }
}
