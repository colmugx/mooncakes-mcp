///| get_package_info Tool
/// Fetches package metadata and README from mooncakes.io

///|
/// Tool schema for get_package_info  
pub let get_package_info_schema : Json = try_parse_json(
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
/// Handler for get_package_info tool
pub async fn get_package_info_handler(
  args : Json,
) -> Result[@sdk.ToolResult, @sdk.MCPError] {
  // Extract package name
  let package_name = match @sdk.extract_string_from_json(args, "package") {
    Some(s) => s
    None => return Err(@sdk.InvalidParams("Missing 'package' parameter"))
  }

  // Fetch package resource
  match @client.fetch_package_resource(package_name) {
    Some(resource) => {
      let text = @client.format_package_resource(resource)
      Ok(@sdk.ToolResult::success(text))
    }
    None =>
      Ok(
        @sdk.ToolResult::error(
          "Package not found or failed to fetch: " + package_name,
        ),
      )
  }
}
