---
name: eventstream-authoring-cli
description: >
  Create, wire, and publish Microsoft Fabric Eventstream real-time event streaming
  topologies via the Fabric Items REST API. Build graph-based definitions with 25
  source types (Event Hubs, IoT Hub, CDC connectors, Kafka, SampleData), 8
  transformation operators (Filter, Aggregate, GroupBy, Join, ManageFields, Union,
  Expand, SQL), 4 destination types (Lakehouse Delta, Eventhouse, Activator, Custom
  Endpoint), and DefaultStream/DerivedStream routing. Use when the user wants to:
  (1) author or publish an Eventstream topology, (2) add CDC sources with SQL-based
  Debezium payload flattening, (3) assemble multi-table fan-out routing,
  (4) modify or delete Eventstream definitions. Triggers: "create eventstream",
  "deploy eventstream", "design eventstream topology", "CDC source", "eventstream operator",
  "real-time ingestion pipeline", "eventstream definition", "update eventstream".
---

> **Update Check — ONCE PER SESSION (mandatory)**
> The first time this skill is used in a session, run the **check-updates** skill before proceeding.
> - **GitHub Copilot CLI / VS Code**: invoke the `check-updates` skill.
> - **Claude Code / Cowork / Cursor / Windsurf / Codex**: compare local vs remote package.json version.
> - Skip if the check was already performed earlier in this session.

> **CRITICAL NOTES**
> 1. To find the workspace details (including its ID) from workspace name: list all workspaces and, then, use JMESPath filtering
> 2. To find the item details (including its ID) from workspace ID, item type, and item name: list all items of that type in that workspace and, then, use JMESPath filtering
> 3. Eventstream ≠ Eventhouse. Eventstream is a real-time event ingestion and routing pipeline. For KQL database operations, use `eventhouse-authoring-cli` or `eventhouse-consumption-cli`.

