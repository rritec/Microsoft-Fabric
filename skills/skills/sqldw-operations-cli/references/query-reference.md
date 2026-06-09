# Query Reference — sqldw-operations-cli

Detailed T-SQL queries for all monitoring and diagnostic analyses. All queries target the built-in `queryinsights` schema and system DMVs available in Fabric Data Warehouse.

> **Data source:** `queryinsights` views retain 30 days of history. Data appears with up to 15 minutes delay after query completion.

---

## Performance Analysis Queries

### Long-Running Queries Summary

**Purpose:** Find the slowest queries from `queryinsights.long_running_queries`.

```sql
SELECT TOP @limit
    last_run_command,
    last_run_total_elapsed_time_ms,
    median_total_elapsed_time_ms,
    number_of_runs
FROM queryinsights.long_running_queries
ORDER BY last_run_total_elapsed_time_ms DESC;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@limit` | 5 | Max queries to return |

**Return fields:**

| Field | Type | Description |
|-------|------|-------------|
| `last_run_command` | string | SQL query text |
| `last_run_total_elapsed_time_ms` | integer | Last execution time (ms) |
| `median_total_elapsed_time_ms` | integer | Median execution time across all runs (ms) |
| `number_of_runs` | integer | Total executions |

**Response formatting** — present each result as:
> Query '{first 50 chars}...' ran {number_of_runs} times, last took {last_run_total_elapsed_time_ms} ms (median {median_total_elapsed_time_ms} ms).

---

### Top Resource Consumers

**Purpose:** Identify CPU- and storage-heavy queries with performance recommendations.

```sql
SELECT TOP @limit
    command,
    total_elapsed_time_ms,
    allocated_cpu_time_ms,
    data_scanned_remote_storage_mb,
    data_scanned_memory_mb,
    data_scanned_disk_mb
FROM queryinsights.exec_requests_history
WHERE start_time > DATEADD(HOUR, -@hours, GETUTCDATE())
ORDER BY allocated_cpu_time_ms DESC;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@limit` | 5 | Max results |
| `@hours` | 1 | Time window in hours |

**Return fields:**

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | SQL query text |
| `total_elapsed_time_ms` | integer | Execution time (ms) |
| `allocated_cpu_time_ms` | integer | CPU time consumed (ms) |
| `data_scanned_remote_storage_mb` | float | Data from OneLake (cold) |
| `data_scanned_memory_mb` | float | Data from memory cache |
| `data_scanned_disk_mb` | float | Data from disk cache |

**Recommendation thresholds:**

| Condition | Recommendation |
|-----------|----------------|
| Remote scans > 1,000 MB | Review data layout; consider OPTIMIZE/clustering |
| CPU > 5,000,000 ms | Review query logic; reduce joins/aggregations |
| Elapsed > 300,000 ms (5 min) | Check joins, filters, and statistics |

---

### Top Users Insights

**Purpose:** Analyze user activity and query patterns using a ranked CTE.

```sql
WITH UserStats AS (
    SELECT
        COALESCE(login_name, 'Unknown User') AS user_name,
        COUNT(*) AS total_queries,
        AVG(total_elapsed_time_ms) AS avg_elapsed_time_ms,
        MAX(total_elapsed_time_ms) AS max_elapsed_time_ms,
        AVG(allocated_cpu_time_ms) AS avg_cpu_time_ms,
        SUM(allocated_cpu_time_ms) AS total_cpu_time_ms,
        AVG(data_scanned_remote_storage_mb + data_scanned_memory_mb + data_scanned_disk_mb) AS avg_data_scanned_mb,
        SUM(data_scanned_remote_storage_mb + data_scanned_memory_mb + data_scanned_disk_mb) AS total_data_scanned_mb,
        COUNT(CASE WHEN status = 'Failed' THEN 1 END) AS failed_queries,
        COUNT(DISTINCT CONVERT(DATE, start_time)) AS active_days,
        MIN(start_time) AS first_query_time,
        MAX(start_time) AS last_query_time
    FROM queryinsights.exec_requests_history
    WHERE start_time > DATEADD(HOUR, -@hours, GETUTCDATE())
    GROUP BY login_name
    HAVING COUNT(*) >= @min_queries
),
RankedUsers AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY total_queries DESC, total_cpu_time_ms DESC) AS user_rank
    FROM UserStats
)
SELECT TOP @limit
    user_name, total_queries, avg_elapsed_time_ms, max_elapsed_time_ms,
    avg_cpu_time_ms, total_cpu_time_ms, avg_data_scanned_mb,
    total_data_scanned_mb, failed_queries, active_days,
    first_query_time, last_query_time, user_rank
FROM RankedUsers
ORDER BY user_rank;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@limit` | 5 | Max users to analyze |
| `@hours` | 24 | Time window |
| `@min_queries` | 1 | Minimum query count for inclusion |

