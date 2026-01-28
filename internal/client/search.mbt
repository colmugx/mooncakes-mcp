///|
pub(all) struct SearchResults {
  query : String
  exact : Bool
  count : Int
  results : Array[ModuleInfo]
  suggestions : Array[String]
}

///|
pub(all) struct ScoredResult {
  pkg : ModuleInfo
  score : Int
}

///|
/// Calculate relevance score for a package
pub fn calculate_score(pkg : ModuleInfo, query_lower : String) -> Int {
  let mut score = 0

  // Name exact match
  if pkg.name.to_lower() == query_lower {
    score = score + 100
    // Name contains query
  } else if pkg.name.to_lower().contains(query_lower) {
    score = score + 50
  }

  // Description contains query
  if pkg.description.to_lower().contains(query_lower) {
    score = score + 20
  }

  // Keywords match
  for keyword in pkg.keywords {
    if keyword.to_lower().contains(query_lower) {
      score = score + 10
    }
  }
  score
}

///|
/// Get search suggestions based on query
pub fn get_search_suggestions(query : String) -> Array[String] {
  let suggestions = Array::new()
  let query_lower = query.to_lower()
  if query_lower == "cli" ||
    query_lower == "command" ||
    query_lower == "argparse" {
    suggestions.push("Try searching for 'terminal' or 'console'")
  }
  if query_lower == "log" || query_lower == "logger" {
    suggestions.push("Try searching for 'stdout' or 'print'")
  }
  if query_lower == "database" || query_lower == "db" {
    suggestions.push("MoonBit is early-stage, consider HTTP-based APIs instead")
  }
  if query_lower == "yaml" || query_lower == "toml" {
    suggestions.push(
      "Try searching for 'json' - MoonBit has built-in JSON support",
    )
  }
  if query_lower == "color" || query_lower == "terminal" {
    suggestions.push("Try searching for 'chalk' or 'console'")
  }
  if suggestions.is_empty() {
    suggestions.push(
      "Try broader keywords or check moonbitlang/ official packages",
    )
    suggestions.push("Use list_by_category to browse packages by category")
  }
  suggestions
}

///|
/// Find similar packages based on name similarity
pub fn find_similar_packages(
  all_modules : Array[ModuleInfo],
  pkg_name : String,
  limit : Int,
) -> Array[String] {
  let similar = Array::new()
  let pkg_name_lower = pkg_name.to_lower()
  for pkg in all_modules {
    // Skip exact match
    if pkg.name.to_lower() == pkg_name_lower {
      continue
    }

    // Check for partial name match
    if pkg.name.to_lower().contains(pkg_name_lower) ||
      pkg_name_lower.contains(pkg.name.to_lower()) {
      similar.push(pkg.name)
    }

    // Limit results
    if similar.length() >= limit {
      break
    }
  }
  similar
}

///|
pub fn enhanced_search(
  all_modules : Array[ModuleInfo],
  query : String,
  limit : Int,
) -> SearchResults {
  let query_lower = query.to_lower()

  // 1. Exact name match
  let exact_matches = Array::new()
  for pkg in all_modules {
    if pkg.name.to_lower() == query_lower {
      exact_matches.push(pkg)
    }
  }
  if exact_matches.length() > 0 {
    return {
      query,
      exact: true,
      count: exact_matches.length(),
      results: exact_matches.iter().take(limit).to_array(),
      suggestions: [],
    }
  }

  // 2. Fuzzy matching with scoring
  let fuzzy = Array::new()
  for pkg in all_modules {
    let score = calculate_score(pkg, query_lower)
    if score > 0 {
      fuzzy.push({ pkg, score })
    }
  }

  // Sort by score (highest first)
  fuzzy.sort_by(fn(a, b) { b.score - a.score })

  // 3. No results - provide suggestions
  if fuzzy.is_empty() {
    let suggestions = get_search_suggestions(query)
    return { query, exact: false, count: 0, results: [], suggestions }
  }

  // Extract packages from scored results
  let results = fuzzy.iter().take(limit).map(fn(x) { x.pkg }).to_array()
  { query, exact: false, count: results.length(), results, suggestions: [] }
}
