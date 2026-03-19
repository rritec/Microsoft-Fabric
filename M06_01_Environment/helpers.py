# helpers.py
# Shared Python utility script stored in Fabric Environment Resources
# Import this in any notebook using importlib

import json
import yaml


def load_config(config_path: str) -> dict:
    """Load a YAML config file from Resources."""
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def load_schema(schema_path: str) -> dict:
    """Load a JSON schema contract from Resources."""
    with open(schema_path, "r") as f:
        return json.load(f)


def load_sql(sql_path: str) -> str:
    """Load a SQL query string from Resources."""
    with open(sql_path, "r") as f:
        return f.read().strip()


def validate_schema(df, schema: dict) -> dict:
    """
    Validates a PySpark DataFrame against a JSON schema contract.

    Args:
        df     : PySpark DataFrame
        schema : dict loaded from schema.json

    Returns:
        dict: {column: {expected, actual, passed}}
    """
    results = {}
    df_schema = {f.name: str(f.dataType) for f in df.schema.fields}

    for col_def in schema.get("columns", []):
        col_name     = col_def["name"]
        expected_type = col_def["type"]
        actual_type   = df_schema.get(col_name, "MISSING")
        passed        = actual_type == expected_type

        results[col_name] = {
            "expected": expected_type,
            "actual"  : actual_type,
            "passed"  : passed
        }

    total  = len(results)
    passed = sum(1 for r in results.values() if r["passed"])
    return {
        "checks"    : results,
        "total"     : total,
        "passed"    : passed,
        "failed"    : total - passed,
        "all_passed": passed == total
    }


def print_config_summary(config: dict):
    """Pretty print a config summary."""
    print("=" * 50)
    print("  PIPELINE CONFIG SUMMARY")
    print("=" * 50)
    p = config.get("pipeline", {})
    print(f"  Name        : {p.get('name')}")
    print(f"  Version     : {p.get('version')}")
    print(f"  Environment : {p.get('environment')}")
    lh = config.get("lakehouse", {})
    print(f"  Lakehouse   : {lh.get('name')}")
    wh = config.get("warehouse", {})
    print(f"  Warehouse   : {wh.get('name')}")
    dq = config.get("data_quality", {})
    print(f"  Max null %  : {dq.get('max_null_pct')}%")
    print(f"  Key cols    : {dq.get('key_cols')}")
    print("=" * 50)
