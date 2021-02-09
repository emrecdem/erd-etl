#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool
baseCommand: [python3, /app/merge_features.py]
arguments: [-o, $(inputs.openface_features.nameroot).csv]
requirements:
  NetworkAccess:
    networkAccess: true
  EnvVarRequirement:
    envDef:
      DB_CONNECTION: postgresql://postgres:postgrespassword@host.docker.internal:5446/postgres
  DockerRequirement:
    dockerImageId: erd-etl
    dockerLoad: scripts/erd-etl.tar
inputs:
  openface_features:
    type: File
    inputBinding:
      position: 1
      prefix: -of
  topics:
    type: File
    inputBinding:
      position: 2
      prefix: -tp
  silences:
    type: File
    inputBinding:
      position: 3
      prefix: -sl
  praat_features:
    type: File
    inputBinding:
      position: 4
      prefix: -pr
outputs:
  csv_out:
    type: File
    outputBinding:
      glob: ./$(inputs.openface_features.nameroot).csv
