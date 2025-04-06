
# **Working with Delta Tables in Microsoft Fabric**

This guide will walk you through the basic operations you can perform on **Delta Tables** in **Microsoft Fabric** (or **Azure Synapse Analytics**). We'll cover creating a table, updating records, deleting records, and merging data.

## **1. Introduction to Delta Tables**

Delta Lake is an open-source storage layer that brings **ACID transactions** to Apache Spark and big data workloads. Delta tables support features like:

- **ACID transactions**
- **Time travel (data versioning)**
- **Schema enforcement and evolution**

---

## **2. Setting Up Your Environment**

Before starting, ensure you have **Microsoft Fabric** or **Azure Synapse Analytics** connected to your **Spark** environment and that you have access to Delta Lake functionality.

### **Step 1: Import Required Libraries**

```python
# from pyspark.sql import SparkSession # not required in fabric
from delta.tables import *
```

### **Step 2: Initialize Spark Session with Delta Support**

```python
# spark = SparkSession.builder     .appName("DeltaTableOperations")     .getOrCreate() # not required in fabric
```

---

## **3. Create a Delta Table**

Creating a Delta table is simple. You can either create it from an existing **DataFrame** or convert a **Parquet** table to a Delta table.

### **Example: Creating a Delta Table from DataFrame**

```python
# Sample data
data = [("John", 25), ("Jane", 30), ("Myla RamReddy", 35)]

# Define schema
columns = ["ename", "age"]

# Create DataFrame
df = spark.createDataFrame(data, columns)

# Table path
delta_table_path="Tables/dbo/people"

# Write the DataFrame to a Delta table
df.write.format("delta").save(delta_table_path)
```


---

## **4. Update Data in a Delta Table**

To update data in Delta tables, you can use the **DeltaTable** API with **`update()`**.

### **Example: Updating Records in Delta Table**

Let’s say you want to update the **age** of a person named **"John"**.

```python
# Create Delta table reference
delta_table = DeltaTable.forPath(spark, delta_table_path)

# Perform an UPDATE operation
delta_table.update(
    condition = "name = 'John'",  # Condition to identify the row
    set = {"age": "29"}           # Set new value for the column
)
```

This will update **John's** age to **29**.

---

## **5. Delete Data from a Delta Table**

You can delete rows from a Delta table using the **`delete()`** method.

### **Example: Deleting Records from Delta Table**

Let's delete the record where **name = 'Jane'**:

```python
# Create Delta table reference
delta_table = DeltaTable.forPath(spark, delta_table_path)

# Perform DELETE operation
delta_table.delete(condition = "name = 'Jane'")
```

This will delete **Jane's** record from the Delta table.

---

## **6. Merge Data in a Delta Table**

The **MERGE** operation allows you to update, insert, or delete records based on a condition. This is helpful when you want to perform **upserts** (insert and update simultaneously).

### **Example: MERGE Operation**

Let’s say we have another DataFrame with updated data, and we want to merge it into the existing Delta table.

```python
# New DataFrame with updated data
new_data = [("John", 32), ("Sam", 28)]  # John's age is now 32

# Create DataFrame
new_df = spark.createDataFrame(new_data, columns)

# Create Delta table reference
delta_table = DeltaTable.forPath(spark, delta_table_path)

# Perform MERGE (Upsert)
delta_table.alias("target").merge(
    new_df.alias("source"),
    "target.name = source.name"
).whenMatchedUpdate(set = {"age": "source.age"})  .whenNotMatchedInsert(values = {"name": "source.name", "age": "source.age"})  .execute()
```

In this case, if **John** already exists in the Delta table, his record will be **updated** to age **32**. If there were any new records (like **Sam**), they would be **inserted**.

---

## **7. Time Travel (Querying Previous Versions)**

One of the most powerful features of Delta tables is **time travel**. You can query a Delta table as of a specific timestamp or version.

### **Example: Querying Delta Table as of a Specific Timestamp**

```python
# Query Delta table as of a specific timestamp
df_time_travel = spark.read.format("delta").option("timestampAsOf", "2025-04-05 09:00:00").load("/mnt/delta/people")
df_time_travel.show()
```

### **Example: Querying Delta Table as of a Specific Version**

```python
# Query Delta table as of a specific version
df_version = spark.read.format("delta").option("versionAsOf", 2).load("/mnt/delta/people")
df_version.show()
```

You can use time travel to retrieve the state of a Delta table as it was at any given point in time or version.

---

## **8. Conclusion**

In this guide, we’ve covered the basic operations that you can perform on Delta tables in **Microsoft Fabric** or **Azure Synapse Analytics**:

1. **Create a Delta table** from a DataFrame or Parquet.
2. **Update records** in a Delta table.
3. **Delete records** from a Delta table.
4. **Merge** data into a Delta table.
5. **Time Travel** to query previous versions of the table.

Delta Lake provides powerful features for managing large-scale data pipelines and ensuring data consistency and reliability.

---

## **Next Steps**

1. **Explore Schema Evolution**: Delta supports automatic schema evolution when new columns are added to the data.
2. **Performance Optimization**: Learn about **Z-Ordering** and **Partitioning** to optimize Delta table performance.

Happy learning and experimenting with Delta Lake in Microsoft Fabric!
