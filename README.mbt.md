# Mooncakes MCP

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that enables AI assistants (Claude, Cursor, etc.) to search and explore MoonBit packages from mooncakes.io.

## Features

- 🔍 **Search Packages**: Find MoonBit packages by name, description, or keywords
- 📦 **Package Info**: View detailed package metadata and READMEs
- 🌳 **Package Structure**: Browse module tree hierarchies
- 🔎 **Query Symbols**: Search types, values, traits, and typealiases

## Installation

### Option 1: Build from Source (requires MoonBit CLI)

1. Install [MoonBit CLI](https://www.moonbitlang.com/download)
2. Clone and build:
   ```bash
   git clone https://github.com/colmugx/mooncakes_mcp.git
   cd mooncakes_mcp
   moon build --target native
   ```

The built binary will be at `_build/native/release/build/cmd/cmd.exe`

**Run using `moon run`:**
```bash
moon run --target native cmd
```

### Option 2: Download Pre-built Binary (Recommended)

Download the latest release from the [GitHub Releases page](https://github.com/colmugx/mooncakes_mcp/releases).

Choose the appropriate file for your platform:
- **macOS**: `mooncakes_mcp-macos-{ARCH}.zip`
- **Linux**: `mooncakes_mcp-linux-{ARCH}.zip`

Extract and make executable:
```bash
unzip mooncakes_mcp-macos-*.zip
chmod +x mooncakes_mcp
```

The binary is ready to run directly - no MoonBit CLI required.

## Configuration

> **Note**: These examples assume you've downloaded the binary to `~/Downloads`. Adjust the path if you placed it elsewhere. Replace `your-username` with your actual username.

### Claude Desktop

```json
{
  "mcpServers": {
    "mooncakes": {
      "command": "/Users/your-username/Downloads/mooncakes_mcp"
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
      "command": "/Users/your-username/Downloads/mooncakes_mcp"
    }
  }
}
```

Or open **Settings → MCP Servers → Add Server** and use the command path.

### Claude Code (VS Code Extension)

Add to your MCP configuration file:

```json
{
  "mcpServers": {
    "mooncakes": {
      "command": "/Users/your-username/Downloads/mooncakes_mcp"
    }
  }
}
```

### HTTP Server Mode (Alternative)

The server can also run in HTTP mode with SSE (Server-Sent Events) streaming:

**Start the HTTP server:**
```bash
~/Downloads/mooncakes_mcp server
```

**Or using `moon run` (if built from source):**
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
