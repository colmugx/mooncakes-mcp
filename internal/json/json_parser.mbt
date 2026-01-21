///| JSON parsing using stdlib - replaces hand-rolled parser
/// Uses MoonBit's builtin Json type for robust parsing

///|
/// MCP Request structure using stdlib Json
pub struct MCPRequest {
  method_name : String
  id : Int
  params : Json // Now using stdlib Json type
} derive(Show)

///|
/// Parse incoming JSON-RPC request using stdlib
pub fn parse_request(json_string : String) -> MCPRequest? {
  // Use stdlib JSON parser with error handling
  let json = @json.parse(json_string) catch {
    _ => return None // Parse error - return None
  }

  // Extract using pattern matching (modern MoonBit style)
  if json is Object(obj) {
    // Extract method field
    let method_name = match obj.get("method") {
      Some(String(m)) => Some(m)
      _ => None
    }

    // Extract id field
    let id = match obj.get("id") {
      Some(Number(n, ..)) => Some(n.to_int())
      _ => None
    }

    // Extract params (keep as Json for flexible handling)
    let params = obj.get("params").unwrap_or(null)

    // Build request if we have required fields
    match (method_name, id) {
      (Some(m), Some(i)) => Some({ method_name: m, id: i, params })
      _ => None
    }
  } else {
    None
  }
}

///|
/// Extract string field from Json object
pub fn extract_string_from_json(json : Json, field : String) -> String? {
  if json is Object(obj) {
    match obj.get(field) {
      Some(String(s)) => Some(s)
      _ => None
    }
  } else {
    None
  }
}

///|
/// Extract integer field from Json object
pub fn extract_int_from_json(json : Json, field : String) -> Int? {
  if json is Object(obj) {
    match obj.get(field) {
      Some(Number(n, ..)) => Some(n.to_int())
      _ => None
    }
  } else {
    None
  }
}

///|
/// Extract nested field from params.arguments.field
/// Used for tool calls like: {"name": "search_packages", "arguments": {"query": "..."}}
pub fn extract_param_argument(params : Json, arg_name : String) -> String? {
  if params is Object(params_obj) {
    // Get the "arguments" field
    match params_obj.get("arguments") {
      Some(Object(args_obj)) =>
        // Get the field from arguments
        match args_obj.get(arg_name) {
          Some(String(s)) => Some(s)
          _ => None
        }
      _ => None
    }
  } else {
    None
  }
}
