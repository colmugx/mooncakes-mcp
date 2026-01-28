///|
/// Clear Cache Tool
pub(all) struct ClearCacheTool {
  ctx : @cache.AppContext
}

///|
pub fn ClearCacheTool::new(ctx : @cache.AppContext) -> ClearCacheTool {
  { ctx, }
}

///|
pub impl @mcp.Tool for ClearCacheTool with name(_) -> String {
  "clear_cache"
}

///|
pub impl @mcp.Tool for ClearCacheTool with description(_) -> String {
  "Clear the package and modules cache"
}

///|
pub impl @mcp.Tool for ClearCacheTool with params(_) -> Array[@mcp.ParamDef] {
  []
}

///|
pub impl @mcp.Tool for ClearCacheTool with execute(self, args : Json) -> @mcp.ToolResult {
  match args {
    Object(_) => {
      self.ctx.clear_all()
      @mcp.ToolResult::text(
        "Cache cleared successfully. Subsequent requests will fetch from network.",
      )
    }
    _ => @mcp.ToolResult::error("Invalid arguments")
  }
}
