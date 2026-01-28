///| README Parser

///| Extracts structured information from README markdown content

///|
/// Structured parsed README sections
pub(all) struct ParsedReadme {
  features : Array[String]
  installation : String
  usage : String
  api_reference : String
  examples : String
}

///|
/// Parse README content and extract structured sections
pub fn parse_readme(readme : String) -> ParsedReadme {
  let features = extract_section_array(readme, ["Features", "特性", "Feature"])
  let installation = extract_section(readme, [
    "Installation", "Install", "安装",
  ])
  let usage = extract_section(readme, [
    "Usage", "Examples", "Quick Start", "Quickstart", "用法",
  ])
  let api = extract_section(readme, ["API", "Reference", "文档"])
  let examples = extract_section(readme, ["Examples", "示例"])
  { features, installation, usage, api_reference: api, examples }
}

///|
/// Extract a single section from README (returns as string)
pub fn extract_section(readme : String, headers : Array[String]) -> String {
  let lines = readme.split("\n")
  let sb = StringBuilder::new()
  let mut capturing = false
  let mut indent = 0
  for line_view in lines {
    let line = line_view.to_string()
    if !capturing {
      // Check if line matches any header
      for header in headers {
        let pattern = "# " + header
        let pattern_lower = pattern.to_lower()
        let line_lower = line.to_lower()

        // Check if line starts with header
        if line_lower.has_prefix(pattern_lower) ||
          line_lower.has_prefix("## " + header.to_lower()) {
          capturing = true
          // Calculate indentation of header
          let mut spaces = 0
          let line_chars = line.to_array()
          for c in line_chars {
            if c == ' ' {
              spaces = spaces + 1
            } else if c == '#' {
              // skip header markers
            } else {
              break
            }
          }
          indent = spaces
          break
        }
      }
    } else if capturing {
      // Check if we've reached the end of this section
      // (another header at same or lower indentation)
      let leading_spaces = count_leading_spaces(line)
      if line.has_prefix("#") && leading_spaces <= indent {
        break
      }
      sb.write_string(line)
      sb.write_string("\n")
    }
  }
  sb.to_string()
}

///|
/// Extract a section and return as array of lines (for features list)
pub fn extract_section_array(
  readme : String,
  headers : Array[String],
) -> Array[String] {
  let section = extract_section(readme, headers)
  let lines = section.split("\n")
  let result = Array::new()
  for line_view in lines {
    let line = line_view.to_string()
    let trimmed_view = line.trim()
    let trimmed = trimmed_view.to_string()
    if trimmed.length() == 0 {
      continue
    }
    // Skip headers
    if trimmed.has_prefix("#") {
      continue
    }
    // Check for list items - extract content after marker
    let item = try {
      if trimmed.has_prefix("- ") {
        Some(trimmed[2:].to_string())
      } else if trimmed.has_prefix("* ") {
        Some(trimmed[2:].to_string())
      } else if trimmed.has_prefix("-") {
        Some(trimmed[1:].to_string())
      } else if trimmed.has_prefix("*") {
        Some(trimmed[1:].to_string())
      } else if trimmed.has_prefix("1. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("2. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("3. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("4. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("5. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("6. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("7. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("8. ") {
        Some(trimmed[3:].to_string())
      } else if trimmed.has_prefix("9. ") {
        Some(trimmed[3:].to_string())
      } else {
        None
      }
    } catch {
      _ => None
    }
    match item {
      Some(i) => {
        let trimmed_item = i.trim()
        if trimmed_item.length() > 0 {
          result.push(trimmed_item.to_string())
        }
      }
      None => ()
    }
  }
  result
}

///|
/// Count leading spaces in a string
pub fn count_leading_spaces(s : String) -> Int {
  let mut count = 0
  let chars = s.to_array()
  for c in chars {
    if c == ' ' {
      count = count + 1
    } else {
      break
    }
  }
  count
}

///|
/// Detect supported platforms from README content
pub fn detect_platforms(readme : String) -> Array[String] {
  let platforms = Array::new()
  let readme_lower = readme.to_lower()

  // Check for platform mentions
  if readme_lower.contains("native") {
    platforms.push("native")
  }
  if readme_lower.contains("wasm") || readme_lower.contains("webassembly") {
    platforms.push("wasm")
  }
  if readme_lower.contains("javascript") || readme_lower.contains("js backend") {
    platforms.push("js")
  }
  if readme_lower.contains("javascript backend") ||
    readme_lower.contains("js backend") {
    if !platforms.contains("js") {
      platforms.push("js")
    }
  }

  // Default to native if no platforms mentioned
  if platforms.is_empty() {
    platforms.push("native")
  }
  platforms
}
