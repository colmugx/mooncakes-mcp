///| Error Types for MCP Tools

///| Provides structured error types and error constructors

///|
/// Error type enumeration for MCP tool errors
pub(all) enum ErrorType {
  PackageNotFound
  NetworkError
  APIError
  ParseError
}

///|
/// Structured error response for MCP tools
pub(all) struct ToolError {
  code : ErrorType
  message : String
  suggested_action : String
  similar_packages : Array[String]
}

///|
/// Create a package not found error
pub fn package_not_found(
  pkg_name : String,
  similar : Array[String],
) -> ToolError {
  {
    code: PackageNotFound,
    message: "Package '" + pkg_name + "' not found",
    suggested_action: "Use search_packages to find alternatives",
    similar_packages: similar,
  }
}

///|
/// Create a network error
pub fn network_error(url : String) -> ToolError {
  {
    code: NetworkError,
    message: "Failed to connect to " + url,
    suggested_action: "Retry the request or check network connectivity",
    similar_packages: [],
  }
}

///|
/// Create an API error
pub fn api_error(url : String, detail : String) -> ToolError {
  {
    code: APIError,
    message: "API error from " + url + ": " + detail,
    suggested_action: "Retry the request or check mooncakes.io status",
    similar_packages: [],
  }
}

///|
/// Create a parse error
pub fn parse_error(source : String, detail : String) -> ToolError {
  {
    code: ParseError,
    message: "Failed to parse " + source + ": " + detail,
    suggested_action: "Check the input format and try again",
    similar_packages: [],
  }
}

///|
/// Create a generic error with custom message
pub fn generic_error(
  error_type : ErrorType,
  message : String,
  suggested : String,
) -> ToolError {
  {
    code: error_type,
    message,
    suggested_action: suggested,
    similar_packages: [],
  }
}