# Eventstream Authoring — CLI Skill

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
| Eventstream Resource Model | [EVENTSTREAM-AUTHORING-CORE.md § Eventstream Resource Model](../../common/EVENTSTREAM-AUTHORING-CORE.md#eventstream-resource-model) | **Read first** — graph-based topology with sources, operators, streams, destinations |
| Source Configuration | [EVENTSTREAM-AUTHORING-CORE.md § Source Configuration](../../common/EVENTSTREAM-AUTHORING-CORE.md#source-configuration) | 25 API-supported source types with per-source properties |
| Transformation Operators | [EVENTSTREAM-AUTHORING-CORE.md § Transformation Operators](../../common/EVENTSTREAM-AUTHORING-CORE.md#transformation-operators) | 8 operator types: Filter, Aggregate, GroupBy, Join, ManageFields, Union, Expand, SQL |
| Destination Configuration | [EVENTSTREAM-AUTHORING-CORE.md § Destination Configuration](../../common/EVENTSTREAM-AUTHORING-CORE.md#destination-configuration) | 4 API-supported destination types with node schema |
| Stream Types | [EVENTSTREAM-AUTHORING-CORE.md § Stream Types](../../common/EVENTSTREAM-AUTHORING-CORE.md#stream-types) | DefaultStream (auto) and DerivedStream (from operators) |
| Eventstream Lifecycle (REST API) | [EVENTSTREAM-AUTHORING-CORE.md § Eventstream Lifecycle (REST API)](../../common/EVENTSTREAM-AUTHORING-CORE.md#eventstream-lifecycle-rest-api) | CRUD + Definition endpoints |
| Item Definitions and Deployment | [EVENTSTREAM-AUTHORING-CORE.md § Item Definitions and Deployment](../../common/EVENTSTREAM-AUTHORING-CORE.md#item-definitions-and-deployment) | Base64 encoding pattern for eventstream.json |
| Gotchas and Limitations | [EVENTSTREAM-AUTHORING-CORE.md § Gotchas and Limitations](../../common/EVENTSTREAM-AUTHORING-CORE.md#gotchas-and-limitations) | Max 11 custom endpoints, base64 encoding, naming constraints |
| Create an Eventstream | [SKILL.md § Create an Eventstream](#create-an-eventstream) | |
| Deploy Full Topology | [SKILL.md § Deploy Full Topology](#deploy-full-topology) | End-to-end: build topology JSON → base64 encode → submit definition |
| Update Eventstream Topology | [SKILL.md § Update Eventstream Topology](#update-eventstream-topology) | |
| Delete an Eventstream | [SKILL.md § Delete an Eventstream](#delete-an-eventstream) | |
| Gotchas, Rules, Troubleshooting | [SKILL.md § Gotchas, Rules, Troubleshooting](#gotchas-rules-troubleshooting) | **MUST DO / AVOID / PREFER** checklists |

---

## Create an Eventstream

Create an empty Eventstream item, then configure it with sources, destinations, and operators via the definition API.

### Step 1: Create the Item

```bash
az rest --method POST \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/eventstreams" \
  --resource "https://api.fabric.microsoft.com" \
  --headers "Content-Type=application/json" \
  --body '{"displayName": "my-eventstream", "description": "IoT sensor pipeline"}'
```

Save the returned `id` as `EVENTSTREAM_ID`.

### Step 2: Build the Topology

Construct the `eventstream.json` topology with sources, streams, operators, and destinations. Each node references its upstream via `inputNodes`.

Prefer building the JSON programmatically to avoid serialization errors. Key rules:
- Every source must have a corresponding DefaultStream
- Operators reference their input via `inputNodes[].name`
- DerivedStreams require `inputSerialization` in properties
- Destinations reference their input stream or operator

### Step 3: Deploy the Definition

Base64-encode the topology JSON and submit via the definition API. See [Item Definitions and Deployment](../../common/EVENTSTREAM-AUTHORING-CORE.md#item-definitions-and-deployment) for the full payload structure.

---

## Deploy Full Topology

For deploying a complete Eventstream with topology in a single API call, use the Create Item with Definition endpoint:

```bash
# 1. Build eventstream.json content (topology)
TOPOLOGY_JSON='{"compatibilityLevel":"1.0","sources":[...],"streams":[...],"operators":[...],"destinations":[...]}'

# 2. Build eventstreamProperties.json (optional — controls retention and throughput)
PROPERTIES_JSON='{"retentionTimeInDays":1,"eventThroughputLevel":"Low","schemaMode":"Inferred"}'

# 3. Base64-encode both (no line wraps)
TOPOLOGY_B64=$(echo -n "$TOPOLOGY_JSON" | base64 -w 0)
PROPERTIES_B64=$(echo -n "$PROPERTIES_JSON" | base64 -w 0)

# 4. Submit via Items API
az rest --method POST \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/items" \
  --resource "https://api.fabric.microsoft.com" \
  --headers "Content-Type=application/json" \
  --body "{
    \"displayName\": \"my-eventstream\",
    \"type\": \"Eventstream\",
    \"definition\": {
      \"parts\": [
        {
          \"path\": \"eventstream.json\",
          \"payload\": \"${TOPOLOGY_B64}\",
          \"payloadType\": \"InlineBase64\"
        },
        {
          \"path\": \"eventstreamProperties.json\",
          \"payload\": \"${PROPERTIES_B64}\",
          \"payloadType\": \"InlineBase64\"
        }
      ]
    }
  }"
```

> **Note:** If `eventstreamProperties.json` is omitted, the API applies defaults: `retentionTimeInDays: 1`, `eventThroughputLevel: "Low"`, `schemaMode: "Inferred"`. Include it explicitly to control retention (1–90 days) and throughput.

> On Windows (PowerShell), use `[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json))` for base64 encoding.

---

## Update Eventstream Topology

1. **Get current definition**: `GET /v1/workspaces/{wsId}/eventstreams/{esId}/definition`
2. **Decode** the `eventstream.json` payload from base64
3. **Modify** the topology (add/remove/update nodes)
4. **Re-encode** to base64
5. **Submit**: `PUT /v1/workspaces/{wsId}/eventstreams/{esId}/definition`

The Update Definition API returns `202 Accepted` for long-running operations. Poll the `Location` header URL until completion.

---

## Delete an Eventstream

```bash
az rest --method DELETE \
  --url "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/eventstreams/${EVENTSTREAM_ID}" \
  --resource "https://api.fabric.microsoft.com"
```

Returns `200 OK` on success.

---

## Gotchas, Rules, Troubleshooting

### MUST DO

- **Always base64-encode** the `eventstream.json` payload before submitting definitions
- **Always pass `--resource https://api.fabric.microsoft.com`** with `az rest` calls
- **Always use JMESPath filtering** to resolve workspace name → ID and item name → ID
- **Always include a DefaultStream** for each source in the topology
- **Poll LRO responses** — Update Definition returns `202 Accepted` with a `Location` header

### PREFER

- Build topology JSON programmatically rather than manual string construction
- Use `SampleData` source type for testing and prototyping
- Set `retentionTimeInDays` explicitly rather than relying on defaults
- Validate cloud connections before referencing them in source configurations
- Use DerivedStreams to make operator output available in Real-Time Hub

### AVOID

- Do NOT use raw JSON in the definition payload — it must be base64-encoded
- Do NOT use underscores or dots in Eventstream display names (breaks SQL operator)
- Do NOT exceed 11 combined CustomEndpoint sources and CustomEndpoint/Eventhouse-direct-ingestion destinations
- Do NOT confuse Eventstream with Eventhouse — they are separate Fabric workloads
- Do NOT hardcode workspace or item IDs — always discover them via the API
