# Create a materialized view

1. create a materialized view that shows the most recent number of bikes at each bike station
```kusto
.create-or-alter materialized-view with (folder="Gold") AggregatedData on table TransformedData
{
   TransformedData
   | summarize arg_max(Timestamp, No_Bikes) by BikepointID
}

```

![image](https://github.com/user-attachments/assets/7109bda1-6a3d-4a5d-a9f0-aca4323279b2)

2. see the data in the materialized view visualized as a column chart

```kusto
AggregatedData
| sort by BikepointID
| render barchart  with (ycolumns=No_Bikes,xcolumn=BikenpointID)

```
![image](https://github.com/user-attachments/assets/27aac5ae-c803-4920-a968-e17e6bc8018b)

3. 
