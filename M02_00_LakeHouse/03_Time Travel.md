## **1. Time Travel (Querying Previous Versions)**

One of the most powerful features of Delta tables is **time travel**. You can query a Delta table as of a specific timestamp or version.

### **Example: Querying Delta Table as of a Specific Timestamp**

```python
# Query Delta table as of a specific timestamp
df_time_travel = spark.read.format("delta").option("timestampAsOf", "2025-04-06 17:16:06").load(delta_table_path)
df_time_travel.show()
```

![image](https://github.com/user-attachments/assets/3998101e-f287-4a18-917e-25f6d8d0195a)


### **Example: Querying Delta Table as of a Specific Version**

```python
# Query Delta table as of a specific version
df_version = spark.read.format("delta").option("versionAsOf", 0).load(delta_table_path)
df_version.show()
# Query Delta table as of a specific version
df_version = spark.read.format("delta").option("versionAsOf", 1).load(delta_table_path)
df_version.show()
# Query Delta table as of a specific version
df_version = spark.read.format("delta").option("versionAsOf", 3).load(delta_table_path)
df_version.show()
# Query Delta table as of a specific version
df_version = spark.read.format("delta").option("versionAsOf", 4).load(delta_table_path)
df_version.show()
```
![image](https://github.com/user-attachments/assets/ca41239e-4771-46d4-bf9f-23cc76119a99)

You can use time travel to retrieve the state of a Delta table as it was at any given point in time or version.

---

## **2. Drop Table**

```sql
%%sql
DROP TABLE IF EXISTS people;
