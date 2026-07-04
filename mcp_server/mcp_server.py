import os
import json
import httpx
from fastmcp import FastMCP
from fastmcp.server.providers.openapi import RouteMap, MCPType

# Point at your Django backend URL
DJANGO_URL = os.environ.get("DJANGO_URL", "http://127.0.0.1:8000")
# Auth token if any
AUTH_TOKEN = os.environ.get("DJANGO_AUTH_TOKEN", "")

# Local cache path for schema
CACHE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema_cache.json")

# Build HTTPX client
headers = {}
if AUTH_TOKEN:
    headers["Authorization"] = f"Bearer {AUTH_TOKEN}"

client = httpx.AsyncClient(
    base_url=DJANGO_URL,
    headers=headers
)

# Fetch schema from URL or fall back to cache
openapi_spec = None

# 1. Try to fetch from active Django server
try:
    print(f"Attempting to fetch OpenAPI schema from {DJANGO_URL}/api/schema/?format=json ...")
    with httpx.Client(timeout=5.0) as sync_client:
        sync_headers = {}
        if AUTH_TOKEN:
            sync_headers["Authorization"] = f"Bearer {AUTH_TOKEN}"
        response = sync_client.get(f"{DJANGO_URL}/api/schema/?format=json", headers=sync_headers)
        if response.status_code == 200:
            openapi_spec = response.json()
            # Save to cache
            with open(CACHE_PATH, "w", encoding="utf-8") as f:
                json.dump(openapi_spec, f, indent=2)
            print("Successfully fetched and cached OpenAPI schema.")
        else:
            print(f"Failed to fetch schema (HTTP {response.status_code}).")
except Exception as e:
    print(f"Could not connect to Django server: {e}")

# 2. If fetch failed, try to load from cache
if openapi_spec is None:
    if os.path.exists(CACHE_PATH):
        try:
            with open(CACHE_PATH, "r", encoding="utf-8") as f:
                openapi_spec = json.load(f)
            print(f"Loaded OpenAPI schema from local cache: {CACHE_PATH}")
        except Exception as e:
            print(f"Error reading local cache: {e}")
    else:
        print("No local cache file found.")

# 3. Fallback to empty spec if everything fails to avoid crash
if openapi_spec is None:
    print("Warning: Starting MCP server with empty OpenAPI schema. Endpoints will not be registered.")
    openapi_spec = {
        "openapi": "3.0.0",
        "info": {
            "title": "Smart Room Renting API (Fallback)",
            "version": "1.0.0"
        },
        "paths": {}
    }

# Create the FastMCP server from the OpenAPI spec
mcp = FastMCP.from_openapi(
    openapi_spec=openapi_spec,
    client=client,
    name="Smart Room Renting API",
    route_maps=[
        # Exclude admin and internal endpoints to keep the schema clean
        RouteMap(pattern=r"^/superadmin/.*", mcp_type=MCPType.EXCLUDE),
        # Exclude delete operations by default for safety
        RouteMap(methods=["DELETE"], pattern=r".*", mcp_type=MCPType.EXCLUDE),
    ]
)

if __name__ == "__main__":
    print("Starting MCP server...")
    mcp.run()
