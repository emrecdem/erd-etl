#!/usr/bin/env cwl-runner

# Runs Praat in a docker container
#
# Praat expects all files to be in the working directory
# The InitialWorkDirRequirement puts the inputs in the working directory
# the run_praat.sh script copies the praat script to the
# working dir and executes praat

# Building the docker image:
# from the praat directory
# docker build -t erd-praat .
#
# from the directory with the cwl file
# docker save erd-praat > erd-praat.tar

cwlVersion: v1.2
class: CommandLineTool
baseCommand: [/app/run_praat.sh]
requirements:
  DockerRequirement:
    dockerImageId: erd-praat
    dockerLoad: erd-praat.tar
  InitialWorkDirRequirement:
    listing:
        - $(inputs.audio)
        - $(inputs.transcription)
        - $(inputs.silences)
inputs:
  audio:
    type: File
    inputBinding:
      position: 1
  transcription:
    type: File
    inputBinding:
      position: 2
  silences:
    type: File
    inputBinding:
      position: 3
  gender:
    type:
        type: enum
        symbols: ["vrouw", "man"]
outputs:
  csv_out:
    type: stdout