---
name: eventstream-consumption-cli
description: >
  List, inspect, and monitor Microsoft Fabric Eventstream real-time event ingestion
  pipelines via the Fabric Items REST API. Discover Eventstreams across workspaces,
  decode base64-encoded graph topologies to trace event flow from source through
  operators to destination nodes. Validate source connection IDs, destination wiring,
  retention policies (1-90 days), and throughput levels. Use when the user wants to:
  (1) list or search Eventstreams in a workspace, (2) decode and trace graph topology
  from source to destination, (3) validate source and destination configurations,
  (4) check retention and throughput settings.
  Triggers: "list eventstreams", "show eventstream", "inspect eventstream",
  "explain eventstream", "eventstream health", "monitor eventstream",
  "describe eventstream", "check eventstream configuration", "eventstream retention".
---

> **Update Check — ONCE PER SESSION (mandatory)**
> The first time this skill is used in a session, run the **check-updates** skill before proceeding.
> - **GitHub Copilot CLI / VS Code**: invoke the `check-updates` skill.
> - **Claude Code / Cowork / Cursor / Windsurf / Codex**: compare local vs remote package.json version.
> - Skip if the check was already performed earlier in this session.

> **CRITICAL NOTES**
> 1. To find the workspace details (including its ID) from workspace name: list all workspaces and, then, use JMESPath filtering
> 2. To find the item details (including its ID) from workspace ID, item type, and item name: list all items of that type in that workspace and, then, use JMESPath filtering
> 3. Eventstream ≠ Eventhouse. Eventstream is a real-time event ingestion and routing pipeline. For KQL queries, use `eventhouse-consumption-cli`.

# Eventstream Consumption — CLI Skill

## Table of Contents