**Return fields:**

| Field | Type | Description |
|-------|------|-------------|
| `user_name` | string | Login name (or 'Unknown User') |
| `total_queries` | integer | Total query count |
| `avg_elapsed_time_ms` | float | Average execution time |
| `max_elapsed_time_ms` | integer | Slowest single query |
| `avg_cpu_time_ms` | float | Average CPU per query |
| `total_cpu_time_ms` | bigint | Total CPU consumed |
| `avg_data_scanned_mb` | float | Avg data scanned per query |
| `total_data_scanned_mb` | float | Total data scanned |
| `failed_queries` | integer | Count of failed queries |
| `active_days` | integer | Distinct days with activity |
| `first_query_time` | datetime | First query timestamp |
| `last_query_time` | datetime | Most recent query timestamp |
| `user_rank` | integer | Rank by total_queries then CPU |

**Response formatting:**
- **User summary**: "{user_name} executed {total_queries} queries over {active_days} days, with {success_rate}% success rate."
- **Query pattern**: Classify as "Long-running analytical" (avg > 60s), "High-frequency operational" (>100/day), "Data-intensive" (avg > 1GB scanned), or "Mixed"
- **CPU intensity**: Low (<1s), Medium (1–10s), High (>10s avg)

---

### Compare Recent vs Baseline

**Purpose:** Detect performance regressions by comparing recent window against historical baseline.

```sql
WITH recent AS (
    SELECT
        AVG(total_elapsed_time_ms) AS avg_recent_elapsed_ms,
        AVG(allocated_cpu_time_ms) AS avg_recent_cpu_ms,
        AVG(data_scanned_remote_storage_mb + data_scanned_memory_mb + data_scanned_disk_mb) AS avg_recent_data_scanned_mb
    FROM queryinsights.exec_requests_history
    WHERE start_time > DATEADD(HOUR, -@hours, GETUTCDATE())
      AND status = 'Succeeded'
),
baseline AS (
    SELECT
        AVG(total_elapsed_time_ms) AS avg_baseline_elapsed_ms,
        AVG(allocated_cpu_time_ms) AS avg_baseline_cpu_ms,
        AVG(data_scanned_remote_storage_mb + data_scanned_memory_mb + data_scanned_disk_mb) AS avg_baseline_data_scanned_mb
    FROM queryinsights.exec_requests_history
    WHERE start_time > DATEADD(DAY, -@days_back, GETUTCDATE())
      AND start_time <= DATEADD(HOUR, -@hours, GETUTCDATE())
      AND status = 'Succeeded'
)
SELECT
    r.avg_recent_elapsed_ms,
    b.avg_baseline_elapsed_ms,
    r.avg_recent_cpu_ms,
    b.avg_baseline_cpu_ms,
    r.avg_recent_data_scanned_mb,
    b.avg_baseline_data_scanned_mb
FROM recent r
CROSS JOIN baseline b;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@hours` | 1 | Size of the recent analysis window |
| `@days_back` | 7 | Days back for baseline comparison |

**Return fields:**

| Field | Description |
|-------|-------------|
| `avg_recent_elapsed_ms` | Recent window average elapsed time |
| `avg_baseline_elapsed_ms` | Baseline period average elapsed time |
| `avg_recent_cpu_ms` | Recent window average CPU time |
| `avg_baseline_cpu_ms` | Baseline period average CPU time |
| `avg_recent_data_scanned_mb` | Recent window average data scanned |
| `avg_baseline_data_scanned_mb` | Baseline period average data scanned |

**Response formatting** — compute percent change for each metric. Flag regressions > 20% with a warning.

