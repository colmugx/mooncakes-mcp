///| get_package_structure Tool
/// Fetches package module tree structure from mooncakes.io

///|
/// Tool schema for get_package_structure
pub let get_package_structure_schema : Json = try_parse_json(
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
      ]),
    ),
    (
      "required",
      @internal_json.json_array([@internal_json.json_string("package")]),
    ),
  ]),
)

///|
/// Handler for get_package_structure tool
pub async fn get_package_structure_handler(
  args : Json,
) -> Result[@sdk.ToolResult, @sdk.MCPError] {
  // Extract package name
  let package_name = match @sdk.extract_string_from_json(args, "package") {
    Some(s) => s
    None => return Err(@sdk.InvalidParams("Missing 'package' parameter"))
  }

  // Fetch module index
  match @client.fetch_module_index(package_name) {
    Some(module_index) => {
      let text = "Package Structure: " +
        package_name +
        "\\n" +
        "==================\\n\\n" +
        @client.format_module_index(module_index, 0)
      Ok(@sdk.ToolResult::success(text))
    }
    None =>
      Ok(
        @sdk.ToolResult::error(
          "Failed to fetch package structure: " + package_name,
        ),
      )
  }
}
