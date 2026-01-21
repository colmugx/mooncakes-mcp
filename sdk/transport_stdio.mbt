///| STDIO Transport Implementation
/// Provides stdin/stdout transport for MCP servers
/// Used primarily for Claude Desktop integration

///|
/// STDIO Transport
/// Reads JSON-RPC messages from stdin (line-delimited)
/// Writes JSON-RPC responses to stdout (line-delimited)
pub struct StdioTransport {
  /// Whether the transport has been closed
  mut closed : Bool
} derive(Show)

///|
/// Create a new STDIO transport
pub fn StdioTransport::new() -> StdioTransport {
  { closed: false }
}

///|
/// Implementation of Transport trait for STDIO
pub async fn StdioTransport::receive(
  self : StdioTransport,
) -> String? raise TransportError {
  // Check if already closed
  if self.closed {
    return None
  }

  // Read one line from stdin (catch any IO errors)
  let line_result = @stdio.stdin.read_until("\n") catch {
    e => raise ReadError("Failed to read from stdin: " + e.to_string())
  }
  match line_result {
    None => {
      // EOF reached - clean shutdown
      self.closed = true
      None
    }
    Some(line_view) => {
      // Convert to String and trim whitespace
      let line = line_view.to_string()
      let message = line.trim().to_string()

      // Skip empty lines (keep listening)
      if message.is_empty() {
        // Recursively call to get next non-empty line
        return self.receive()
      }
      Some(message)
    }
  }
}

///|
pub async fn StdioTransport::send(
  self : StdioTransport,
  message : String,
) -> Unit raise TransportError {
  // Check if closed
  if self.closed {
    raise InvalidState("Cannot send on closed transport")
  }

  // Validate message format (optional but good practice)
  match validate_jsonrpc_message(message) {
    Err(e) => raise WriteError("Invalid JSON-RPC message: " + e.message())
    Ok(_) => ()
  }

  // Write to stdout with newline (catch any IO errors)
  @stdio.stdout.write(message + "\n") catch {
    e => raise WriteError("Failed to write to stdout: " + e.to_string())
  }
}

///|
pub fn StdioTransport::send_event(
  _self : StdioTransport,
  event_type~ : String,
  data~ : String,
) -> Unit {
  // STDIO doesn't support server-initiated events
  // This is a no-op - gracefully degrade
  ignore(event_type)
  ignore(data)
  ()
}

///|
pub fn StdioTransport::supports_streaming(_self : StdioTransport) -> Bool {
  // STDIO is request/response only, no streaming
  false
}

///|
pub fn StdioTransport::close(self : StdioTransport) -> Unit {
  if not(self.closed) {
    self.closed = true
  }
}
