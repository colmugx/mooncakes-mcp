///| Package Categories

///| Provides category definitions and classification for MoonBit packages

///|
/// Package category with associated keywords
pub struct Category {
  name : String
  keywords : Array[String]
}

///|
/// Predefined categories for MoonBit packages
pub let categories : Array[Category] = [
  {
    name: "web",
    keywords: [
      "http", "websocket", "server", "client", "request", "api", "rest",
    ],
  },
  {
    name: "data",
    keywords: ["json", "xml", "csv", "parser", "serializer", "encode", "decode"],
  },
  {
    name: "time",
    keywords: ["time", "date", "datetime", "timestamp", "duration", "calendar"],
  },
  {
    name: "crypto",
    keywords: ["crypto", "hash", "encryption", "rsa", "aes", "sha", "hmac"],
  },
  {
    name: "encoding",
    keywords: ["base64", "utf", "encoding", "charset", "unicode", "hex"],
  },
  {
    name: "cli",
    keywords: [
      "cli", "command", "terminal", "console", "argparse", "tui", "ncurses",
    ],
  },
  {
    name: "testing",
    keywords: ["test", "testing", "assert", "mock", "fixture", "expect"],
  },
  {
    name: "logging",
    keywords: ["log", "logger", "logging", "stdout", "stderr", "debug"],
  },
  {
    name: "math",
    keywords: ["math", "calc", "calculation", "matrix", "vector", "geometry"],
  },
  {
    name: "format",
    keywords: ["format", "fmt", "string", "printf", "template"],
  },
  {
    name: "image",
    keywords: ["image", "img", "png", "jpg", "codec", "qoi", "jpeg"],
  },
  { name: "audio", keywords: ["audio", "sound", "music", "midi", "wav", "pcm"] },
  {
    name: "compression",
    keywords: ["compress", "decompress", "gzip", "zip", "lz4", "archive"],
  },
]

///|
/// Find category by name
fn find_category(name : String) -> Category? {
  for cat in categories {
    if cat.name.to_lower() == name.to_lower() {
      return Some(cat)
    }
  }
  None
}

///|
/// List packages by category name
pub fn list_by_category(
  category_name : String,
  all_modules : Array[ModuleInfo],
) -> Array[ModuleInfo] {
  let category_lower = category_name.to_lower()
  match find_category(category_lower) {
    Some(cat) => {
      let matches = Array::new()
      for pkg in all_modules {
        let mut matched = false
        for keyword in cat.keywords {
          let keyword_lower = keyword.to_lower()
          if pkg.name.to_lower().contains(keyword_lower) ||
            pkg.description.to_lower().contains(keyword_lower) {
            matched = true
            break
          }
        }
        if matched {
          matches.push(pkg)
        }
      }
      matches
    }
    None => []
  }
}

///|
/// Classify a package into a category
pub fn classify_package(pkg : ModuleInfo) -> String? {
  for cat in categories {
    for keyword in cat.keywords {
      let keyword_lower = keyword.to_lower()
      if pkg.name.to_lower().contains(keyword_lower) ||
        pkg.description.to_lower().contains(keyword_lower) {
        return Some(cat.name)
      }
    }
  }
  None
}

///|
/// Get all available category names
pub fn get_all_categories() -> Array[String] {
  categories.map(fn(c) { c.name })
}
