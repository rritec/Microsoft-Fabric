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
# META           "id": "c9b06928-81f8-a899-402f-4f3aecb89715",
# META           "workspace_id": "00000000-0000-0000-0000-000000000000"
# META         },
# META         {
# META           "id": "e7bf30d6-1e0c-48d1-b396-aaca203aeda6"
# META         },
# META         {
# META           "id": "5f7da4c3-e4b6-83c5-4b70-2403c8964cc6",
# META           "workspace_id": "00000000-0000-0000-0000-000000000000"
# META         }
# META       ]
# META     },
# META     "warehouse": {
# META       "known_warehouses": []
# META     }
# META   }
# META }

# CELL ********************

# Welcome to your new notebook
# Type here in the cell editor to add code!


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.sql("SELECT * FROM `ram-test`.lh_test.dbo.emp LIMIT 1000")
display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df = spark.sql("SELECT * FROM bronze.dbo.emp LIMIT 1000")
display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
