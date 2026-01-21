///| Mooncakes.io API Client - Real HTTP Implementation
/// Fetches package information from mooncakes.io using async HTTP

///|
/// Module information from mooncakes.io
pub struct ModuleInfo {
  name : String
  version : String
  description : String
  keywords : Array[String]
  repository : String
} derive(Show)

///|
/// Package resource information
pub struct PackageResource {
  name : String
  author : String
  version : String
  license : String
  keywords : Array[String]
  description : String
  repository : String
  readme_content : String
} derive(Show)

///|
/// Module index tree structure
pub struct ModuleIndex {
  name : String
  has_package : Bool
  children : Array[(String, ModuleIndex)] // Using array instead of Map for simplicity
} derive(Show)

///|
/// Simple type/value/trait info from package_data.json
pub struct SymbolInfo {
  name : String
  kind : String // "type", "value", "trait", "typealias"
  signature : String
  docstring : String
} derive(Show)

///|
/// Base URL for mooncakes.io API  
let base_url : String = "https://mooncakes.io/assets"

///|
/// Parse ModuleInfo from JSON
fn parse_module_from_json(json : Json) -> ModuleInfo? {
  if json is Object(obj) {
    let name = match obj.get("name") {
      Some(String(s)) => s
      _ => return None
    }
    let version = match obj.get("version") {
      Some(String(s)) => s
      _ => ""
    }
    let description = match obj.get("description") {
      Some(String(s)) => s
      _ => ""
    }
    let repository = match obj.get("repository") {
      Some(String(s)) => s
      _ => ""
    }
    let keywords = match obj.get("keywords") {
      Some(Array(arr)) => {
        let result = Array::new()
        for item in arr {
          if item is String(s) {
            result.push(s)
          }
        }
        result
      }
      _ => []
    }
    Some({ name, version, description, keywords, repository })
  } else {
    None
  }
}

///|
/// Fetch all modules from mooncakes.io using real HTTP
pub async fn fetch_modules_async() -> Array[ModuleInfo] {
  try {
    // Make HTTP GET request to mooncakes.io
    let (response, body) = @http.get(base_url + "/modules.json")
    if response.code != 200 {
      @stdio.stderr.write("HTTP error: " + response.code.to_string() + "\n")
      return get_fallback_modules()
    }

    // Read and parse JSON
    let json = body.json()

    // Parse array of modules
    if json is { "modules": Array(arr), .. } {
      let modules = Array::new()
      for item in arr {
        match parse_module_from_json(item) {
          Some(mod_info) => modules.push(mod_info)
          None => continue
        }
      }
      if modules.length() > 0 {
        return modules
      }
    }

    // Fallback if parsing failed
    @stdio.stderr.write("Failed to parse modules.json, using fallback\n")
    get_fallback_modules()
  } catch {
    err => {
      @stdio.stderr.write("Failed to fetch modules: " + err.to_string() + "\n")
      get_fallback_modules()
    }
  }
}

///|
/// Fallback module data
fn get_fallback_modules() -> Array[ModuleInfo] {
  [
    {
      name: "moonbitlang/x",
      version: "0.4.38",
      description: "MoonBit extended standard library with utilities",
      keywords: ["stdlib", "utility", "extended"],
      repository: "https://github.com/moonbitlang/x",
    },
    {
      name: "moonbitlang/core",
      version: "0.1.0",
      description: "MoonBit core standard library",
      keywords: ["stdlib", "core"],
      repository: "https://github.com/moonbitlang/core",
    },
    {
      name: "moonbitlang/async",
      version: "0.16.1",
      description: "Async runtime for MoonBit with HTTP support",
      keywords: ["async", "http", "network"],
      repository: "https://github.com/moonbitlang/async",
    },
  ]
}

///|
/// Fetch all modules - async version using real HTTP
pub async fn fetch_modules() -> Array[ModuleInfo] {
  fetch_modules_async()
}

///|
/// Search modules - async version
pub async fn search_modules(query : String, limit : Int) -> Array[ModuleInfo] {
  let all_modules = fetch_modules()
  search_in_modules(all_modules, query, limit)
}

///|
/// Internal search logic
fn search_in_modules(
  all_modules : Array[ModuleInfo],
  query : String,
  limit : Int,
) -> Array[ModuleInfo] {
  let matches = Array::new()
  let mut count = 0
  let query_lower = query.to_lower()
  for pkg in all_modules {
    if count >= limit {
      break
    }
    let name_match = pkg.name.to_lower().contains(query_lower)
    let desc_match = pkg.description.to_lower().contains(query_lower)
    let mut keyword_match = false
    for k in pkg.keywords {
      if k.to_lower().contains(query_lower) {
        keyword_match = true
        break
      }
    }
    if name_match || desc_match || keyword_match {
      matches.push(pkg)
      count = count + 1
    }
  }
  matches
}

