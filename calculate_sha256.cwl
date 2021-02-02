#!/usr/bin/env cwl-runner


cwlVersion: v1.2
class: CommandLineTool
baseCommand: [python, calculate_sha256.py]
hints:
    InitialWorkDirRequirement:
        listing:
          - class: File
            location: "scripts/calculate_sha256.py"

inputs:
  video:
    type: File
    inputBinding:
      position: 1

stdout: cwl.output.json
outputs:
    sha256:
        type: string