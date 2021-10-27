#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow

inputs:
  xenonflow_jobid:
    type: string
  video:
    type: File
  audio:
    type: File
  transcription:
    type: File
  silences:
    type: File
  topics:
    type: File
  gender:
    type:
        type: enum
        symbols: ["vrouw", "man"]
outputs:
  csv_out:
    type: File
    outputSource: merge_features/csv_out

steps:
  praat:
    run: praat.cwl
    in:
      audio: audio
      transcription: transcription
      silences: silences
      gender: gender
    out: [csv_out]

  openface:
    run: openface.cwl
    in:
      video: video
    out: [csv_out]

  sentiment:
    run: sentiment.cwl
    in:
      transcript: transcription
    out: [csv_out]

  merge_features:
    run: merge_features.cwl
    in:
      openface_features: openface/csv_out
      topics: topics
      silences: silences
      praat_features: praat/csv_out
      sentiment_features: sentiment/csv_out
      video_file: video
      jobid: xenonflow_jobid
    out: [csv_out]
