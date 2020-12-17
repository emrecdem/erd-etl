#!/usr/bin/env cwl-runner


cwlVersion: v1.2
class: CommandLineTool
baseCommand: [/home/openface-build/build/bin/FeatureExtraction, -of, video.csv]
hints:
  DockerRequirement:
    dockerImageId: openface
    dockerFile: >
        FROM algebr/openface:latest

        WORKDIR /home/openface-build

        RUN chmod +r /home/openface-build/build/bin/model/patch_experts/*.dat

        ENTRYPOINT []
        CMD /bin/bash
inputs:
  video:
    type: File
    inputBinding:
      position: 1
      prefix: -f
outputs:
  csv_out:
    type: File
    outputBinding:
      glob: ./processed/video.csv