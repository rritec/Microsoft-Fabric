# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "5f7da4c3-e4b6-83c5-4b70-2403c8964cc6",
# META       "default_lakehouse_name": "bronze",
# META       "default_lakehouse_workspace_id": "00000000-0000-0000-0000-000000000000",
# META       "known_lakehouses": [
# META         {
# META           "id": "2c036b85-0c83-9d53-4ce1-85d935333e4a",
# META           "workspace_id": "00000000-0000-0000-0000-000000000000"
# META         },
# META         {
# META           "id": "5f7da4c3-e4b6-83c5-4b70-2403c8964cc6",
# META           "workspace_id": "00000000-0000-0000-0000-000000000000"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

from pyspark.sql.functions import (
    col, to_date, trim, coalesce, lit, when
)

# Read Bronze data from Files
emp_bronze_df = (
    spark.read
         .option("header", "true")
         .option("inferSchema", "true")
         .option("sep", "|")
         .csv("Files/data/emp.csv")
)

# Preview data (Git-friendly)
emp_bronze_df.printSchema()
emp_bronze_df.show(5)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

spark.conf.set("spark.sql.legacy.timeParserPolicy", "LEGACY")
emp_silver_df = (
    emp_bronze_df
        # Convert hiredate string to DATE
        .withColumn(
            "hiredate",
            to_date(trim(col("hiredate")), "dd-MMM-yy")
        )
        # Replace NULL commission with 0
        .withColumn(
            "comm",
            coalesce(col("comm"), lit(0))
        )
        # Calculate total salary
        .withColumn(
            "totalsal",
            col("sal") + col("comm")
        )
        # Derive salary grade
        .withColumn(
            "salgrade",
            when(col("totalsal") < 2000, "LOW")
            .when(col("totalsal").between(2000, 3400), "MEDIUM")
            .otherwise("HIGH")
        )
)

# Preview transformed data
emp_silver_df.printSchema()
emp_silver_df.show(5)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

emp_silver_df.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("silver.dbo.silver_emp")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.sql("SELECT * FROM silver.dbo.silver_emp LIMIT 1000")
display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
