///| Get Package Info Tool - Tool Trait Implementation
///| Fetches package metadata and README from mooncakes.io

/// Get package info tool using the new Tool trait
pub(all) struct GetPackageInfoTool {}

pub impl @mcp.Tool for GetPackageInfoTool with name(
  _
) -> String {
  "get_package_info"
}

pub impl @mcp.Tool for GetPackageInfoTool with description(
  _
) -> String {
  "Get package metadata and README from mooncakes.io"
}

pub impl @mcp.Tool for GetPackageInfoTool with params(
  _
) -> Array[@mcp.ParamDef] {
  [
    @mcp.string_param(
      "package",
      "Package name (e.g., 'moonbitlang/async')",
    ),
  ]
}

pub impl @mcp.Tool for GetPackageInfoTool with execute(
  self,
  args : Json
) -> @mcp.ToolResult {
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
    None => @mcp.ToolResult::error("Package not found or failed to fetch: " + pkg_name)
  }
}
