#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool
baseCommand: [python3, /app/sentiment.py]
arguments: [-o, $(inputs.transcript.nameroot)_sentiment.csv]
requirements:
  NetworkAccess:
    networkAccess: true  # required for nltk.download()
  DockerRequirement:
    dockerImageId: erd-etl
    dockerLoad: scripts/erd-etl.tar
inputs:
  transcript:
    type: File
    inputBinding:
      position: 1
      prefix: -i
  language:
    type:
      type: enum
      symbols: ["en", "nl"]
    inputBinding:
      position: 2
      prefix: -l
outputs:
  csv_out:
    type: File
    outputBinding:
      glob: ./$(inputs.transcript.nameroot)_sentiment.csv
