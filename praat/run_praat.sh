#!/bin/sh

cp /app/extract-stuff-perframe-DN.praat $HOME

audio=$(basename $1)
transcription=$(basename $2)
silences=$(basename $3)
gender=$4

cd $HOME && /usr/bin/praat_barren --no-pref-files --run extract-stuff-perframe-DN.praat $1 $2 $3 $4