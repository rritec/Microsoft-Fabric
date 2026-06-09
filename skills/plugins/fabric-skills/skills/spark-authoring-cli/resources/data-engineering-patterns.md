# Data Engineering Patterns — Skill Resource

Essential patterns and principles for PySpark data engineering in Microsoft Fabric.
## Recommended patterns

### Must

1. **Always define explicit schemas** for production data ingestion — avoid `inferSchema=true` which adds overhead and inconsistency
2. **Use Delta Lake format** for all managed tables — provides ACID guarantees, time travel, and optimized reads
3. **Validate data quality** at ingestion boundaries — check nulls, data types, and business rules before persisting
4. **Add metadata columns** to track lineage — `ingestion_timestamp`, `source_system`, `pipeline_run_id` for debugging
5. **Handle errors gracefully** — wrap ingestion/transformation logic in try-except with proper logging and recovery
6. **Use MERGE for upserts** — leverage Delta Lake's `MERGE INTO` for incremental updates based on merge keys
7. **Partition large tables** — use date or category columns for partition pruning to improve query performance
8. **If a real public source URL is provided, ingest from that source** — download/copy into lakehouse `Files/` first, then load with Spark from lakehouse paths (do not replace with synthetic inline rows)

### Prefer

1. **Batch processing over streaming** unless real-time requirements exist — simpler to debug and monitor
2. **Read-optimized writes** for analytical workloads — use `.coalesce()` or `.repartition()` to right-size output files
3. **Window functions over self-joins** — more efficient for ranking, running totals, and lag/lead operations
4. **Broadcast joins for small dimensions** — use `.broadcast()` hint when one table fits in memory (<100MB)
5. **Columnar operations over row-wise** — leverage DataFrame/SQL API instead of UDFs when possible
6. **Lazy evaluation mindset** — build transformation chains, then execute with actions (`.write()`, `.count()`)

### Avoid

1. **Don't use `.collect()` on large DataFrames** — brings all data to driver, causes OOM errors
2. **Don't chain multiple `.count()` calls** — each triggers a full scan; cache DataFrame if needed
3. **Don't ignore skew** — salting keys or adaptive query execution prevents straggler tasks
4. **Don't skip Delta optimization** — run `OPTIMIZE` and `VACUUM` regularly to prevent small file problem
5. **Don't hardcode paths or credentials** — use parameters and secure configuration patterns
6. **Don't mix append and overwrite** carelessly — understand partition scope for `.mode("overwrite")`

---

## Data Ingestion Principles

### Schema Management
Guide LLM to define explicit schemas with nullable constraints, data type validation, and business context comments.

> **Note**: This section refers to **data schemas** (DataFrame structure). For **lakehouse schemas** (databases/namespaces for organizing tables), see SPARK-AUTHORING-CORE.md Lakehouse Schema Organization.

### Source Format Handling
- **CSV/TSV**: Explicit schema, header option
- **Parquet/ORC**: Columnar formats with embedded schema
- **JSON**: multiLine option for nested objects
- **ADLS Gen2**: `abfss://container@storage.dfs.core.windows.net/path`
- **OneLake**: `abfss://workspace@onelake.dfs.fabric.microsoft.com/lakehouse.Lakehouse/Files/path`
- **Public HTTP/HTTPS datasets**: Download/copy to lakehouse `Files/...` first, then `spark.read` from lakehouse paths for stable runtime behavior

### Validation Patterns
- **Completeness**: Filter nulls in required fields
- **Referential integrity**: Join with dimensions, flag orphans
- **Business rules**: Domain-specific checks (amount > 0, date ranges)
- **Duplicates**: dropDuplicates or groupBy to identify

### Error Handling Strategy
- Try-except blocks with specific exceptions
- Contextual logging
- Dead letter queues for invalid records
- Retry logic for transient failures

---

## Transformation Patterns

### When to Use Different Operations

**Aggregations**: For summarization and metrics; combine multiple in single pass with `.agg()`

**Window Functions**: For ranking (row_number, rank), running calculations (cumulative sums), and lead/lag comparisons; more efficient than self-joins

**Joins**: Inner (matching only), Left (dimension lookups), Broadcast (<100MB tables to avoid shuffle)

### Example Approaches
**Customer Segmentation:** Use window functions for lifetime metrics, when().otherwise() for classification, temporal dimensions for recency

**Product Analytics:** Join with dimensions, aggregate by category, rank with row_number(), compute percentiles

---

## Delta Lake Best Practices

### MERGE Operations (Upserts)
When to use:
- Incremental loads where source sends changed/new records
- Slowly changing dimensions (SCD Type 1 or Type 2)
- Deduplication scenarios

