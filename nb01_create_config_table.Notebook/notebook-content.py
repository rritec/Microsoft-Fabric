# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "c8964cc6-2403-4b70-83c5-e4b65f7da4c3",
# META       "default_lakehouse_name": "bronze",
# META       "default_lakehouse_workspace_id": "12f495ce-6aee-4531-98b5-aad2886e82a5",
# META       "known_lakehouses": [
# META         {
# META           "id": "c8964cc6-2403-4b70-83c5-e4b65f7da4c3"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

# MAGIC %%sql
# MAGIC drop table if exists tgtemp

# METADATA ********************

# META {
# META   "language": "sparksql",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# MAGIC %%sql
# MAGIC create table tgtemp(col1 int,col2 int)

# METADATA ********************

# META {
# META   "language": "sparksql",
# META   "language_group": "synapse_pyspark"
# META }
