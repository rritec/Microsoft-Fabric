---
name: activator-consumption-cli
description: >
  Inspect existing alerts, notifications, and automated actions in Fabric via
  read-only REST API calls using `az rest` CLI. **Invoke this skill** whenever
  the user wants to:
  (1) list existing alerts in a workspace,
  (2) inspect how an alert or notification is configured,
  (3) read and decode an Activator/Reflex definition (ReflexEntities.json),
  (4) list rules, sources, and actions behind an alert,
  (5) understand why an alert fires or what action it takes.
  **Invoke this skill before answering questions** about an Activator/Reflex item
  in a Fabric workspace — the listing, lookup, and decoding workflows are part of
  this skill, not preamble to it.
  Triggers: "show my alerts", "what alerts do I have", "inspect this alert",
  "show me the rule", "show me the action", "show me the source",
  "get reflex definition", "list activators", "list alerts",
  "list reflex items", "show activator items", "activator details",
  "find activator named"
---

> **Update Check — ONCE PER SESSION (mandatory)**
> The first time this skill is used in a session, run the **check-updates** skill before proceeding.
> - **GitHub Copilot CLI / VS Code**: invoke the `check-updates` skill (e.g., `/fabric-skills:check-updates`).
> - **Claude Code / Cowork / Cursor / Windsurf / Codex**: read the local `package.json` version, then compare it against the remote version via `git fetch origin main --quiet && git show origin/main:package.json` (or the GitHub API). If the remote version is newer, show the changelog and update instructions.
> - Skip if the check was already performed earlier in this session.

> **CRITICAL NOTES**
> 1. To find the workspace details (including its ID) from workspace name: list all workspaces and, then, use JMESPath filtering
> 2. To find the item details (including its ID) from workspace ID, item type, and item name: list all items of that type in that workspace and, then, use JMESPath filtering

# activator-consumption-cli — Read-Only Activator Exploration via CLI

## Table of Contents

