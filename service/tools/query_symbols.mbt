///| Query Symbols Tool - Tool Trait Implementation
///| Query symbols (types/values/traits) from package documentation

/// Query symbols tool using the new Tool trait
pub(all) struct QuerySymbolsTool {}

pub impl @mcp.Tool for QuerySymbolsTool with name(
  _
) -> String {
  "query_symbols"
}

pub impl @mcp.Tool for QuerySymbolsTool with description(
  _
) -> String {
  "Query types, values, and traits from package documentation"
}

pub impl @mcp.Tool for QuerySymbolsTool with params(
  _
) -> Array[@mcp.ParamDef] {
  [
    @mcp.string_param(
      "package",
      "Package name (e.g., 'moonbitlang/async')",
    ),
    @mcp.optional_string_param(
      "subpackage",
      "Subpackage path (e.g., 'http')",
    ),
    @mcp.optional_string_param(
      "kind",
      "Kind of symbol to query (type/value/trait/typealias/all)",
    ),
    @mcp.optional_string_param(
      "query",
      "Search query (optional, empty means all)",
    ),
  ]
}

pub impl @mcp.Tool for QuerySymbolsTool with execute(
  self,
  args : Json
) -> @mcp.ToolResult {
  // Extract package parameter
  let pkg_name = match @mcp.get_string(args, "package") {
    Ok(p) => p
    Err(err) => return err
  }

  // Extract optional parameters
  let subpackage = match @mcp.get_optional_string(args, "subpackage") {
    Ok(Some(s)) => s
    Ok(None) => ""
    Err(_) => ""
  }
  let kind_filter = match @mcp.get_optional_string(args, "kind") {
    Ok(Some(s)) => s
    Ok(None) => "all"
    Err(_) => "all"
  }
  let query_str = match @mcp.get_optional_string(args, "query") {
    Ok(Some(s)) => s
    Ok(None) => ""
    Err(_) => ""
  }

  // For root packages, extract last segment of package name
  let subpackage_path = if subpackage == "" {
    let parts = pkg_name.split("/").to_array()
    if parts.length() > 0 {
      parts[parts.length() - 1].to_string()
    } else {
      pkg_name
    }
  } else {
    subpackage
  }

  // Call async HTTP client to fetch package data
  let symbols = @client.fetch_package_data(pkg_name, subpackage_path)

  // Filter by kind and query
  let filtered = Array::new()
  for sym in symbols {
    let kind_match = kind_filter == "all" || sym.kind == kind_filter
    let query_match = query_str == "" || sym.name.contains(query_str)
    if kind_match && query_match {
      filtered.push(sym)
    }
  }

  // Format results
  if filtered.length() == 0 {
    @mcp.ToolResult::text("No symbols found matching the criteria.")
  } else {
    let mut result = "Found " + filtered.length().to_string() + " symbol(s):\\n\\n"
    for sym in filtered {
      result = result + @client.format_symbol(sym) + "\\n"
    }
    @mcp.ToolResult::text(result)
  }
}