---

### Recent Queries

**Purpose:** Retrieve the most recently executed queries.

```sql
SELECT TOP @limit
    distributed_statement_id,
    login_name,
    command,
    start_time,
    total_elapsed_time_ms,
    status
FROM queryinsights.exec_requests_history
ORDER BY start_time DESC;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@limit` | 10 | Max queries to return |

---

### Search Query Patterns

**Purpose:** Search historical query patterns by table name, column, or keyword.

```sql
SELECT TOP @limit
    query_hash,
    COUNT(*) AS execution_count,
    AVG(total_elapsed_time_ms) AS avg_elapsed_ms,
    MIN(total_elapsed_time_ms) AS min_elapsed_ms,
    MAX(total_elapsed_time_ms) AS max_elapsed_ms,
    MAX(command) AS sample_command
FROM queryinsights.exec_requests_history
WHERE command LIKE '%' + @search_term + '%'
  AND command NOT LIKE '%queryinsights%'
GROUP BY query_hash
HAVING COUNT(*) >= @min_execution_count
ORDER BY execution_count DESC;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@search_term` | _(required)_ | Text to search for |
| `@min_execution_count` | 1 | Minimum pattern execution count |
| `@limit` | 10 | Max patterns to return |

---

## Deep Diagnostics Queries

### Long-Running Query Analysis

**Purpose:** Identify queries exceeding a duration threshold for deeper investigation.

```sql
SELECT TOP @limit
    distributed_statement_id,
    command,
    total_elapsed_time_ms,
    allocated_cpu_time_ms,
    data_scanned_remote_storage_mb,
    data_scanned_memory_mb,
    result_cache_hit
FROM queryinsights.exec_requests_history
WHERE total_elapsed_time_ms >= @min_duration_ms
  AND status = 'Succeeded'
ORDER BY total_elapsed_time_ms DESC;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@limit` | 3 | Max queries to analyze |
| `@min_duration_ms` | 30000 | Minimum duration threshold (ms) |

**Analysis checklist:**
- High `data_scanned_remote_storage_mb` → data layout issues
- High `allocated_cpu_time_ms` relative to elapsed → CPU-bound query
- High elapsed but low CPU → resource contention (check pressure windows)
- `result_cache_hit = 0` on repeated queries → cache not effective

---

### Pressure Window Analysis

**Purpose:** Identify SQL pool pressure events from `queryinsights.sql_pool_insights` and find the heaviest queries running during those windows.

**Step 1** — Find pressure windows by consolidating consecutive pressure events:

```sql
WITH PressureEvents AS (
    SELECT
        timestamp,
        sql_pool_name,
        max_resource_percentage,
        is_pool_under_pressure,
        current_workspace_capacity,
        LAG(timestamp) OVER (PARTITION BY sql_pool_name ORDER BY timestamp) AS prev_timestamp
    FROM queryinsights.sql_pool_insights
    WHERE timestamp > DATEADD(HOUR, -@hours, GETUTCDATE())
      AND is_pool_under_pressure = 1
),
WindowBoundaries AS (
    SELECT
        timestamp, sql_pool_name, max_resource_percentage, current_workspace_capacity,
        CASE
            WHEN prev_timestamp IS NULL
              OR DATEDIFF(SECOND, prev_timestamp, timestamp) > 120
            THEN 1
            ELSE 0
        END AS is_window_start
    FROM PressureEvents
),
WindowGroups AS (
    SELECT
        timestamp, sql_pool_name, max_resource_percentage, current_workspace_capacity,
        SUM(is_window_start) OVER (
            PARTITION BY sql_pool_name ORDER BY timestamp ROWS UNBOUNDED PRECEDING
        ) AS window_id
    FROM WindowBoundaries
)
SELECT
    sql_pool_name,
    window_id,
    MIN(timestamp) AS window_start,
    MAX(timestamp) AS window_end,
    DATEDIFF(SECOND, MIN(timestamp), MAX(timestamp)) AS duration_seconds,
    COUNT(*) AS pressure_data_points,
    MAX(max_resource_percentage) AS peak_resource_pct,
    MAX(current_workspace_capacity) AS capacity_sku
FROM WindowGroups
GROUP BY sql_pool_name, window_id
ORDER BY MIN(timestamp) DESC;
```