///|
/// Format module info
pub fn format_module(pkg : ModuleInfo, index : Int) -> String {
  let mut keywords_str = ""
  let mut first = true
  for k in pkg.keywords {
    if first {
      keywords_str = k
      first = false
    } else {
      keywords_str = keywords_str + ", " + k
    }
  }
  index.to_string() +
  ". " +
  pkg.name +
  "@" +
  pkg.version +
  "\n" +
  "   Description: " +
  pkg.description +
  "\n" +
  "   Keywords: " +
  keywords_str +
  "\n" +
  "   URL: https://mooncakes.io/docs/" +
  pkg.name +
  "/\n" +
  "\{index}. \{pkg.name}@\{pkg.version}\n" +
  "   Description: \{pkg.description}\n" +
  "   Keywords: \{keywords_str}\n" +
  "   URL: https://mooncakes.io/docs/\{pkg.name}/\n"
}

///|
/// Format search results
pub fn format_search_results(packages : Array[ModuleInfo]) -> String {
  if packages.length() == 0 {
    "No packages found."
  } else {
    let mut result = "Found " +
      packages.length().to_string() +
      " package(s):\\n\\n"
    let mut i = 0
    for pkg in packages {
      result = result + format_module(pkg, i + 1)
      i = i + 1
      if i < packages.length() {
        result = result + "\\n"
      }
    }
    result
  }
}

///|
/// Fetch package resource (metadata + README)
pub async fn fetch_package_resource(package_name : String) -> PackageResource? {
  try {
    // Format: https://mooncakes.io/assets/{author}/{package}/resource.json
    let url = base_url + "/" + package_name + "/resource.json"
    let (response, body) = @http.get(url)
    if response.code != 200 {
      @stdio.stderr.write(
        "HTTP error fetching resource: " + response.code.to_string() + "\n",
      )
      return None
    }
    let json = body.json()

    // Parse resource.json
    if json is Object(obj) {
      let meta_info = match obj.get("meta_info") {
        Some(Object(meta)) => {
          let name = match meta.get("name") {
            Some(String(s)) => s
            _ => package_name
          }
          let author = match meta.get("author") {
            Some(String(s)) => s
            _ => ""
          }
          let version = match meta.get("version") {
            Some(String(s)) => s
            _ => ""
          }
          let license = match meta.get("license") {
            Some(String(s)) => s
            _ => ""
          }
          let description = match meta.get("description") {
            Some(String(s)) => s
            _ => ""
          }
          let repository = match meta.get("repository") {
            Some(String(s)) => s
            _ => ""
          }
          let keywords = match meta.get("keywords") {
            Some(Array(arr)) => {
              let result = Array::new()
              for item in arr {
                if item is String(s) {
                  result.push(s)
                }
              }
              result
            }
            _ => []
          }
          let readme_content = match obj.get("readme_content") {
            Some(String(s)) => s
            _ => ""
          }
          Some({
            name,
            author,
            version,
            license,
            description,
            repository,
            keywords,
            readme_content,
          })
        }
        _ => None
      }
      meta_info
    } else {
      None
    }
  } catch {
    err => {
      @stdio.stderr.write(
        "Failed to fetch package resource: " + err.to_string() + "\n",
      )
      None
    }
  }
}

///|
/// Format package resource for display
pub fn format_package_resource(resource : PackageResource) -> String {
  let mut keywords_str = ""
  let mut first = true
  for k in resource.keywords {
    if first {
      keywords_str = k
      first = false
    } else {
      keywords_str = keywords_str + ", " + k
    }
  }
  "Package: " +
  resource.name +
  "@" +
  resource.version +
  "\\n" +
  "Author: " +
  resource.author +
  "\\n" +
  "License: " +
  resource.license +
  "\\n" +
  "Description: " +
  resource.description +
  "\\n" +
  "Keywords: " +
  keywords_str +
  "\\n" +
  "Repository: " +
  resource.repository +
  "\\n\\n" +
  "README:\\n" +
  "-------\\n" +
  resource.readme_content
}

