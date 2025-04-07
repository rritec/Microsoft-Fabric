# Delta_table_Schema_Evolution
## Step 1: Create Initial Delta Table (employees)
``` python
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, FloatType

# Define consistent schema
schema = StructType([
    StructField("id", IntegerType(), True),
    StructField("name", StringType(), True),
    StructField("salary", FloatType(), True)
])

data = [(1, "Alice", 5000.0), (2, "Bob", 6000.0)]
df = spark.createDataFrame(data, schema)

delta_table_path="Tables/dbo/employees"

# Overwrite table
df.write.format("delta") \
    .mode("overwrite") \
    .save(delta_table_path)

# Read table
df = spark.sql("SELECT * FROM rr_master_lakehouse.dbo.employees LIMIT 1000")
display(df)

```
![image](https://github.com/user-attachments/assets/b1fc5d78-6c00-49ec-ba13-75878ae4c875)


## Step 2: Try Schema Enforcement (This will fail)(Observe Error Msg)
``` python
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

# Wrong type for salary (String) and extra column age
schema_wrong = StructType([
    StructField("id", IntegerType(), True),
    StructField("name", StringType(), True),    
    StructField("salary", FloatType(), True), 
    StructField("age", IntegerType(), True)   # Wrong Column
])

data_wrong = [(3, "Charlie", 8000.50, 30)]

df_invalid = spark.createDataFrame(data_wrong, schema_wrong)

# This will fail due to schema enforcement
df_invalid.write.format("delta") \
    .mode("append") \
    .save(delta_table_path)

```
![image](https://github.com/user-attachments/assets/418e8908-8103-4fd9-a2ca-032bb769588d)

## Step 3: Enable Schema Evolution
``` python
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, FloatType

# Correct salary type and new age column
schema_new = StructType([
    StructField("id", IntegerType(), True),
    StructField("name", StringType(), True),
    StructField("salary", FloatType(), True),
    StructField("age", IntegerType(), True)
])

data_new = [(4, "David", 5500.0, 28)]
df_new = spark.createDataFrame(data_new, schema_new)

df_new.write.format("delta") \
    .option("mergeSchema", "true") \
    .mode("append") \
    .save(delta_table_path)

df = spark.sql("SELECT * FROM rr_master_lakehouse.dbo.employees LIMIT 1000")
display(df)

```
![image](https://github.com/user-attachments/assets/84fa6c93-a378-4443-91dc-816d8c8c6d01)

## Step 4: Check Updated Schema
``` sql
%%sql
desc rr_master_lakehouse.dbo.employees
```
![image](https://github.com/user-attachments/assets/38c3b041-8069-4d4b-b8f8-96af0ee3e220)

``` sql
%%sql
select * from  rr_master_lakehouse.dbo.employees
```
![image](https://github.com/user-attachments/assets/3b569c7b-32a4-4660-9324-e7c107792fad)

