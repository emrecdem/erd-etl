#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool
baseCommand: [python3, /app/merge_features.py]
arguments: [-o, output.csv]
requirements:
  NetworkAccess:
    networkAccess: true
  EnvVarRequirement:
    envDef:
      DB_CONNECTION: postgresql://postgres:postgrespassword@172.26.0.10:5432/postgres
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
  sentiment_features:
    type: File
    inputBinding:
      position: 5
      prefix: -sm
  video_file:
    type: File
    inputBinding:
      position: 6
      prefix: -vi
  jobid:
    type: string
    inputBinding:
      position: 7
      prefix: -jid
outputs:
  csv_out:
    type: File
    outputBinding:
      glob: ./output.csv
