///| Search Packages Tool - Enhanced Tool Trait Implementation

///| Uses the modern mcp::Tool trait API with intelligent search

///|
/// Search packages tool using the new Tool trait
pub(all) struct SearchPackagesTool {
  ctx : @cache.AppContext
}

///|
pub fn SearchPackagesTool::new(ctx : @cache.AppContext) -> SearchPackagesTool {
  { ctx, }
}

///|
pub impl @mcp.Tool for SearchPackagesTool with name(_) -> String {
  "search_packages"
}

///|
pub impl @mcp.Tool for SearchPackagesTool with description(_) -> String {
  "Search for MoonBit packages from mooncakes.io registry (enhanced with scoring and suggestions)"
}

///|
pub impl @mcp.Tool for SearchPackagesTool with params(_) -> Array[@mcp.ParamDef] {
  [
    @mcp.string_param("query", "Search query to filter packages"),
    @mcp.optional_number_param(
      "limit", "Maximum number of results to return (default: 10)",
    ),
  ]
}

///|
pub impl @mcp.Tool for SearchPackagesTool with execute(self, args : Json) -> @mcp.ToolResult {
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

  // Check cache first
  let cache_key = "search:" + query + ":" + limit.to_string()
  match self.ctx.get_modules(cache_key) {
    Some(cached) => {
      // Return cached results with warning
      let mut result = @cache.cache_warning()
      result = result + "Query: '" + query + "'\n"
      result = result +
        "Found " +
        cached.length().to_string() +
        " result(s)\n\n"
      if cached.length() > 0 {
        result = result + "Results:\n"
        result = result + @client.format_search_results(cached)
      }
      return @mcp.ToolResult::text(result)
    }
    None => ()
  }

  // Call async HTTP client to search packages
  let search_results = @client.search_modules(query, limit)

  // Store in cache for future requests
  self.ctx.set_modules(cache_key, search_results)

  // Format results (no cache warning for fresh data)
  let mut result = ""
  result = result + "Query: '" + query + "'\n"
  result = result +
    "Found " +
    search_results.length().to_string() +
    " result(s)\n\n"
  if search_results.length() > 0 {
    result = result + "Results:\n"
    result = result + @client.format_search_results(search_results)
  } else {
    result = result +
      (
        #|No results found.
        #|
        #|Try these keywords:
        #|  - json, http, time, crypto, encoding
        #|  - cli, testing, logging, math, format
        #|  - image, audio, compression
        #|
        #|Or use list_categories to browse packages by category
      )
  }
  @mcp.ToolResult::text(result)
}
