[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"EMP 20-2026" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "ecb89715-4f3a-402f-a899-81f8c9b06928"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "EMP 20-2026", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared #"EMP 30-2026" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "ecb89715-4f3a-402f-a899-81f8c9b06928"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "EMP 30-2026", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "EMP20-EMP30_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"EMP20-EMP30" = let
  Source = Table.Combine({#"EMP 20-2026", #"EMP 30-2026"}),
  #"Removed duplicates" = Table.Distinct(Source, {"EMPNO"})
in
  #"Removed duplicates";
shared #"EMP20-EMP30_DataDestination" = let
  Pattern = FabricSql.Contents([CreateNavigationProperties = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  Navigation_2 = Navigation_1{[sqlId = "a9040a7d-dee0-480e-94b3-e08341218f91"]}[Data],
  Navigation_3 = Navigation_2{[Schema = "dbo"]}[Data],
  TableNavigation = Navigation_3{[Name = "EMP20-EMP30"]}?[Data]?
in
  TableNavigation;
