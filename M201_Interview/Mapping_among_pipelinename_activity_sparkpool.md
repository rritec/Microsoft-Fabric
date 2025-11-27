``` kql
// --------------------------------------------------
// Optimized KQL: Big Data Pool Applications + Pipeline Activity Runs
// Goal: Join Synapse Big Data Pool applications with pipeline activity runs
//       for a specific workspace and calculate application durations.
// --------------------------------------------------

// Step 1: Big Data Pool Applications (Ended)
let bdp = 
SynapseBigDataPoolApplicationsEnded
| extend props = todynamic(Properties)  // Convert Properties JSON to dynamic
| project
    BDP_TimeGenerated = TimeGenerated,          // When the record was generated
    BDP_ResourceId = _ResourceId,              // Full resource ID of the BDP
    livyId = tostring(props.livyId),           // Livy session ID
    applicationId = tostring(props.applicationId),
    applicationName = tostring(props.applicationName),
    livyState = tostring(props.livyState),
    schedulerState = tostring(props.schedulerState),
    pluginState = tostring(props.pluginState),
    BDP_SubmitTime = todatetime(props.submitTime),
    BDP_StartTime = todatetime(props.startTime),
    BDP_EndTime = todatetime(props.endTime),
    incomingCorrelationId = tostring(props.incomingCorrelationId), // To join with pipeline runs
    submitterId = tostring(props.submitterId),
    // Extract Spark Pool / Cluster name from applicationName
    SparkPoolName = extract(@"_([^_]+)_\d+$", 1, tostring(props.applicationName))
;

// Step 2: Activity Runs (ADF / Synapse Pipelines)
let act = 
SynapseIntegrationActivityRuns
| where extract(@"workspaces/([^/]+)$", 1, _ResourceId) == "syn-gdcde-azure-prod"  // Filter workspace early
| project
    Activity_TimeGenerated = TimeGenerated,
    PipelineName,
    ActivityName,
    ActivityRunId,
    PipelineRunId,
    CorrelationId,
    Activity_ResourceId = _ResourceId,
    WorkspaceName = extract(@"workspaces/([^/]+)$", 1, _ResourceId)
;

// Step 3: Join Activity Runs with Big Data Pool Applications
act
| join kind=inner (
    bdp
) on $left.CorrelationId == $right.incomingCorrelationId
| project    
    PipelineRunId,
    WorkspaceName,
    PipelineName,
    ActivityName,
    ActivityRunId,
    livyId,
    applicationId,
    applicationName,
    BDP_StartTime,
    BDP_EndTime,
    // Calculate application duration in minutes
    BDP_Duration_Minutes = datetime_diff("minute", BDP_EndTime, BDP_StartTime),
    Activity_ResourceId,
    BDP_ResourceId,
    SparkPoolName
| order by BDP_Duration_Minutes desc, BDP_StartTime desc   // Sort by longest duration first, then latest start time




```
