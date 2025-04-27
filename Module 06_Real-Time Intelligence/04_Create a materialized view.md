# Create a materialized view

1. create a materialized view that shows the most recent number of bikes at each bike station
```kusto
.create-or-alter materialized-view with (folder="Gold") AggregatedData on table TransformedData
{
   TransformedData
   | summarize arg_max(Timestamp, No_Bikes) by BikepointID
}

```
2. see the data in the materialized view visualized as a column chart

```kusto
AggregatedData
| sort by BikepointID
| render columnchart with (ycolumns=No_Bikes,xcolumn=BikepointID)

```

3. 
