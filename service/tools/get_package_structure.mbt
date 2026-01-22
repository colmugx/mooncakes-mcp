///| Get Package Structure Tool - Tool Trait Implementation
///| Fetches package module tree structure from mooncakes.io

/// Get package structure tool using the new Tool trait
pub(all) struct GetPackageStructureTool {}

pub impl @mcp.Tool for GetPackageStructureTool with name(
  _
) -> String {
  "get_package_structure"
}

pub impl @mcp.Tool for GetPackageStructureTool with description(
  _
) -> String {
  "Get package module tree structure from mooncakes.io"
}

pub impl @mcp.Tool for GetPackageStructureTool with params(
  _
) -> Array[@mcp.ParamDef] {
  [
    @mcp.string_param(
      "package",
      "Package name (e.g., 'moonbitlang/async')",
    ),
  ]
}

pub impl @mcp.Tool for GetPackageStructureTool with execute(
  self,
  args : Json
) -> @mcp.ToolResult {
  // Extract package parameter
  let pkg_name = match @mcp.get_string(args, "package") {
    Ok(p) => p
    Err(err) => return err
  }

  // Call async HTTP client to fetch module index
  match @client.fetch_module_index(pkg_name) {
    Some(module_index) => {
      let text = "Package Structure: " +
        pkg_name +
        "\\n" +
        "==================\\n\\n" +
        @client.format_module_index(module_index, 0)
      @mcp.ToolResult::text(text)
    }
    None => @mcp.ToolResult::error("Failed to fetch package structure: " + pkg_name)
  }
}
