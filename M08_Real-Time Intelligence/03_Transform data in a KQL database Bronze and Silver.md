# Transform data in a KQL database

## Introduction
Learn how to use an **update policy** to transform data in a KQL Database within Real-Time Intelligence. Update policies automate data transformation when new data is written to a table.

## Move Raw Data Table to a Bronze Folder
1. Browse to the KQL database `rritec_Eventhouse`.
2. Under the KQL database name, select the KQL Queryset `rritec_Eventhouse`.
3. Observe data
```kusto
// Use "take" to view a sample number of records in the table and check the data.
RawData
| take 100

// See how many records are in the table.
RawData
| count

// This query returns the number of ingestions per minute in the given table.
RawData
| summarize IngestionCount = count() by bin(ingestion_time(), 1m)
```
4. Run the following command to move the table into a Bronze folder:

```kusto
.alter table RawData (BikepointID:string, Street:string, Neighbourhood:string, Latitude:dynamic, Longitude:dynamic, No_Bikes:long, No_Empty_Docks:long, Timestamp:datetime) with (folder="Bronze")
```

## Create Target Table
1. Create a new table `TransformedData`:

```kusto
.create table TransformedData (BikepointID:int, Street:string, Neighbourhood:string, Latitude:dynamic, Longitude:dynamic, No_Bikes:long, No_Empty_Docks:long, Timestamp:datetime, BikesToBeFilled:long, Action:string) with (folder="Silver")
```

2. Run the command to create the table.

## Create Function with Transformation Logic
 1. Copy/paste the following function:

```kusto
.create-or-alter function TransformRawData() {
    RawData
    | parse BikepointID with * "BikePoints_" BikepointID:int
    | extend BikesToBeFilled = No_Empty_Docks - No_Bikes
    | extend Action = iff(BikesToBeFilled > 0, tostring(BikesToBeFilled), "NA")
}
```

2. Run the command to create the function `TransformRawData`.

## Apply Update Policy

```kusto
.alter table TransformedData policy update
```[{
    "IsEnabled": true,
    "Source": "RawData",
    "Query": "TransformRawData()",
    "IsTransactional": false,
    "PropagateIngestionProperties": false
}]```
```

- Run the command to apply the policy.

## Verify Transformation
1. To view records from the source table:

```kusto
RawData
| take 10
```

2. To view records from the target table:

```kusto
TransformedData
| take 10
```

Notice that the `BikepointID` column no longer contains the prefix "BikePoints_" in the target table.

3. Observe data of London Bridge
```kusto
TransformedData
| where Neighbourhood == "London Bridge"
| project Timestamp, No_Bikes
```

4. Observe data of London Bridge in timechart graph
```kusto
TransformedData
| where Neighbourhood == "London Bridge"
| project Timestamp, No_Bikes
| render timechart
```
---

## Related Content
- [Update policy](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/management/updatepolicy)
- [Parse operator](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/parseoperator)
- [Stored functions](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/functions/user-defined-functions)
- [.create function command](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/management/functions)

# Reference
https://learn.microsoft.com/en-us/fabric/real-time-intelligence/tutorial-3-transform-kql-database
