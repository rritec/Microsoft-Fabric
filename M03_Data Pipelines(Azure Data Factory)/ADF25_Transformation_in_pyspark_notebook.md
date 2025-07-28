# ADF25_Transformation_in_pyspark_notebook

1. Create one notebook
2. write `tableName = "test"` in first cell and click on toggle parameter cell

<img width="1070" height="105" alt="image" src="https://github.com/user-attachments/assets/2d39e9d7-fafa-45cf-b1eb-10f8db9f954e" />

3. Write pysaprksql as shown below
   
```sql
df = spark.sql("SELECT empno,ename,sal,comm,sal+ifnull(comm,0) as totalsal FROM June18_Lakehouse.emp LIMIT 1000")
display(df)
```
4. write data to delta table

```sql
df.write.format("delta").mode("overwrite").save("Tables/"+tableName)
```

5. create data pipeline



6. add notebook activity
7. point out to above notebook and create one parameter


<img width="734" height="787" alt="image" src="https://github.com/user-attachments/assets/8151ecf6-f8a5-45ef-8673-bbc2be135723" />


8. run data pipeline
9. observe delta table in lakehouse
