[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared emp = let
  Source = Csv.Document(Web.Contents("https://mylaramreddy-my.sharepoint.com/personal/deepthi_mylaramreddy_onmicrosoft_com/Documents/Apps/Microsoft Power Query/Uploaded Files/emp.csv"), [Delimiter = ",", Columns = 8, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"empno", Int64.Type}, {"ename", type text}, {"job", type text}, {"mgr", Int64.Type}, {"hiredate", type date}, {"sal", Int64.Type}, {"comm", Int64.Type}, {"deptno", Int64.Type}}),
  #"Filtered rows" = Table.SelectRows(#"Changed column type", each ([comm] = null)),
  #"Replaced value" = Table.ReplaceValue(#"Filtered rows", null, 0, Replacer.ReplaceValue, {"comm"}),
  #"Removed bottom rows" = Table.RemoveLastN(#"Replaced value", 1),
  #"Replaced value 1" = Table.ReplaceValue(#"Removed bottom rows", null, 0, Replacer.ReplaceValue, {"mgr"})
in
  #"Replaced value 1";
