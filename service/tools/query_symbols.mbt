///| Query symbols (types/values/traits) Tool
/// Query symbols from package documentation

///|
/// Tool schema for query_symbols
pub let query_symbols_schema : Json = try_parse_json(
  @internal_json.json_object([
    ("type", @internal_json.json_string("object")),
    (
      "properties",
      @internal_json.json_object([
        (
          "package",
          @internal_json.json_object([
            ("type", @internal_json.json_string("string")),
            (
              "description",
              @internal_json.json_string(
                "Package name (e.g., 'moonbitlang/async')",
              ),
            ),
          ]),
        ),
        (
          "subpackage",
          @internal_json.json_object([
            ("type", @internal_json.json_string("string")),
            (
              "description",
              @internal_json.json_string("Subpackage path (e.g., 'http')"),
            ),
            ("default", @internal_json.json_string("")),
          ]),
        ),
        (
          "kind",
          @internal_json.json_object([
            ("type", @internal_json.json_string("string")),
            (
              "enum",
              @internal_json.json_array([
                @internal_json.json_string("type"),
                @internal_json.json_string("value"),
                @internal_json.json_string("trait"),
                @internal_json.json_string("typealias"),
                @internal_json.json_string("all"),
              ]),
            ),
            (
              "description",
              @internal_json.json_string("Kind of symbol to query"),
            ),
            ("default", @internal_json.json_string("all")),
          ]),
        ),
        (
          "query",
          @internal_json.json_object([
            ("type", @internal_json.json_string("string")),
            (
              "description",
              @internal_json.json_string(
                "Search query (optional, empty means all)",
              ),
            ),
            ("default", @internal_json.json_string("")),
          ]),
        ),
      ]),
    ),
    (
      "required",
      @internal_json.json_array([@internal_json.json_string("package")]),
    ),
  ]),
)

///|
/// Handler for query_symbols tool
pub async fn query_symbols_handler(
  args : Json,
) -> Result[@sdk.ToolResult, @sdk.MCPError] {
  // Extract package name
  let package_name = match @sdk.extract_string_from_json(args, "package") {
    Some(s) => s
    None => return Err(@sdk.InvalidParams("Missing 'package' parameter"))
  }

  // Extract subpackage (optional, defaults to empty for root package)
  let subpackage = @sdk.extract_string_from_json(args, "subpackage").unwrap_or(
    "",
  )

  // Extract kind filter
  let kind_filter = @sdk.extract_string_from_json(args, "kind").unwrap_or("all")

  // Extract query string
  let query_str = @sdk.extract_string_from_json(args, "query").unwrap_or("")

  // Fetch package data
  // For root packages, try fetching with the package name's last segment
  let subpackage_path = if subpackage == "" {
    // Extract last part of package name (e.g., "moonbitlang/core" -> "core")
    let parts = package_name.split("/").to_array()
    if parts.length() > 0 {
      parts[parts.length() - 1].to_string()
    } else {
      package_name
    }
  } else {
    subpackage
  }
  let symbols = @client.fetch_package_data(package_name, subpackage_path)

  // Filter by kind
  let filtered = Array::new()
  for sym in symbols {
    if kind_filter == "all" || sym.kind == kind_filter {
      if query_str == "" || sym.name.contains(query_str) {
        filtered.push(sym)
      }
    }
  }

  // Format results
  if filtered.length() == 0 {
    Ok(@sdk.ToolResult::success("No symbols found matching the criteria."))
  } else {
    let mut result = "Found " +
      filtered.length().to_string() +
      " symbol(s):\\n\\n"
    for sym in filtered {
      result = result + @client.format_symbol(sym) + "\\n"
    }
    Ok(@sdk.ToolResult::success(result))
  }
}