**Step 2** — For each pressure window, find overlapping queries (substitute actual `window_start`/`window_end` timestamps from Step 1):

```sql
-- Replace '<window_start>' and '<window_end>' with actual timestamps from Step 1
SELECT TOP @top_n
    command,
    login_name,
    start_time,
    end_time,
    total_elapsed_time_ms,
    allocated_cpu_time_ms,
    data_scanned_remote_storage_mb,
    data_scanned_memory_mb,
    data_scanned_disk_mb,
    status,
    result_cache_hit,
    query_hash
FROM queryinsights.exec_requests_history
WHERE start_time <= '<window_end>'
  AND end_time >= '<window_start>'
  AND command IS NOT NULL
  AND LEN(command) > 20
ORDER BY allocated_cpu_time_ms DESC;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@hours` | 24 | Hours back to analyze |
| `@top_n` | 5 | Max queries per pressure window |

**Response formatting** — for each overlapping query, classify problems:
- CPU > 5M ms → "Extremely high CPU", >1M → "Very high CPU", >100K → "High CPU"
- Remote storage > 1,000 MB → "Heavy remote storage scans (cold data)"
- Total data > 5 GB → "Massive data scan", > 1 GB → "Large data scan"
- Elapsed > 5 min → "Very long running", > 1 min → "Long running"
- `result_cache_hit = 0` and elapsed > 30s → "Cache miss on slow query"
- `SELECT *` detected → "Uses SELECT * (missing column pruning)"

**Global recommendations** — based on aggregate analysis:
- If SELECT pool has more pressure → read-heavy workload, suggest caching and column pruning
- If NONSELECT pool has more pressure → write-heavy, suggest batching and COPY INTO
- If total pressure > 60 min → suggest scaling capacity or staggering workloads

---

### Cache Warmth Analysis

**Purpose:** Compare cold (remote storage) vs warm (memory/disk) reads for repeated queries using a CTE with hash-level grouping.

```sql
WITH hash_stats AS (
    SELECT
        query_hash,
        COUNT(*) AS run_count
    FROM queryinsights.exec_requests_history
    WHERE query_hash IS NOT NULL
      AND status = 'Succeeded'
      AND start_time > DATEADD(HOUR, -@hours, GETUTCDATE())
    GROUP BY query_hash
    HAVING COUNT(*) >= @min_runs
)
SELECT TOP 500
    e.query_hash,
    e.start_time,
    e.total_elapsed_time_ms,
    e.allocated_cpu_time_ms,
    e.data_scanned_remote_storage_mb,
    e.data_scanned_memory_mb,
    e.data_scanned_disk_mb,
    e.result_cache_hit,
    e.row_count,
    LEFT(e.command, 200) AS command_snippet,
    e.login_name,
    h.run_count
FROM queryinsights.exec_requests_history e
INNER JOIN hash_stats h ON e.query_hash = h.query_hash
WHERE e.status = 'Succeeded'
  AND e.start_time > DATEADD(HOUR, -@hours, GETUTCDATE())
ORDER BY h.run_count DESC, e.query_hash, e.start_time;
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `@hours` | 24 | Time window to analyze |
| `@min_runs` | 2 | Minimum executions per query_hash to include |

**Classification logic** — for each execution, compute `total_mb = remote + memory + disk`:
- `result_cache_hit = 1` → **cached**
- `total_mb = 0` → **no-scan**
- `remote_mb / total_mb > 0.8` → **cold** (>80% from remote storage)
- `(memory_mb + disk_mb) / total_mb > 0.8` → **warm** (>80% from cache)
- Otherwise → **mixed**

**Overall pattern per query_hash:**
- `always-cold`: Every run is cold — never benefits from caching
- `always-warm`: Every run is warm — well cached
- `warming-up`: Started cold, latest run is warm
- `inconsistent`: Mix of cold and warm runs
- `always-cached`: Result set cache hit every time

**Recommendations:**
- Over 50% cold runs → Enable result set caching: `ALTER DATABASE SET RESULT_SET_CACHING ON;`
- Always-cold patterns → Check for `GETDATE()`/`GETUTCDATE()` or volatile functions that bust the cache key
- Compare avg cold elapsed vs avg warm elapsed to calculate warm speedup ratio

---

### Cluster Key Recommendations

**Purpose:** Use a two-phase approach to identify tables that would benefit from data clustering.

**Phase 1 (data-volume)**: Aggregate query_hash groups to find the highest total data scanned.

```sql
SELECT
    query_hash,
    COUNT(*) AS exec_count,
    AVG(total_elapsed_time_ms) AS avg_elapsed_ms,
    AVG(allocated_cpu_time_ms) AS avg_cpu_ms,
    SUM(CAST(data_scanned_remote_storage_mb AS BIGINT)) AS total_remote_mb,
    AVG(data_scanned_remote_storage_mb) AS avg_remote_mb,
    MAX(command) AS sample_command
