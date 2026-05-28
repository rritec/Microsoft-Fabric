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
# META         },
# META         {
# META           "id": "35333e4a-85d9-4ce1-9d53-0c832c036b85"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

notebookutils.help()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

notebookutils.fs.help()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

notebookutils.fs.help('mkdirs')

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

notebookutils.fs.mkdirs("Files/tmp/a/b/d")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

notebookutils.fs.mkdirs("abfss://12f495ce-6aee-4531-98b5-aad2886e82a5@onelake.dfs.fabric.microsoft.com/c8964cc6-2403-4b70-83c5-e4b65f7da4c3/Files/x/y/z")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

notebookutils.fs.mkdirs("abfss://12f495ce-6aee-4531-98b5-aad2886e82a5@onelake.dfs.fabric.microsoft.com/35333e4a-85d9-4ce1-9d53-0c832c036b85/Files/x/y/z")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

notebookutils.fs.help("cp")

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

# CELL ********************

sourceFilePath="abfss://12f495ce-6aee-4531-98b5-aad2886e82a5@onelake.dfs.fabric.microsoft.com/c8964cc6-2403-4b70-83c5-e4b65f7da4c3/Files/data/emp.csv"
targetFilePath="abfss://12f495ce-6aee-4531-98b5-aad2886
e82a5@onelake.dfs.fabric.microsoft.com/c8964cc6-2403-4b70-83c5-e4b65f7da4c3/Files/x/y/z"
notebookutils.fs.cp(sourceFilePath,targetFilePath)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

sourceFilePath="abfss://12f495ce-6aee-4531-98b5-aad2886e82a5@onelake.dfs.fabric.microsoft.com/c8964cc6-2403-4b70-83c5-e4b65f7da4c3/Files/data/emp.csv"
targetFilePath="abfss://ce7f6858-bbb8-4887-ba28-41d5d4654b8b@onelake.dfs.fabric.microsoft.com/e7bf30d6-1e0c-48d1-b396-aaca203aeda6/Files"
notebookutils.fs.cp(sourceFilePath,targetFilePath)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# # notebook:Utility for notebook operations (e.g, chaining Fabric notebooks together)

# CELL ********************

notebookutils.notebook.help()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

notebookutils.notebook.help("run")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

pathOfNotebook="https://app.powerbi.com/groups/12f495ce-6aee-4531-98b5-aad2886e82a5/synapsenotebooks/cab67a0b-61f4-4253-9f6c-78526f3a3903"
notebookutils.notebook.run("Notebook_2")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

result = notebookutils.notebook.run(
    path="Notebook_1",
    #timeoutSeconds=300,
    arguments={"param1": "Ram"},
    workspace="ram-test"
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
