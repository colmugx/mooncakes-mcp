///| Get Package Info Tool - Tool Trait Implementation

///| Fetches package metadata and README from mooncakes.io

///|
/// Get package info tool using the new Tool trait
pub(all) struct GetPackageInfoTool {}

///|
pub impl @mcp.Tool for GetPackageInfoTool with name(_) -> String {
  "get_package_info"
}

///|
pub impl @mcp.Tool for GetPackageInfoTool with description(_) -> String {
  "Get package metadata and README from mooncakes.io (enhanced with features, platforms, installation)"
}

///|
pub impl @mcp.Tool for GetPackageInfoTool with params(_) -> Array[@mcp.ParamDef] {
  [@mcp.string_param("package", "Package name (e.g., 'moonbitlang/async')")]
}

///|
pub impl @mcp.Tool for GetPackageInfoTool with execute(self, args : Json) -> @mcp.ToolResult {
  // Extract package parameter
  let pkg_name = match @mcp.get_string(args, "package") {
    Ok(p) => p
    Err(err) => return err
  }

  // Call async HTTP client to fetch package resource
  match @client.fetch_package_resource(pkg_name) {
    Some(resource) => {
      let text = @client.format_package_resource(resource)
      @mcp.ToolResult::text(text)
    }
    None => {
      // Try to find similar packages
      let all_modules = @client.fetch_modules_async()
      let similar = @client.find_similar_packages(all_modules, pkg_name, 3)
      let error = @error.package_not_found(pkg_name, similar)
      let error_text = format_error(error)
      @mcp.ToolResult::text(error_text)
    }
  }
}

///|
/// Format structured error for display
fn format_error(err : @error.ToolError) -> String {
  let error_code = match err.code {
    @error.PackageNotFound => "PACKAGE_NOT_FOUND"
    @error.NetworkError => "NETWORK_ERROR"
    @error.APIError => "API_ERROR"
    @error.ParseError => "PARSE_ERROR"
  }
  let mut result = "Error: " + error_code + "\n"
  result = result + "Message: " + err.message + "\n"
  result = result + "Suggested Action: " + err.suggested_action + "\n"
  if !err.similar_packages.is_empty() {
    result = result + "\nSimilar Packages:\n"
    let mut i = 1
    for pkg in err.similar_packages {
      result = result + "  " + i.to_string() + ". " + pkg + "\n"
      i = i + 1
    }
  }
  result
}