FROM queryinsights.exec_requests_history
WHERE status = 'Succeeded'
  AND command IS NOT NULL
  AND LEN(command) > 20
  AND start_time > DATEADD(HOUR, -168, GETUTCDATE())  -- 7 days
  AND command NOT LIKE '%queryinsights%'
  AND command NOT LIKE '%INFORMATION_SCHEMA%'
  AND command NOT LIKE '%sys.%'
GROUP BY query_hash
HAVING COUNT(*) >= 3
ORDER BY SUM(CAST(data_scanned_remote_storage_mb AS BIGINT)) DESC;
```

**Phase 2 (predicate-parsing)**: Examine `sample_command` for each hash to identify:
1. Tables in `FROM` / `JOIN` clauses (handles 3-part, 2-part, and 1-part names)
2. Columns in `WHERE` predicates (range filters, `IN`, `BETWEEN`, comparisons) — these are cluster key candidates
3. Score columns by: predicate usage count + cardinality + data type suitability

> **Important:** Equality `JOIN ON` conditions do **NOT** benefit from data clustering. Only `WHERE` filter predicates benefit.

**Cardinality guidance** — prefer mid-to-high cardinality columns:
- High cardinality (many distinct values, e.g., date, ID) → best candidates — enables efficient file skipping
- Low cardinality (few distinct values, e.g., gender, region) → poor candidates — limited pruning benefit

**Fallback heuristic** — when predicates can't be parsed, use column metadata:
- Date/time columns with mid-to-high cardinality → strong cluster key candidates (score 50)
- Columns ending in `_sk`, `_id`, `_key`, `Date`, `Time` → moderate candidates (score 30)
- Integer columns → weak candidates (score 15)

**Row count verification** — use `sys.partitions` with `COUNT` fallback:

```sql
-- Try sys.partitions first
SELECT SUM(p.rows) AS row_count
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
WHERE s.name = 'dbo' AND t.name = 'FactSales';

-- If 0, use COUNT fallback
SELECT SUM(CAST(1 AS BIGINT)) AS rc FROM [dbo].[FactSales];
```

**Ranking**: Primary = total data scanned (I/O impact). Secondary = query_count * row_count.

**To apply clustering** — use CTAS (ALTER TABLE not supported in Fabric):

```sql
-- Step 1: Create clustered copy
CREATE TABLE dbo.FactSales_clustered
WITH (CLUSTER BY (SaleDate, Region))
AS SELECT * FROM dbo.FactSales;
```

**Post-CTAS table swap** — replace the original table using `sp_rename`:

```sql
-- Step 2: Rename original table
EXEC sp_rename 'dbo.FactSales', 'FactSales_old';

-- Step 3: Rename clustered table to original name
EXEC sp_rename 'dbo.FactSales_clustered', 'FactSales';

-- Step 4: Verify, then drop old table
-- DROP TABLE IF EXISTS dbo.FactSales_old;
```

**Verify clustering columns** after swap:

```sql
SELECT
    t.name AS table_name,
    c.name AS column_name,
    ic.data_clustering_ordinal AS clustering_ordinal
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.index_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE ic.data_clustering_ordinal > 0 AND t.name = 'FactSales'
ORDER BY ic.data_clustering_ordinal;
```

> **Note:** Fabric does not support `ALTER TABLE SET DATA_CLUSTERING_KEY` or `RENAME OBJECT`. Always use CTAS with `WITH (CLUSTER BY (...))` and `sp_rename` for table swaps.
