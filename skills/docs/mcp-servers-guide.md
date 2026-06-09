# MCP Servers Guide

Model Context Protocol (MCP) servers provide live data connections to AI assistants. This guide explains how MCP servers fit into skills-for-fabric and how to register them.

## What is MCP?

MCP (Model Context Protocol) is a standard for connecting AI assistants to external data sources and tools. MCP servers:

- Provide real-time access to databases, APIs, and services
- Enable AI assistants to execute queries and retrieve live data
- Run as separate processes that communicate with the AI tool

## Skills vs. MCP Servers

| Aspect | Skills | MCP Servers |
|--------|--------|-------------|
| **Purpose** | Provide knowledge and patterns | Provide data access |
| **Content** | Markdown documentation | Executable servers |
| **Runtime** | Loaded into AI context | Run as separate processes |
| **Example** | "How to query a warehouse" | "Execute this SQL query" |

**Key insight:** Skills teach the AI assistant *what to do*. MCP servers *do it*.

## The mcp-setup Folder

MCP server registration scripts and templates live in `mcp-setup/`:

```
mcp-setup/
├── README.md                    # Setup instructions
├── mcp-config-template.json     # Template for MCP configuration
├── register-fabric-mcp.ps1      # Windows registration script
└── register-fabric-mcp.sh       # macOS/Linux registration script
```

## Why MCP Config Goes Here

MCP servers should NOT be defined inside skills because:

1. **Separation of concerns** — Skills are knowledge; MCP is infrastructure
2. **Security** — MCP configs may contain connection strings or credentials
3. **Reusability** — One MCP server can serve multiple skills
4. **Maintenance** — MCP server setup is a one-time operation, not per-skill

## MCP Configuration Template

```json
{
  "mcpServers": {
    "fabric-sql": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic/mcp-server-fabric-sql",
        "--connection-string",
        "Server=<endpoint>.datawarehouse.fabric.microsoft.com;Database=<db>;Authentication=ActiveDirectoryDefault"
      ]
    },
    "fabric-spark": {
      "command": "fabric-spark-mcp",
      "args": ["--workspace-id", "<wsId>", "--lakehouse-id", "<lhId>"]
    }
  }
}
```

## Registering an MCP Server

### Prerequisites

1. The MCP server package must be installed (npm, pip, or standalone binary)
2. You need connection details for your Fabric resources
3. You need authentication configured (typically `az login`)

### Windows

```powershell
.\mcp-setup\register-fabric-mcp.ps1
```

### macOS/Linux

```bash
./mcp-setup/register-fabric-mcp.sh
```

### Manual Registration

For tools that support MCP configuration files:

1. Copy `mcp-config-template.json` to your tool's config location
2. Replace placeholders with your actual values
3. Restart the AI tool

## Adding a New MCP Server

### Create or Obtain the Server

MCP servers can be:
- Published npm packages (`@anthropic/mcp-server-*`)
- Python packages (`pip install mcp-server-*`)
- Standalone binaries
- Custom implementations

### Add Registration Logic

Update the registration scripts:

**register-fabric-mcp.sh:**
```bash
# Add Fabric SQL MCP
add_mcp_server "fabric-sql" \
  "npx" \
  "-y @anthropic/mcp-server-fabric-sql --connection-string $CONN_STRING"
```

**register-fabric-mcp.ps1:**
```powershell
# Add Fabric SQL MCP
Add-McpServer -Name "fabric-sql" `
  -Command "npx" `
  -Args @("-y", "@anthropic/mcp-server-fabric-sql", "--connection-string", $connString)
```

### Update the Template

Add the new server to `mcp-config-template.json`:

```json
{
  "mcpServers": {
    "existing-server": { ... },
    "new-server": {
      "command": "...",
      "args": [...]
    }
  }
}
```

### Document in README

Update `mcp-setup/README.md` with:
- Server purpose
- Prerequisites
- Configuration options

## MCP Server Security

### Do NOT Commit Secrets

MCP configurations often contain connection strings. The template uses placeholders:

```json
{
  "args": ["--connection-string", "<YOUR_CONNECTION_STRING>"]
}
```

### Use Environment Variables

Prefer environment variables over hardcoded values:

```json
{
  "args": ["--connection-string", "${FABRIC_CONN_STRING}"]
}
```

### Rely on Azure CLI Auth

When possible, use `ActiveDirectoryDefault` which leverages `az login`:

```json
{
  "args": ["--auth-method", "ActiveDirectoryDefault"]
}
```

## Skills That Complement MCP

When an MCP server is available, skills can reference it:

```markdown
## Prerequisites

This skill works best with the Fabric SQL MCP server installed.
See [mcp-setup/README.md](../mcp-setup/README.md) for installation.

## With MCP Server

If you have `fabric-sql` MCP configured, I can execute queries directly:

> Execute: SELECT TOP 10 * FROM dbo.FactSales

## Without MCP Server

Without MCP, I'll generate sqlcmd commands for you to run:

```bash
sqlcmd -S $FABRIC_SERVER -d $FABRIC_DB -G -Q "SELECT TOP 10 * FROM dbo.FactSales"
```
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| MCP server not found | Verify the server package is installed |
| Authentication fails | Run `az login` and ensure correct tenant |
| Connection timeout | Check firewall rules, port 1433 access |
| Server crashes on startup | Check logs, verify connection string format |
| Tool doesn't recognize MCP | Verify config file location for your AI tool |

## Further Reading

- [MCP Specification](https://modelcontextprotocol.io/)
- [mcp-setup/README.md](../mcp-setup/README.md) — Detailed setup instructions