| Task | Reference | Notes |
|---|---|---|
| Finding Workspaces and Items in Fabric | [COMMON-CLI.md § Finding Workspaces and Items in Fabric](../../common/COMMON-CLI.md#finding-workspaces-and-items-in-fabric) | **Mandatory** — *READ link first* [needed for finding workspace id by its name or item id by its name, item type, and workspace id] |
| Fabric Topology & Key Concepts | [COMMON-CORE.md § Fabric Topology & Key Concepts](../../common/COMMON-CORE.md#fabric-topology--key-concepts) | |
| Environment URLs | [COMMON-CORE.md § Environment URLs](../../common/COMMON-CORE.md#environment-urls) | |
| Authentication & Token Acquisition | [COMMON-CORE.md § Authentication & Token Acquisition](../../common/COMMON-CORE.md#authentication--token-acquisition) | Wrong audience = 401; read before any auth issue |
| Core Control-Plane REST APIs | [COMMON-CORE.md § Core Control-Plane REST APIs](../../common/COMMON-CORE.md#core-control-plane-rest-apis) | Includes pagination, LRO polling, and rate-limiting patterns |
| Gotchas, Best Practices & Troubleshooting | [COMMON-CORE.md § Gotchas, Best Practices & Troubleshooting](../../common/COMMON-CORE.md#gotchas-best-practices--troubleshooting) | |
| Tool Selection Rationale | [COMMON-CLI.md § Tool Selection Rationale](../../common/COMMON-CLI.md#tool-selection-rationale) | |
| Authentication Recipes | [COMMON-CLI.md § Authentication Recipes](../../common/COMMON-CLI.md#authentication-recipes) | `az login` flows and token acquisition |
| Fabric Control-Plane API via `az rest` | [COMMON-CLI.md § Fabric Control-Plane API via az rest](../../common/COMMON-CLI.md#fabric-control-plane-api-via-az-rest) | **Always pass `--resource`**; includes pagination and LRO helpers |
| Gotchas & Troubleshooting (CLI-Specific) | [COMMON-CLI.md § Gotchas & Troubleshooting (CLI-Specific)](../../common/COMMON-CLI.md#gotchas--troubleshooting-cli-specific) | `az rest` audience, shell escaping, token expiry |
| Quick Reference | [COMMON-CLI.md § Quick Reference](../../common/COMMON-CLI.md#quick-reference) | `az rest` template + token audience/tool matrix |
| Listing and Discovering Eventstreams | [EVENTSTREAM-CONSUMPTION-CORE.md § Listing and Discovering Eventstreams](../../common/EVENTSTREAM-CONSUMPTION-CORE.md#listing-and-discovering-eventstreams) | List, Get, Search across workspaces |
| Inspecting Eventstream Topology | [EVENTSTREAM-CONSUMPTION-CORE.md § Inspecting Eventstream Topology](../../common/EVENTSTREAM-CONSUMPTION-CORE.md#inspecting-eventstream-topology) | Decode base64 definition → trace graph flow |
| Monitoring Eventstream Health | [EVENTSTREAM-CONSUMPTION-CORE.md § Monitoring Eventstream Health](../../common/EVENTSTREAM-CONSUMPTION-CORE.md#monitoring-eventstream-health) | Retention and throughput checks |
| Source and Destination Status | [EVENTSTREAM-CONSUMPTION-CORE.md § Source and Destination Status](../../common/EVENTSTREAM-CONSUMPTION-CORE.md#source-and-destination-status) | Validation checklist for sources and destinations |
| Integration with Downstream Analytics | [EVENTSTREAM-CONSUMPTION-CORE.md § Integration with Downstream Analytics](../../common/EVENTSTREAM-CONSUMPTION-CORE.md#integration-with-downstream-analytics) | Eventhouse, Lakehouse, Activator, Real-Time Hub |
| Gotchas and Troubleshooting Reference | [EVENTSTREAM-CONSUMPTION-CORE.md § Gotchas and Troubleshooting Reference](../../common/EVENTSTREAM-CONSUMPTION-CORE.md#gotchas-and-troubleshooting-reference) | 10 common issues with causes and fixes |
| List Eventstreams | [SKILL.md § List Eventstreams](#list-eventstreams) | |
| Inspect Eventstream Topology | [SKILL.md § Inspect Eventstream Topology](#inspect-eventstream-topology) | Decode and explore the graph |
| Validate Eventstream Configuration | [SKILL.md § Validate Eventstream Configuration](#validate-eventstream-configuration) | |
| Gotchas, Rules, Troubleshooting | [SKILL.md § Gotchas, Rules, Troubleshooting](#gotchas-rules-troubleshooting) | **MUST DO / AVOID / PREFER** checklists |

---

## List Eventstreams

### List All Eventstreams in a Workspace

```bash
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/eventstreams" \
  --resource "https://api.fabric.microsoft.com"
```

Returns an array of Eventstream items. Use JMESPath to filter by name:

```bash
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/eventstreams" \
  --resource "https://api.fabric.microsoft.com" \
  --query "value[?displayName=='my-eventstream']"
```

### Get Eventstream Details

```bash
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/eventstreams/${EVENTSTREAM_ID}" \
  --resource "https://api.fabric.microsoft.com"
```

---

## Inspect Eventstream Topology

Retrieve the Eventstream definition and decode it to inspect the full graph topology.

### Step 1: Get the Definition

```bash
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/eventstreams/${EVENTSTREAM_ID}/definition" \
  --resource "https://api.fabric.microsoft.com"
```

### Step 2: Decode the Topology

Extract the `eventstream.json` part's `payload` field and base64-decode it:

```bash
# Using jq + base64 (Linux/macOS)
az rest --method GET \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/eventstreams/${EVENTSTREAM_ID}/definition" \
  --resource "https://api.fabric.microsoft.com" \
  | jq -r '.definition.parts[] | select(.path=="eventstream.json") | .payload' \
  | base64 -d | jq .
```

```powershell
# PowerShell (Windows)
$def = az rest --method GET `
  --url "https://api.fabric.microsoft.com/v1/workspaces/$WORKSPACE_ID/eventstreams/$EVENTSTREAM_ID/definition" `
  --resource "https://api.fabric.microsoft.com" | ConvertFrom-Json
$payload = ($def.definition.parts | Where-Object { $_.path -eq 'eventstream.json' }).payload
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

### Step 3: Summarize the Topology

After decoding, count and list each node type:

| Metric | Path in decoded JSON |
|--------|---------------------|
| Sources | `.sources[] \| .name, .type` |
| Destinations | `.destinations[] \| .name, .type` |
| Operators | `.operators[] \| .name, .type` |
| Streams | `.streams[] \| .name, .type` |

---

## Validate Eventstream Configuration

Check key configuration aspects of a decoded Eventstream topology:

### Source Validation Checklist

| Check | How |
|-------|-----|
| Source type is API-supported | Compare against 25 known type enums |
| Cloud connection exists | Verify `dataConnectionId` GUID resolves |
| Consumer group set | Required for Event Hub, IoT Hub, Kafka sources |
| Serialization matches source | `inputSerialization.type` = `Json`, `Csv`, or `Avro` |

### Destination Validation Checklist

| Check | How |
|-------|-----|
| Destination type is valid | Must be `Lakehouse`, `Eventhouse`, `Activator`, or `CustomEndpoint` |
| Target item accessible | Verify `workspaceId` + `itemId` resolve via GET |
| Input wired | `inputNodes` array must not be empty |
| Eventhouse direct ingestion | `connectionName` and `mappingRuleName` set |

### EventstreamProperties Validation

Decode `eventstreamProperties.json` and check:
- `retentionTimeInDays` is within 1–90
- `eventThroughputLevel` is `Low`, `Medium`, or `High`

---

## Gotchas, Rules, Troubleshooting

### MUST DO

- **Always pass `--resource https://api.fabric.microsoft.com`** with `az rest` calls
- **Always use JMESPath filtering** to resolve workspace name → ID and item name → ID
- **Always base64-decode** the definition payload before inspecting topology
- **Handle pagination** — check for `continuationUri` in list responses
- **Poll LRO responses** — Get Definition may return `202 Accepted`

### PREFER

- Decode topology JSON into structured output for readable summaries
- Use `jq` (bash) or `ConvertFrom-Json` (PowerShell) for parsing
- Validate configurations before reporting issues to users
- Cross-reference destinations with downstream skills (eventhouse, sqldw, spark)

### AVOID

- Do NOT confuse Eventstream with Eventhouse — they are separate Fabric workloads
- Do NOT hardcode workspace or item IDs — always discover them via the API
- Do NOT assume all source types appear in API enums — preview sources exist only in the UI
- Do NOT modify Eventstream topology with this consumption skill — use `eventstream-authoring-cli` for writes
- Do NOT attempt to query event data through the Eventstream API — use downstream skills (eventhouse-consumption-cli, sqldw-consumption-cli) for querying landed data
