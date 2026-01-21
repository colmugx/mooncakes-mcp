///|
/// Simple Tool Registry
/// For POC - stores tools in array, searches linearly
struct ToolEntry {
  name : String
  description : String
  input_schema : Json
  handler : async (Json) -> Result[ToolResult, MCPError]
}

///|
pub struct ToolRegistry {
  tools : Array[ToolEntry]
}

///|
pub fn ToolRegistry::new() -> ToolRegistry {
  { tools: [] }
}

///|
pub fn ToolRegistry::register(
  self : ToolRegistry,
  name : String,
  description : String,
  input_schema : Json,
  handler : async (Json) -> Result[ToolResult, MCPError],
) -> Unit {
  self.tools.push({ name, description, input_schema, handler })
}

///|
pub fn ToolRegistry::list_tools(self : ToolRegistry) -> Array[ToolDefinition] {
  self.tools.map(fn(entry) {
    {
      name: entry.name,
      description: entry.description,
      input_schema: entry.input_schema,
    }
  })
}

///|
pub async fn ToolRegistry::call_tool(
  self : ToolRegistry,
  name : String,
  params : Json,
) -> Result[ToolResult, MCPError] {
  for entry in self.tools {
    if entry.name == name {
      let handler = entry.handler
      return handler(params)
    }
  }
  Err(MethodNotFound("Tool not found: " + name))
}

///|
struct PromptEntry {
  name : String
  description : String?
  arguments : Array[PromptArgument]?
  handler : async (Json?) -> Result[GetPromptResult, MCPError]
}

///|
pub struct PromptRegistry {
  prompts : Array[PromptEntry]
}

///|
pub fn PromptRegistry::new() -> PromptRegistry {
  { prompts: [] }
}

///|
pub fn PromptRegistry::register(
  self : PromptRegistry,
  name : String,
  description : String?,
  arguments : Array[PromptArgument]?,
  handler : async (Json?) -> Result[GetPromptResult, MCPError],
) -> Unit {
  self.prompts.push({ name, description, arguments, handler })
}

///|
pub fn PromptRegistry::list_prompts(self : PromptRegistry) -> Array[Prompt] {
  self.prompts.map(fn(entry) {
    {
      name: entry.name,
      description: entry.description,
      arguments: entry.arguments,
    }
  })
}

///|
pub async fn PromptRegistry::get_prompt(
  self : PromptRegistry,
  name : String,
  arguments : Json?,
) -> Result[GetPromptResult, MCPError] {
  for entry in self.prompts {
    if entry.name == name {
      let handler = entry.handler
      return handler(arguments)
    }
  }
  Err(MethodNotFound("Prompt not found: " + name))
}
