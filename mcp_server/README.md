# Django API MCP Server

This directory contains a Model Context Protocol (MCP) server that exposes all OpenAPI endpoints of your Django REST Framework backend as callable tools for Claude Desktop or Claude Code.

## Prerequisites

- Python 3.10+
- Django backend running locally at `http://127.0.0.1:8000` (or configured via environment variables)

## Setup

1. **Install dependencies:**
   It is recommended to run this in its own environment to avoid version conflicts with the main Django backend:
   ```bash
   pip install -r requirements.txt
   ```

2. **Verify it starts:**
   With your Django server running:
   ```bash
   python mcp_server.py
   ```
   This will fetch the OpenAPI schema from Django and cache it locally as `schema_cache.json`.

---

## Connecting to Claude Desktop

To use this server as custom tools inside Claude Desktop, update your configuration file.

### Configuration Path
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`

### Add the Server configuration
Add the following key under `mcpServers` inside your configuration file:

```json
{
  "mcpServers": {
    "smart-room-renting-api": {
      "command": "python",
      "args": [
        "c:/Users/ayush/OneDrive/Desktop/7th sem project/mcp_server/mcp_server.py"
      ],
      "env": {
        "DJANGO_URL": "http://127.0.0.1:8000",
        "DJANGO_AUTH_TOKEN": "YOUR_OPTIONAL_BEARER_TOKEN"
      }
    }
  }
}
```

> [!TIP]
> Replace `"c:/Users/ayush/OneDrive/Desktop/7th sem project/mcp_server/mcp_server.py"` with the absolute path on your filesystem if it differs.
> Always use forward slashes `/` in the path configuration to avoid escape sequence issues in JSON.

---

## Features & Customization

- **Automatic Caching:** If Django is offline when Claude Desktop starts up, the MCP server will load the last cached schema from `schema_cache.json` rather than crashing.
- **Safety Exclusions:** Administrative routes (like `/superadmin/*`) and destructive methods (like `DELETE` operations) are excluded by default for safety. You can adjust this in `mcp_server.py`'s `route_maps` configuration if needed.
- **Authentication:** To call endpoints that require auth, configure the `DJANGO_AUTH_TOKEN` environment variable in the configuration block.