///|
/// Fetch module index (package structure)
pub async fn fetch_module_index(package_name : String) -> ModuleIndex? {
  try {
    let url = base_url + "/" + package_name + "/module_index.json"
    let (response, body) = @http.get(url)
    if response.code != 200 {
      @stdio.stderr.write(
        "HTTP error fetching module_index: " + response.code.to_string() + "\n",
      )
      return None
    }
    let json = body.json()
    parse_module_index(json)
  } catch {
    err => {
      @stdio.stderr.write(
        "Failed to fetch module index: " + err.to_string() + "\n",
      )
      None
    }
  }
}

///|
/// Parse ModuleIndex from JSON
fn parse_module_index(json : Json) -> ModuleIndex? {
  if json is Object(obj) {
    let name = match obj.get("name") {
      Some(String(s)) => s
      _ => ""
    }
    let has_package = match obj.get("pkg") {
      Some(Null) | None => false
      Some(_) => true
    }
    let children = match obj.get("childs") {
      Some(Object(childs_obj)) => {
        let result = Array::new()
        for entry in childs_obj {
          let (child_name, child_json) = entry
          match parse_module_index(child_json) {
            Some(child_module) => result.push((child_name, child_module))
            None => continue
          }
        }
        result
      }
      _ => []
    }
    Some({ name, has_package, children })
  } else {
    None
  }
}

///|
/// Format module index tree for display
pub fn format_module_index(mod_idx : ModuleIndex, indent : Int) -> String {
  let prefix = "  ".repeat(indent)
  let pkg_marker = if mod_idx.has_package { " [📦]" } else { "" }
  let mut result = prefix + mod_idx.name + pkg_marker + "\\n"
  for child_entry in mod_idx.children {
    let (_, child) = child_entry
    result = result + format_module_index(child, indent + 1)
  }
  result
}

///|
/// Fetch package data (detailed documentation)
/// URL: https://mooncakes.io/assets/{package}/{subpackage}/package_data.json
pub async fn fetch_package_data(
  package_name : String,
  subpackage : String,
) -> Array[SymbolInfo] {
  try {
    let url = base_url +
      "/" +
      package_name +
      "/" +
      subpackage +
      "/package_data.json"
    let (response, body) = @http.get(url)
    if response.code != 200 {
      @stdio.stderr.write(
        "HTTP error fetching package_data: " + response.code.to_string() + "\n",
      )
      return []
    }
    let json = body.json()
    parse_package_data(json)
  } catch {
    err => {
      @stdio.stderr.write(
        "Failed to fetch package data: " + err.to_string() + "\n",
      )
      []
    }
  }
}

///|
/// Parse package_data.json and extract symbols
fn parse_package_data(json : Json) -> Array[SymbolInfo] {
  let symbols = Array::new()
  if json is Object(obj) {
    // Parse types
    match obj.get("types") {
      Some(Array(types)) =>
        for type_json in types {
          match parse_symbol(type_json, "type") {
            Some(sym) => symbols.push(sym)
            None => continue
          }
        }
      _ => ()
    }

    // Parse values
    match obj.get("values") {
      Some(Array(values)) =>
        for value_json in values {
          match parse_symbol(value_json, "value") {
            Some(sym) => symbols.push(sym)
            None => continue
          }
        }
      _ => ()
    }

    // Parse traits
    match obj.get("traits") {
      Some(Array(traits)) =>
        for trait_json in traits {
          match parse_symbol(trait_json, "trait") {
            Some(sym) => symbols.push(sym)
            None => continue
          }
        }
      _ => ()
    }

    // Parse typealias
    match obj.get("typealias") {
      Some(Array(aliases)) =>
        for alias_json in aliases {
          match parse_symbol(alias_json, "typealias") {
            Some(sym) => symbols.push(sym)
            None => continue
          }
        }
      _ => ()
    }
  }
  symbols
}

///|
/// Parse a single symbol from JSON
fn parse_symbol(json : Json, kind : String) -> SymbolInfo? {
  if json is Object(obj) {
    let name = match obj.get("name") {
      Some(String(s)) => s
      _ => return None
    }
    let signature = match obj.get("signature") {
      Some(String(s)) => s
      _ => ""
    }
    let docstring = match obj.get("docstring") {
      Some(String(s)) => s
      _ => ""
    }
    Some({ name, kind, signature, docstring })
  } else {
    None
  }
}

///|
///\n/// Format symbol info for display
pub fn format_symbol(sym : SymbolInfo) -> String {
  "[" +
  sym.kind +
  "] " +
  sym.name +
  "\\n" +
  "  Signature: " +
  sym.signature +
  "\\n" +
  (if sym.docstring != "" { "  Doc: " + sym.docstring + "\\n" } else { "" })
}
