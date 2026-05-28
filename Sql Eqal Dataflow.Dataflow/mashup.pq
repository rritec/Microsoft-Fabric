[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DEPT = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "DEPT"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "EMP_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared EMP = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "EMP"]}[Data],
  #"Removed other columns" = Table.SelectColumns(#"Navigation 2", {"SAL", "DEPTNO"}),
  #"Filtered rows" = Table.SelectRows(#"Removed other columns", each ([DEPTNO] = 10 or [DEPTNO] = 20)),
  #"Merged queries" = Table.NestedJoin(#"Filtered rows", {"DEPTNO"}, DEPT, {"DEPTNO"}, "DEPT", JoinKind.Inner),
  #"Expanded DEPT" = Table.ExpandTableColumn(#"Merged queries", "DEPT", {"DNAME"}, {"DNAME"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded DEPT", {"DEPTNO"}),
  #"Grouped rows" = Table.Group(#"Removed columns", {"DNAME"}, {{"Totalsal", each List.Sum([SAL]), type nullable number}}),
  #"Sorted rows" = Table.Sort(#"Grouped rows", {{"Totalsal", Order.Ascending}})
in
  #"Sorted rows";
shared EMP_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[lakehouseName = "DM_lakehouse"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "EMP2026", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
