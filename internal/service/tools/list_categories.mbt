///| List Categories Tool

///| Lists all available package categories

///|
/// List categories tool using new Tool trait
pub(all) struct ListCategoriesTool {}

///|
pub impl @mcp.Tool for ListCategoriesTool with name(_) -> String {
  "list_categories"
}

///|
pub impl @mcp.Tool for ListCategoriesTool with description(_) -> String {
  "List all available package categories for browsing"
}

///|
pub impl @mcp.Tool for ListCategoriesTool with params(_) -> Array[@mcp.ParamDef] {
  [
    @mcp.optional_string_param(
      "category", "Filter packages by specific category name (optional)",
    ),
  ]
}

///|
pub impl @mcp.Tool for ListCategoriesTool with execute(_, args : Json) -> @mcp.ToolResult {
  // Extract optional category parameter
  let category_filter = match @mcp.get_optional_string(args, "category") {
    Ok(Some(s)) => Some(s)
    Ok(None) => None
    Err(_) => None
  }

  // Get all modules
  let all_modules = @client.fetch_modules_async()
  let mut result = ""

  // If category is specified, list packages in that category
  match category_filter {
    Some(cat_name) => {
      let packages = @client.list_by_category(cat_name, all_modules)
      result = result + "Category: " + cat_name + "\n"
      result = result +
        "Found " +
        packages.length().to_string() +
        " package(s)\n\n"
      if packages.length() > 0 {
        result = result + "Packages:\n"
        let mut i = 1
        for pkg in packages {
          result = result +
            i.to_string() +
            ". " +
            pkg.name +
            "@" +
            pkg.version +
            "\n"
          result = result + "   " + pkg.description + "\n\n"
          i = i + 1
        }
      } else {
        result = result + "No packages found in this category.\n\n"
        result = result + "Try:\n"
        result = result + "  - Using search_packages with broader keywords\n"
        result = result + "  - Listing all categories without filter\n"
      }
    }
    None => {
      // List all categories
      let cats = @client.get_all_categories()
      result = result +
        "Available Categories (" +
        cats.length().to_string() +
        "):\n\n"
      let mut i = 1
      for cat in cats {
        // Count packages in this category
        let packages = @client.list_by_category(cat, all_modules)
        result = result +
          i.to_string() +
          ". " +
          cat +
          " (" +
          packages.length().to_string() +
          " packages)\n"

        // Show sample keywords
        let cat_info = get_category_info(cat)
        let mut keywords = ""
        let mut first = true
        for kw in cat_info.keywords {
          if first {
            keywords = kw
            first = false
          } else {
            keywords = keywords + ", " + kw
          }
        }
        if keywords.length() > 0 {
          result = result + "   Keywords: " + keywords + "\n"
        }
        result = result + "\n"
        i = i + 1
      }
      result = result + "Usage:\n"
      result = result + "  - list_categories: List all categories\n"
      result = result +
        "  - list_categories {\"category\": \"web\"}: List packages in 'web' category\n"
    }
  }
  @mcp.ToolResult::text(result)
}

///|
/// Get category info by name
fn get_category_info(name : String) -> @client.Category {
  let cats = @client.categories
  match find_category_helper(cats, name) {
    Some(cat) => cat
    None => abort("Category not found: " + name)
  }
}

///|
/// Helper to find category by name
fn find_category_helper(
  categories : Array[@client.Category],
  name : String,
) -> @client.Category? {
  for cat in categories {
    if cat.name == name {
      return Some(cat)
    }
  }
  None
}
