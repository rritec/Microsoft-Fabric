[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared EMP = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "EMP"]}[Data]
in
  #"Navigation 2";
shared DEPT = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "DEPT"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "EMP 2026_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"EMP 10- 2026" = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "EMP"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each ([DEPTNO] = 10))
in
  #"Filtered rows";
shared #"EMP 2026_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "ecb89715-4f3a-402f-a899-81f8c9b06928"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "EMP 2026", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "EMP 20-2026_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"EMP 20-2026" = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "EMP"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each ([DEPTNO] = 20))
in
  #"Filtered rows";
shared #"EMP 20-2026_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "ecb89715-4f3a-402f-a899-81f8c9b06928"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "EMP 20-2026", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "EMP 30-2026_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"EMP 30-2026" = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "EMP"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each ([DEPTNO] = 30))
in
  #"Filtered rows";
shared #"EMP 30-2026_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "ecb89715-4f3a-402f-a899-81f8c9b06928"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "EMP 30-2026", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "EMP-50-2026_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"EMP-50-2026" = let
  Source = FabricSql.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "EMP"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each ([DEPTNO] = 50))
in
  #"Filtered rows";
shared #"EMP-50-2026_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "ecb89715-4f3a-402f-a899-81f8c9b06928"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "EMP-50-2026", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