Guide LLM to generate MERGE with:
- `.merge(source_df, "target.id = source.id")` on unique key
- `.whenMatchedUpdateAll()` to update existing records
- `.whenNotMatchedInsertAll()` to insert new records
- Optional: `.whenMatchedDelete()` for hard deletes based on condition

### Optimization Strategies
Tell LLM to include:
- **Z-Ordering**: `OPTIMIZE table_name ZORDER BY (frequently_filtered_column)` improves query speed
- **VACUUM**: `VACUUM table_name RETAIN 168 HOURS` cleans up old file versions after retention period
- **Partition pruning**: Query with partition columns in WHERE clause to skip irrelevant data
- **File compaction**: Run `OPTIMIZE` to combine small files into right-sized files (128MB-1GB)

### Time Travel
Use cases:
- **Point-in-time queries**: `spark.read.format("delta").option("versionAsOf", 5).load(path)`
- **Rollback bad writes**: Restore to previous version with `RESTORE TABLE table_name TO VERSION AS OF 10`
- **Audit trail**: Query historical data for compliance, debugging

### Spark Session Configurations for Performance

Guide LLM to configure Spark sessions based on workload type:

**Write-Heavy Workloads (Bronze Layer - High-Volume Ingestion):**
- `spark.microsoft.delta.parquet.vorder.enabled = false` — Disable V-Order for faster writes
- `spark.databricks.delta.optimizeWrite.binSize = 1073741824` — Target 1GB file size for fewer small files
- `spark.databricks.delta.autoCompact.enabled = true` — Automatic compaction during writes
- `spark.microsoft.delta.optimize.fast.enabled = true` — Fast optimization algorithms
- `spark.databricks.delta.properties.defaults.enableDeletionVectors = true` — Efficient delete tracking
- `spark.microsoft.delta.targetFileSize.adaptive.enabled = true` — Adaptive file sizing
- `spark.native.enabled = true` — Use native execution engine (Velox)
- `spark.gluten.delta.columnMapping.name.enabled = true` — Column mapping for schema evolution

**Balanced Workloads (Silver Layer - Mixed Read/Write):**
- `spark.microsoft.delta.parquet.vorder.enabled = true` — Enable V-Order for better read performance
- `spark.databricks.delta.optimizeWrite.enabled = true` — Balance write optimization with read efficiency
- `spark.microsoft.delta.snapshot.driverMode.enabled = true` — Faster snapshot reads
- `spark.sql.adaptive.enabled = true` — Adaptive query execution
- `spark.sql.adaptive.coalescePartitions.enabled = true` — Dynamic partition coalescing

**Read-Heavy Workloads (Gold Layer - Analytics & Reporting):**
- `spark.microsoft.delta.parquet.vorder.enabled = true` — V-Order for maximum read performance
- `spark.databricks.delta.optimizeWrite.enabled = false` — No write optimization overhead
- `spark.sql.parquet.enableVectorizedReader = true` — Vectorized Parquet reads
- `spark.sql.files.maxPartitionBytes = 134217728` — 128MB partition size for optimal parallelism
- `spark.sql.adaptive.enabled = true` — Optimize query plans based on runtime stats
- `spark.databricks.delta.stalenessLimit = 0` — Always use latest snapshot

**When to apply these configs:**
- Pass during Livy session creation: `"conf": {"spark.config.key": "value"}`
- Set in notebook first cell before any Spark operations
- Configure at workspace level for consistent defaults
- Override per-job for specific workload requirements

---

## Quality Assurance Strategies

### Testing Levels
Guide LLM to implement:

**Unit Testing** (local Spark):
- Test transformation logic with small sample DataFrames
- Use `pytest` fixtures to create test Spark session
- Assert row counts, column values, schema correctness
- Focus on business logic in isolation

**Integration Testing** (Fabric API):
- Validate workspace/lakehouse creation succeeded
- Test notebook deployment via REST API
- Verify Livy session creation and code execution
- Check end-to-end data flow through bronze → silver → gold

**Data Quality Checks** (production):
- Row count validation: compare source vs target
- Schema validation: ensure expected columns exist with correct types
- Null checks: flag unexpected nulls in required fields
- Range checks: validate numeric values within expected bounds
- Freshness checks: ensure data updated within SLA timeframe

### Quality Gates
Define when pipelines should fail:
- **Critical failures**: schema mismatch, zero rows ingested, primary key violations
- **Warnings**: elevated null rate, data volume anomaly (>20% change), late arrival
- **Monitoring**: track ingestion lag, transformation duration, error rates over time

### Logging and Observability
Prompt LLM to generate:
- **Structured logging**: JSON-formatted logs with timestamp, severity, context
- **Metrics emission**: log key counts (rows processed, errors, duration) for monitoring
- **Error context**: capture input values, stack traces, environment details for debugging
