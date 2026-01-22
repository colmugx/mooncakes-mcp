///| Search Packages Tool - New Tool Trait Implementation
///| Uses the modern mcp::Tool trait API

/// Search packages tool using the new Tool trait
pub(all) struct SearchPackagesTool {}

pub impl @mcp.Tool for SearchPackagesTool with name(
  _
) -> String {
  "search_packages"
}

pub impl @mcp.Tool for SearchPackagesTool with description(
  _
) -> String {
  "Search for MoonBit packages from mooncakes.io registry"
}

pub impl @mcp.Tool for SearchPackagesTool with params(
  _
) -> Array[@mcp.ParamDef] {
  [
    @mcp.string_param(
      "query",
      "Search query to filter packages",
    ),
    @mcp.optional_number_param(
      "limit",
      "Maximum number of results to return (default: 10)",
    ),
  ]
}

pub impl @mcp.Tool for SearchPackagesTool with execute(
  self,
  args : Json
) -> @mcp.ToolResult {
  // Extract query parameter
  let query = match @mcp.get_string(args, "query") {
    Ok(q) => q
    Err(err) => return err
  }

  // Extract optional limit parameter (default to 10)
  let limit = match @mcp.get_optional_number(args, "limit") {
    Ok(Some(n)) => n.to_int()
    Ok(None) => 10
    Err(_) => 10
  }

  // Call async HTTP client to search packages
  let packages = @client.search_modules(query, limit)
  let result_text = @client.format_search_results(packages)

  @mcp.ToolResult::text(result_text)
}

