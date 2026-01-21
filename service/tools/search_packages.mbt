///|
/// Search Packages Tool implementation (async)
pub async fn search_packages_handler(
  params : Json,
) -> Result[@sdk.ToolResult, @sdk.MCPError] {
  let query = match @sdk.extract_string_from_json(params, "query") {
    Some(q) => q
    None => return Err(@sdk.InvalidParams("Missing 'query' parameter"))
  }
  let limit = @sdk.extract_int_from_json(params, "limit").unwrap_or(10)
  let packages = @client.search_modules(query, limit)
  let result_text = @client.format_search_results(packages)
  Ok(@sdk.ToolResult::success(result_text))
}

///|
/// Shared helper to parse JSON string back to Json type
fn try_parse_json(s : String) -> Json {
  @json.parse(s) catch {
    _ => Json::null()
  }
}

///|
pub let search_packages_schema : Json = try_parse_json(
  @internal_json.json_object([
    ("type", @internal_json.json_string("object")),
    (
      "properties",
      @internal_json.json_object([
        (
          "query",
          @internal_json.json_object([
            ("type", @internal_json.json_string("string")),
            ("description", @internal_json.json_string("Search query")),
          ]),
        ),
        (
          "limit",
          @internal_json.json_object([
            ("type", @internal_json.json_string("integer")),
            ("description", @internal_json.json_string("Max results")),
            ("default", @internal_json.json_number(10)),
          ]),
        ),
      ]),
    ),
    (
      "required",
      @internal_json.json_array([@internal_json.json_string("query")]),
    ),
  ]),
)
