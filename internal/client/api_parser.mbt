///|
pub fn parse_module_from_json(json : Json) -> ModuleInfo? {
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
pub fn parse_module_index(json : Json) -> ModuleIndex? {
  if json is Object(obj) {
    let name = match obj.get("name") {
      Some(String(s)) => s
      _ => ""
    }
    let has_package = match obj.get("package") {
      Some(Null) | None => false
      Some(_) => true
    }
    let children = match obj.get("childs") {
      Some(Array(childs_arr)) => {
        let result = Array::new()
        for child_json in childs_arr {
          match parse_module_index(child_json) {
            Some(child_module) =>
              // Use the name from the parsed module as key
              result.push((child_module.name, child_module))
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
fn parse_package_data(json : Json, module : String) -> Array[SymbolInfo] {
  let symbols = Array::new()
  if json is Object(obj) {
    // Parse types
    match obj.get("types") {
      Some(Array(types)) =>
        for type_json in types {
          match parse_symbol(type_json, "type", module) {
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
          match parse_symbol(value_json, "value", module) {
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
          match parse_symbol(trait_json, "trait", module) {
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
          match parse_symbol(alias_json, "typealias", module) {
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
pub fn parse_symbol(json : Json, kind : String, module : String) -> SymbolInfo? {
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

    // Infer enhanced information
    let is_deprecated = docstring.to_lower().contains("deprecated")
    let is_async = signature.contains("async")
    Some({
      name,
      kind,
      signature,
      docstring,
      is_exported: true,
      is_deprecated,
      is_async,
      module,
    })
  } else {
    None
  }
}

///|
pub fn parse_package_resource(
  json : Json,
  package_name : String,
) -> PackageResource? {
  if json is Object(obj) {
    match obj.get("meta_info") {
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
  } else {
    None
  }
}
