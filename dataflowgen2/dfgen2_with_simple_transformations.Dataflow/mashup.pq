[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "emp_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared emp = let
  Source = Csv.Document(Web.Contents("https://raw.githubusercontent.com/rritec/Microsoft-Fabric/refs/heads/main/Labdata/emp.csv"), [Delimiter = ",", Columns = 8, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"empno", Int64.Type}, {"ename", type text}, {"job", type text}, {"mgr", Int64.Type}, {"hiredate", type date}, {"sal", Int64.Type}, {"comm", Int64.Type}, {"deptno", Int64.Type}}),
  #"Removed bottom rows" = Table.RemoveLastN(#"Changed column type", 1),
  #"Replaced value" = Table.ReplaceValue(#"Removed bottom rows", null, 0, Replacer.ReplaceValue, {"comm"}),
  #"Inserted Addition" = Table.AddColumn(#"Replaced value", "TotalSal", each [sal] + [comm], type number)
in
  #"Inserted Addition";
shared emp_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "12f495ce-6aee-4531-98b5-aad2886e82a5"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "c8964cc6-2403-4b70-83c5-e4b65f7da4c3"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "emp", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
