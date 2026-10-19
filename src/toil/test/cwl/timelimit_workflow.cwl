cwlVersion: v1.2
$graph:
- class: Workflow
  id: main
  inputs:
    duration:
      type: int
    timeLimit:
      type: int
  outputs: []
  steps:
    node_sleep:
      in:
        duration: duration
        timeLimit: timeLimit
      run: '#sleep-cl'
      out: []
- class: CommandLineTool
  id: sleep-cl
  hints:
    DockerRequirement:
      dockerPull: ubuntu:latest
  requirements:
    InlineJavascriptRequirement: {}
    ToolTimeLimit:
      timelimit: $(inputs.timeLimit)
  baseCommand: sleep
  inputs:
    duration:
      type: int
      inputBinding:
        position: 1
    timeLimit:
      type: int
  outputs: []
