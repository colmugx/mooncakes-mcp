///|
test "count_leading_spaces" {
  inspect(@client.count_leading_spaces(""), content="0")
  inspect(@client.count_leading_spaces(" "), content="1")
  inspect(@client.count_leading_spaces("  abc"), content="2")
  inspect(@client.count_leading_spaces("abc"), content="0")
}

///|
test "parse_module_from_json" {
  // Valid input
  let valid_json : Json = {
    "name": "moonbitlang/async",
    "version": "0.1.0",
    "description": "Async library",
    "repository": "https://github.com/moonbitlang/async",
    "keywords": ["async", "promise"],
  }
  inspect(
    @client.parse_module_from_json(valid_json),
    content="Some({name: \"moonbitlang/async\", version: \"0.1.0\", description: \"Async library\", keywords: [\"async\", \"promise\"], repository: \"https://github.com/moonbitlang/async\"})",
  )

  // Partial input (missing optional fields)
  let partial_json : Json = { "name": "moonbitlang/core" }
  inspect(
    @client.parse_module_from_json(partial_json),
    content="Some({name: \"moonbitlang/core\", version: \"\", description: \"\", keywords: [], repository: \"\"})",
  )

  // Invalid JSON structure (not an object)
  inspect(@client.parse_module_from_json("invalid"), content="None")

  // Missing required field "name"
  let missing_name : Json = { "version": "1.0.0" }
  inspect(@client.parse_module_from_json(missing_name), content="None")
}

///|
test "parse_readme" {
  // Full README
  let full_readme =
    #|# Features
    #|- Feature 1
    #|- Feature 2
    #|
    #|# Installation
    #|moon add user/repo
    #|
    #|# Usage
    #|let x = 1
  let result = @client.parse_readme(full_readme)
  inspect(result.features, content="[\"Feature 1\", \"Feature 2\"]")
  inspect(result.installation.trim(), content="moon add user/repo")
  inspect(result.usage.trim(), content="let x = 1")

  // Empty README
  let empty_result = @client.parse_readme("")
  inspect(empty_result.features, content="[]")
  inspect(empty_result.installation, content="")

  // Alternative headers
  let alt_readme =
    #|## 特性
    #|* 异步
    #|
    #|## 安装
    #|moon add colmugx/async
  let alt_result = @client.parse_readme(alt_readme)
  inspect(alt_result.features, content="[\"异步\"]")
  inspect(alt_result.installation.trim(), content="moon add colmugx/async")
}

///|
test "detect_platforms" {
  inspect(
    @client.detect_platforms("Support wasm and native"),
    content="[\"native\", \"wasm\"]",
  )
  inspect(
    @client.detect_platforms("JavaScript backend support"),
    content="[\"js\"]",
  )
  inspect(@client.detect_platforms("Only native code"), content="[\"native\"]")
  inspect(@client.detect_platforms("No mentions"), content="[\"native\"]")
}
