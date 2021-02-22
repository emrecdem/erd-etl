#!/bin/bash

cwltool workflow_single.cwl \
  --video data/$1.mp4 \
  --audio data/$1.wav \
  --transcription data/DUMMY_talkspurt.TextGrid \
  --silences data/DUMMY_SIL.TextGrid \
  --topics data/DUMMY_topics.txt \
  --gender $2