| Task | Reference | Notes |
|---|---|---|
| Finding Workspaces and Items in Fabric | [COMMON-CLI.md § Finding Workspaces and Items in Fabric](../../common/COMMON-CLI.md#finding-workspaces-and-items-in-fabric) | **Mandatory** — *READ link first* [needed for workspace/item ID resolution] |
| Fabric Topology & Key Concepts | [COMMON-CORE.md § Fabric Topology & Key Concepts](../../common/COMMON-CORE.md#fabric-topology--key-concepts) | |
| Authentication & Token Acquisition | [COMMON-CORE.md § Authentication & Token Acquisition](../../common/COMMON-CORE.md#authentication--token-acquisition) | Wrong audience = 401 |
| Core Control-Plane REST APIs | [COMMON-CORE.md § Core Control-Plane REST APIs](../../common/COMMON-CORE.md#core-control-plane-rest-apis) | |
| Long-Running Operations (LRO) | [COMMON-CORE.md § Long-Running Operations (LRO)](../../common/COMMON-CORE.md#long-running-operations-lro) | `getDefinition` may return 202 |
| Rate Limiting & Throttling | [COMMON-CORE.md § Rate Limiting & Throttling](../../common/COMMON-CORE.md#rate-limiting--throttling) | |
| Fabric Item Definitions | [ITEM-DEFINITIONS-CORE.md § Definition Envelope](../../common/ITEM-DEFINITIONS-CORE.md#definition-envelope) | Base64 payload structure |
| Authentication Recipes | [COMMON-CLI.md § Authentication Recipes](../../common/COMMON-CLI.md#authentication-recipes) | `az login` flows |
| Fabric Control-Plane API via `az rest` | [COMMON-CLI.md § Fabric Control-Plane API via az rest](../../common/COMMON-CLI.md#fabric-control-plane-api-via-az-rest) | **Always pass `--resource https://api.fabric.microsoft.com`** |
| LRO Pattern | [COMMON-CLI.md § Long-Running Operations (LRO) Pattern](../../common/COMMON-CLI.md#long-running-operations-lro-pattern) | |
| Pagination Pattern | [COMMON-CLI.md § Pagination Pattern](../../common/COMMON-CLI.md#pagination-pattern) | |
| Tool Stack | [SKILL.md § Tool Stack](#tool-stack) | |
| Connection | [SKILL.md § Connection](#connection) | |
| Listing Activator Items | [SKILL.md § Listing Activator Items](#listing-activator-items) | |
| Inspecting a Single Activator | [SKILL.md § Inspecting a Single Activator](#inspecting-a-single-activator) | |
| Reading the Definition | [SKILL.md § Reading the Definition](#reading-the-definition) | |
| Exploring Rules, Sources, and Actions | [SKILL.md § Exploring Rules, Sources, and Actions](#exploring-rules-sources-and-actions) | |
| Must / Prefer / Avoid | [SKILL.md § Must / Prefer / Avoid](#must--prefer--avoid) | |
| Examples | [SKILL.md § Examples](#examples) | |

---

## Tool Stack

| Tool | Purpose | Install |
|---|---|---|
| **az cli** | Fabric REST API calls for reading Activator items and definitions | `winget install Microsoft.AzureCLI` |
| **jq** | JSON processing, Base64 decoding, definition inspection | `winget install jqlang.jq` |

---

## Connection

Use the shared authentication guidance in [COMMON-CLI.md § Authentication Recipes](../../common/COMMON-CLI.md#authentication-recipes). Resolve workspace and item IDs per [COMMON-CLI.md § Finding Workspaces and Items in Fabric](../../common/COMMON-CLI.md#finding-workspaces-and-items-in-fabric). Examples below assume `WS_ID` and `REFLEX_ID` are already resolved.

---

## Listing Activator Items

### List All Activators in a Workspace

```bash
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes" \
  --resource "https://api.fabric.microsoft.com" \
  | jq '.value[] | {id, displayName, description}'
```

Required scopes: `Workspace.Read.All` or `Workspace.ReadWrite.All`

### Paginated Listing

For workspaces with many items, follow the `continuationUri` returned in each response:

```bash
NEXT_URL="https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes"
while [ -n "$NEXT_URL" ]; do
  RESPONSE=$(az rest --method GET \
    --url "$NEXT_URL" \
    --resource "https://api.fabric.microsoft.com")
  echo "$RESPONSE" | jq '.value[] | {id, displayName, description}'
  NEXT_URL=$(echo "$RESPONSE" | jq -r '.continuationUri // empty')
done
```

### Filter by Folder

```bash
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes?recursive=true&rootFolderId=${FOLDER_ID}" \
  --resource "https://api.fabric.microsoft.com" \
  | jq '.value[] | {id, displayName}'
```

---

## Inspecting a Single Activator

```bash
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes/${REFLEX_ID}" \
  --resource "https://api.fabric.microsoft.com" \
  | jq '{id, displayName, description, type, workspaceId}'
```

---

## Reading the Definition

> `getDefinition` is a **POST** (not GET), requires **ReadWrite** scopes (`Reflex.ReadWrite.All` or `Item.ReadWrite.All`) even for read-only inspection, and may return **202 LRO**. Use the `fabric_lro` helper from [COMMON-CLI.md § Long-Running Operations (LRO) Pattern](../../common/COMMON-CLI.md#long-running-operations-lro-pattern) so 202 responses can be polled via the `Location` header before decoding.

### Decode the Full Definition

```bash
DEFINITION=$(fabric_lro POST \
  "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes/${REFLEX_ID}/getDefinition" \
  '{}')

echo "$DEFINITION" \
  | jq '.definition.parts[] | select(.path=="ReflexEntities.json") | .payload' -r \
  | base64 -d | jq .
```

### Save Definition to File

```bash
DEFINITION=$(fabric_lro POST \
  "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes/${REFLEX_ID}/getDefinition" \
  '{}')

echo "$DEFINITION" \
  | jq '.definition.parts[] | select(.path=="ReflexEntities.json") | .payload' -r \
  | base64 -d | jq . > reflex-entities.json
```

---

## Exploring Rules, Sources, and Actions

Once you have the decoded `ReflexEntities.json`, use `jq` to extract specific components.

### List All Entity Types

```bash
cat reflex-entities.json | jq '[.[] | .type] | sort | group_by(.) | map({type: .[0], count: length})'
```

### List Data Sources

```bash
cat reflex-entities.json | jq '.[] | select(.type | endswith("Source-v1")) | {name: .payload.name, type: .type, id: .uniqueIdentifier}'
```

### List Rules

```bash
cat reflex-entities.json | jq '.[] | select(.type == "timeSeriesView-v1" and .payload.definition.type == "Rule") | {name: .payload.name, id: .uniqueIdentifier, shouldRun: .payload.definition.settings.shouldRun}'
```

### List Objects and Their Attributes

```bash
# Objects
cat reflex-entities.json | jq '.[] | select(.type == "timeSeriesView-v1" and .payload.definition.type == "Object") | {name: .payload.name, id: .uniqueIdentifier}'

# Attributes for a specific object
OBJECT_ID="<object-guid>"
cat reflex-entities.json | jq --arg oid "$OBJECT_ID" '.[] | select(.type == "timeSeriesView-v1" and .payload.definition.type == "Attribute" and .payload.parentObject.targetUniqueIdentifier == $oid) | {name: .payload.name, id: .uniqueIdentifier}'
```

### Inspect a Rule's Condition

```bash
RULE_ID="<rule-guid>"
cat reflex-entities.json \
  | jq --arg rid "$RULE_ID" '.[] | select(.uniqueIdentifier == $rid) | .payload.definition.instance' -r \
  | jq '.steps[] | {step: .name, rows: [.rows[] | .kind]}'
```

### List Actions (Fabric Item Actions)

```bash
cat reflex-entities.json | jq '.[] | select(.type == "fabricItemAction-v1") | {name: .payload.name, itemType: .payload.fabricItem.itemType, itemId: .payload.fabricItem.itemId}'
```

### Summary View

Get a high-level overview of an Activator's configuration:

```bash
cat reflex-entities.json | jq '{
  containers: [.[] | select(.type == "container-v1") | .payload.name],
  sources: [.[] | select(.type | endswith("Source-v1")) | {name: .payload.name, type: .type}],
  objects: [.[] | select(.type == "timeSeriesView-v1" and .payload.definition.type == "Object") | .payload.name],
  rules: [.[] | select(.type == "timeSeriesView-v1" and .payload.definition.type == "Rule") | {name: .payload.name, active: .payload.definition.settings.shouldRun}],
  actions: [.[] | select(.type == "fabricItemAction-v1") | {name: .payload.name, type: .payload.fabricItem.itemType}]
}'
```

---

## Must / Prefer / Avoid

### MUST DO

- **Always use `--resource https://api.fabric.microsoft.com`** with `az rest`
- **Always send `--body '{}'`** for `getDefinition` — it is a POST and omitting the body can cause 411 errors
- **Handle LRO responses** — `getDefinition` may return 202; poll the `Location` header
- **Base64-decode** the `ReflexEntities.json` payload before inspection — it is Base64-encoded in the API response
- **JSON-parse** the `definition.instance` field in rule entities — it is a JSON-encoded string, not a nested object

### PREFER

- **Summary view first** — give users a high-level overview before diving into individual entities
- **Save to file** when the definition is large — decode once and explore with `jq` locally
- **Discover IDs dynamically** via workspace and item listing + JMESPath filtering
- **Paginated listing** for workspaces with many Activator items

### AVOID

- **Hardcoded workspace or item IDs** — always resolve dynamically
- **Using GET for `getDefinition`** — it is a POST endpoint; GET will return 405
- **Attempting to read definitions of items with encrypted sensitivity labels** — it will be blocked
- **Modifying data** — this is a read-only skill; use [activator-authoring-cli](../activator-authoring-cli/SKILL.md) for write operations

---

## Examples

### List All Activators and Show Their Rules

```bash
# Step 1: List activators
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes" \
  --resource "https://api.fabric.microsoft.com" \
  | jq '.value[] | {id, displayName}'

# Step 2: For a specific activator, get and decode its definition
az rest --method POST \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes/${REFLEX_ID}/getDefinition" \
  --resource "https://api.fabric.microsoft.com" \
  --headers "Content-Type=application/json" \
  --body '{}' \
  | jq '.definition.parts[] | select(.path=="ReflexEntities.json") | .payload' -r \
  | base64 -d \
  | jq '.[] | select(.type == "timeSeriesView-v1" and .payload.definition.type == "Rule") | {name: .payload.name, active: .payload.definition.settings.shouldRun}'
```

### Inspect a Specific Rule's Full Configuration

```bash
# Decode definition and extract rule details
az rest --method POST \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WS_ID}/reflexes/${REFLEX_ID}/getDefinition" \
  --resource "https://api.fabric.microsoft.com" \
  --headers "Content-Type=application/json" \
  --body '{}' \
  | jq '.definition.parts[] | select(.path=="ReflexEntities.json") | .payload' -r \
  | base64 -d \
  | jq '.[] | select(.payload.name == "Too hot for medicine") | .payload.definition.instance' -r \
  | jq '.steps[] | {step: .name, details: .rows}'
```

---

## Querying Activation History

Activation history (when rules fired) is not available via the public REST API. It is accessible via the **Activator MCP server** using the `get_activations_for_rule` tool.

### Prerequisites

Use the shared authentication guidance in [COMMON-CLI.md § Authentication Recipes](../../common/COMMON-CLI.md#authentication-recipes) before connecting to the Activator MCP endpoint.

```bash
pip install mcp httpx azure-identity aiohttp
```

### Workflow

1. **List rules** using the public API (getDefinition → decode → filter for Rule entities) to get the rule's `uniqueIdentifier`
2. **Connect to the Activator MCP server** and call `get_activations_for_rule` with the rule ID

### MCP Server Connection

The Activator MCP endpoint is at:
```
https://api.fabric.microsoft.com/v1/mcp/workspaces/{workspaceId}/reflexes/{activatorId}
```

Use the shared Fabric API authentication guidance from [COMMON-CORE.md § Authentication & Token Acquisition](../../common/COMMON-CORE.md#authentication--token-acquisition). MCP clients should rely on standard Azure identity flows and must not hardcode tokens.

### Calling `get_activations_for_rule`

Connect using the MCP `streamable_http_client`, then call the tool:

```python
from mcp import ClientSession
from mcp.client.streamable_http import streamable_http_client

# After connecting and initializing the session:
result = await session.call_tool(
    "get_activations_for_rule",
    {
        "getActivationsParams": {
            "workspaceId": "<workspace-id>",
            "artifactId": "<activator-id>",
            "ruleId": "<rule-uniqueIdentifier>",
        }
    },
)
```

The response contains `totalCount` and an `activations` array with details of each time the rule fired.

### Available MCP Tools

| Tool | Purpose |
|------|---------|
| `list_rules` | List rules in an Activator (alternative to public API decode) |
| `get_activations_for_rule` | Get activation history for a specific rule |

---

## Agent Integration Notes

- This skill uses the Fabric Items API (`/reflexes`) for listing and `getDefinition` for inspection
- No additional data-plane protocols are needed for item/rule inspection — all use `az rest` with the Fabric API audience
- `getDefinition` requires **ReadWrite** scopes even for read-only access — this is a known API requirement
- **Activation history** requires the MCP server connection (not available via public REST API)
- For **creating or modifying** Activator items and rules, use the [activator-authoring-cli](../activator-authoring-cli/SKILL.md) skill
