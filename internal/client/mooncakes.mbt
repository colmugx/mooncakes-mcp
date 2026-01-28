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
/// Enhanced package resource information
pub struct PackageResource {
  name : String
  author : String
  version : String
  license : String
  keywords : Array[String]
  description : String
  repository : String
  readme_content : String
  // Enhanced fields
  platforms : Array[String]
  features : Array[String]
  installation : String
  usage : String
} derive(Show)

///|
/// Module index tree structure
pub struct ModuleIndex {
  name : String
  has_package : Bool
  children : Array[(String, ModuleIndex)] // Using array instead of Map for simplicity
} derive(Show)

///|
/// Enhanced symbol info from package_data.json
pub struct SymbolInfo {
  name : String
  kind : String // "type", "value", "trait", "typealias"
  signature : String
  docstring : String
  // Enhanced fields
  is_exported : Bool
  is_deprecated : Bool
  is_async : Bool
  module : String
} derive(Show)

///|
/// Base URL for mooncakes.io API  
let base_url : String = "https://mooncakes.io/assets"

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
/// Search modules - async version (uses enhanced search)
pub async fn search_modules(query : String, limit : Int) -> Array[ModuleInfo] {
  let all_modules = fetch_modules_async()
  let results = enhanced_search(all_modules, query, limit)
  results.results
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

  // Use concatenation to avoid interpolation issues
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
  "/\n"
}

///|
/// Format search results (enhanced)
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
/// Fetch package resource (metadata + README) - Enhanced
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

          // Parse enhanced information from README
          let parsed_readme = parse_readme(readme_content)
          let platforms = detect_platforms(readme_content)
          Some({
            name,
            author,
            version,
            license,
            description,
            repository,
            keywords,
            readme_content,
            platforms,
            features: parsed_readme.features,
            installation: parsed_readme.installation,
            usage: parsed_readme.usage,
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
/// Format package resource for display (enhanced)
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
  let mut features_str = ""
  let mut ffirst = true
  for f in resource.features {
    if ffirst {
      features_str = "- " + f
      ffirst = false
    } else {
      features_str = features_str + "\n- " + f
    }
  }
  let mut platforms_str = ""
  let mut pfirst = true
  for p in resource.platforms {
    if pfirst {
      platforms_str = p
      pfirst = false
    } else {
      platforms_str = platforms_str + ", " + p
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
  "Platforms: " +
  platforms_str +
  "\\n" +
  "Repository: " +
  resource.repository +
  "\\n\\n" +
  "Features:\\n" +
  features_str +
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
/// Fetch package data (detailed documentation) - Enhanced
/// URL: https://mooncakes.io/assets/{package}/{subpackage}/package_data.json
/// Tries multiple URL patterns with fallback logic
pub async fn fetch_package_data(
  package_name : String,
  subpackage : String,
) -> Array[SymbolInfo] {
  try {
    // First try: with subpackage path
    let url = base_url +
      "/" +
      package_name +
      "/" +
      subpackage +
      "/package_data.json"
    let (response, body) = @http.get(url)
    if response.code == 200 {
      let json = body.json()
      return parse_package_data(json, package_name + "/" + subpackage)
    }

    // Fallback: try without subpackage path (root package)
    if subpackage != "" {
      let fallback_url = base_url + "/" + package_name + "/package_data.json"
      let (fallback_response, fallback_body) = @http.get(fallback_url)
      if fallback_response.code == 200 {
        let json = fallback_body.json()
        return parse_package_data(json, package_name)
      }
    }
    @stdio.stderr.write(
      "HTTP error fetching package_data: " + response.code.to_string() + "\n",
    )
    []
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
/// Format symbol info for display (enhanced)
pub fn format_symbol(sym : SymbolInfo) -> String {
  let deprecated_marker = if sym.is_deprecated { " [DEPRECATED]" } else { "" }
  let async_marker = if sym.is_async { " [async]" } else { "" }

  // Use concatenation to avoid interpolation issues
  "[" +
  sym.kind +
  deprecated_marker +
  async_marker +
  "] " +
  sym.name +
  "\\n" +
  "  Module: " +
  sym.module +
  "\\n" +
  "  Signature: " +
  sym.signature +
  "\\n" +
  (if sym.docstring != "" { "  Doc: " + sym.docstring + "\\n" } else { "" })
}
