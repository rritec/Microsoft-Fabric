// Step 1: Parent → Child mapping
let ParentChildMap =
ADFActivityRun
| where ActivityType == "ExecutePipeline" 
| project ParentPipelineName = PipelineName,
          ChildPipelineRunId = tostring(
              coalesce(
                  parse_json(Output).pipelineRunId,
                  parse_json(Output).runId,
                  parse_json(Output).invokedPipelineRunId
              )
          )
| join kind=leftouter (
    ADFPipelineRun
    | project ChildPipelineName = PipelineName, RunId
) on $left.ChildPipelineRunId == $right.RunId
| distinct ParentPipelineName, ChildPipelineName;

// Step 2: All pipelines (inventory)
let AllPipelines =
ADFPipelineRun
| distinct PipelineName;


// Step 3: One row per pipeline (even if no child / no parent)
AllPipelines
| join kind=leftouter ParentChildMap
    on $left.PipelineName == $right.ParentPipelineName
| distinct  PipelineName,
          ParentPipeline = ParentPipelineName,
          ChildPipeline = ChildPipelineName
//| order by PipelineName asc



