# Mooncakes MCP

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that enables AI assistants (Claude, Cursor, etc.) to search and explore MoonBit packages from mooncakes.io.

## Features

- 🔍 **Search Packages**: Find MoonBit packages by name, description, or keywords
- 📦 **Package Info**: View detailed package metadata and READMEs
- 🌳 **Package Structure**: Browse module tree hierarchies
- 🔎 **Query Symbols**: Search types, values, traits, and typealiases

## Installation

### Prerequisites

- [MoonBit CLI](https://www.moonbitlang.com/download)
- Build the project:
  ```bash
  moon build --target native
  ```

The built binary will be at `_build/native/release/build/cmd/cmd.exe`

## Configuration

### Claude Desktop

```json
{
  "mcpServers": {
    "mooncakes": {
      "command": "/path/to/_build/native/release/build/cmd/cmd.exe"
    }
  }
}
```

**Using `moon run` directly (requires MoonBit CLI in PATH):**

```json
{
  "mcpServers": {
    "mooncakes": {
      "command": "moon",
      "args": ["run", "--target", "native", "/path/to/_build/native/release/build/cmd/cmd.exe"]
    }
  }
}
```

### Cursor

Add to your Cursor settings (Settings > MCP):

```json
{
  "mcpServers": {
    "mooncakes": {
      "command": "/path/to/_build/native/release/build/cmd/cmd.exe"
    }
  }
}
```

Or open Settings → MCP Servers → Add Server and use the command path.

### Claude Code (VS Code Extension)

Add to your MCP configuration:

```json
{
  "mcpServers": {
    "mooncakes": {
      "command": "/path/to/_build/native/release/build/cmd/cmd.exe"
    }
  }
}
```

### HTTP Server Mode (Alternative)

The server can also run in HTTP mode with SSE (Server-Sent Events) streaming:

**Start the HTTP server:**
```bash
/path/to/_build/native/release/build/cmd/cmd.exe server
```

Or using `moon run`:
```bash
moon run --target native cmd -- server
```

The server will listen on `http://127.0.0.1:4240/mcp`

**Configure clients to use HTTP mode:**

Claude Desktop / Cursor / Claude Code:
```json
{
  "mcpServers": {
    "mooncakes": {
      "url": "http://127.0.0.1:4240/mcp"
    }
  }
}
```

**Note:** When using HTTP mode, you need to start the server manually before using the MCP tools.

## Available Tools

### `search_packages`

Search for MoonBit packages from mooncakes.io registry.

**Parameters:**
- `query` (string, required): Search term to filter packages
- `limit` (number, optional): Maximum number of results (default: 10)

**Example:**
```
Search for packages related to "async"
```

### `get_package_info`

Get package metadata and README from mooncakes.io.

**Parameters:**
- `package` (string, required): Package name (e.g., `moonbitlang/async`)

**Example:**
```
Get information for moonbitlang/core
```

### `get_package_structure`

Get package module tree structure from mooncakes.io.

**Parameters:**
- `package` (string, required): Package name (e.g., `moonbitlang/async`)

**Example:**
```
Show the module structure of moonbitlang/core
```

### `query_symbols`

Query types, values, and traits from package documentation.

**Parameters:**
- `package` (string, required): Package name (e.g., `moonbitlang/async`)
- `subpackage` (string, optional): Subpackage path (e.g., `http`)
- `kind` (string, optional): Filter by symbol type: `type`, `value`, `trait`, `typealias`, or `all` (default: `all`)
- `query` (string, optional): Search query to filter symbols by name

**Example:**
```
Query all types in moonbitlang/core containing "Array"
```

## License

Apache-2.0

## Links

- [MoonBit Language](https://www.moonbitlang.com/)
- [Mooncakes.io](https://mooncakes.io/) - MoonBit package registry
- [MCP Protocol](https://modelcontextprotocol.io/) - Model Context Protocol
