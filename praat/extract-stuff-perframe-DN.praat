## start procedure De Jong for syllable detection ##

procedure countSyll
 
# shorten variables
#iglevel = 'ignorance_Level/Intensity_Median'
#mindip = 'minimum_dip_between_peaks'

iglevel = 0
mindip = 2

obj$ = selected$("Sound")
soundid = selected("Sound")
originaldur = Get total duration

Subtract mean

# Use intensity to get threshold
To Intensity... 50 0 yes

intid = selected("Intensity")

start = Get time from frame number... 1

nframes = Get number of frames
end = Get time from frame number... 'nframes'

# estimate noise floor
minint = Get minimum... 0 0 Parabolic

# estimate noise max
maxint = Get maximum... 0 0 Parabolic

#get median of Intensity: limits influence of high peaks
medint = Get quantile... 0 0 0.5

# estimate Intensity threshold
threshold = medint + iglevel
if threshold < minint
  threshold = minint
endif

Down to Matrix

matid = selected("Matrix")
# Convert intensity to sound
To Sound (slice)... 1

sndintid = selected("Sound")

intdur = Get finishing time
intmax = Get maximum... 0 0 Parabolic

# estimate peak positions (all peaks)
To PointProcess (extrema)... Left yes no Sinc70

ppid = selected("PointProcess")

numpeaks = Get number of points

# fill array with time points
for i from 1 to numpeaks
  t'i' = Get time from index... 'i'
endfor

# fill array with intensity values

select 'sndintid'

peakcount = 0
for i from 1 to numpeaks
  value = Get value at time... t'i' Cubic
  if value > threshold
    peakcount += 1
    int'peakcount' = value
    timepeaks'peakcount' = t'i'
  endif
endfor

# fill array with valid peaks: only intensity values if preceding 
# dip in intensity is greater than mindip

select 'intid'

validpeakcount = 0
precedingtime = timepeaks1
precedingint = int1
for p to peakcount-1
  following = p + 1
  followingtime = timepeaks'following'
  dip = Get minimum... 'precedingtime' 'followingtime' None
  diffint = abs(precedingint - dip)
  if diffint > mindip
    validpeakcount += 1
    validtime'validpeakcount' = timepeaks'p'
  endif
  precedingtime = timepeaks'following'
  precedingint = Get value at time... timepeaks'following' Cubic
endfor

# Look for only voiced parts

select 'soundid' 

To Pitch (ac)... 0.02 30 4 no 0.03 0.25 0.01 0.35 0.25 450
pitchid = selected("Pitch")

voicedcount = 0
for i from 1 to validpeakcount
  querytime = validtime'i'

  value = Get value at time... 'querytime' Hertz Linear

  if value <> undefined
    voicedcount = voicedcount + 1
    voicedpeak'voicedcount' = validtime'i'
  endif
endfor
   
# calculate time correction due to shift in time for Sound object versus
# intensity object
timecorrection = originaldur/intdur

# Insert voiced peaks in second Tier

select 'soundid' 

To TextGrid... "syllables" syllables
textgridid = selected("TextGrid")
for i from 1 to voicedcount
  position = voicedpeak'i' * timecorrection
  Insert point... 1 position 'i'
endfor

#select TextGrid 'textgridid'
n_syllables = Get number of points... 1
#printline 'n_syllables'
.result = n_syllables

# write textgrid to textfile
#Write to text file... 'directory$'/'obj$'.syllables.TextGrid
#Write to text file... /Users/khiet/work/deniece/test/'obj$'.syllables.TextGrid


# clean up before next sound file is opened

select 'intid'
plus 'matid'
plus 'ppid'
plus 'sndintid'
plus 'soundid'
plus 'textgridid'
plus 'pitchid'
Remove

endproc

## end procedure syllable detection by De Jong ##
 

## start script to extract features ##

 #praat bin/pitch-stuff-perfile.praat /Users/khiet/work/deniece/Sessie1_Sarah/P1_S1_16k.wav /Users/khiet/work/deniece/Sessie1_Sarah/P1_finished_new.TextGrid /Users/khiet/work/deniece/Sessie1_Sarah_sil_praat/P1_S1_16k.silpraat.TextGrid male
 # praat bin/extract-stuff-perfile.praat /Users/khiet/work/deniece/Sessie1_Sarah/P1_S1_16k.wav /Users/khiet/work/deniece/Sessie1_Sarah_lifeevents2/P1_Sil_Timestamps_merged.TextGrid /Users/khiet/work/deniece/Sessie1_Sarah_sil_praat2/P1.silpraat2.TextGrid

form Get arguments
  sentence Wavfile
  sentence Tgfile
  sentence Tgfilesil
  sentence Gender
endform

myobject$ = "dummy"
myobject_sil$ = "sil"
Read from file... 'wavfile$'
name_wavfile$ = selected$("Sound")
where = index(name_wavfile$,"_")
name_id$ = left$(name_wavfile$,where-1)
number_id$ = mid$(name_wavfile$,2,where-2)
Rename... 'myobject$'

Read from file... 'tgfilesil$'
Rename... 'myobject_sil$'

Read from file... 'tgfile$'
Rename... 'myobject$'

select TextGrid 'myobject$'
n_intervals = Get number of intervals... 1

step = 0.01
t = step
begin_low_band = 0
end_low_band = 2000
begin_high_band = 2000
end_high_band = 5000

if (gender$ = "male")
  pitch_range = 300
  number_gender = 0
else
  pitch_range = 600
  number_gender = 1
endif




## header
print speaker_id1;speaker_id2;gender;label;interval_number;starttime;endtime;dur_part;time;sounding;pitch;intensity'newline$'
#print speaker_id1;speaker_id2;gender;label;interval_number;starttime;endtime;dur_part;mean_pitch;sd_pitch;min_pitch;max_pitch;range_pitch;slope_pitch;
#print mean_intens;sd_intens;min_intens;max_intens;range_intens;
#print mean_intens_all;sd_intens_all;min_intens_all;max_intens_all;range_intens_all;
#print hammarberg;slope_ltas;cog;
#print n_syllables;ar;sr;
#print mean_dur_silent;mean_dur_talkspurt;ratio_dur_sil_talkspurt;talkspurt_rate;sil_rate
#print 'newline$'

for j from 1 to n_intervals
  select TextGrid 'myobject$'
  label$ = Get label of interval... 1 'j'
  where = startsWith(label$,"Timestamp")
  if (where==1)
    
    starttime = Get start time of interval... 1 'j'
    endtime = Get end time of interval... 1 'j'
    select Sound 'myobject$'
    Extract part... 'starttime' 'endtime' rectangular 1 yes
    dur_part = Get total duration
    end_part = Get end time
    t = Get start time
    To Pitch... 0.0 75 'pitch_range'
    select Sound 'myobject$'_part
    To Intensity... 100 0 yes
    
    while (t < end_part)
      select TextGrid 'myobject_sil$'
      t_interval = Get interval at time... 1 't'
      t_label$ = Get label of interval... 1 't_interval'
      if (t_label$ = "silent")
        sounding = 0
      else
        sounding = 1
      endif
      select Pitch 'myobject$'_part
      t_p = Get value at time... 't' Hertz Linear
      if (t_p = undefined)
        t_p = 0
      endif
      select Intensity 'myobject$'_part
      t_i = Get value at time... 't' Cubic
      if (t_i = undefined)
        t_i = 0
      endif
      print "'name_id$'";'number_id$';'number_gender';"'label$'";'j';'starttime:2';'endtime:2';'dur_part:2';'t:2';'sounding';'t_p:2';'t_i:2''newline$'
      t = t + 0.01
    endwhile
    
    #Extract part... 'starttime' 'endtime' no
    #select Sound 'myobject$'_part
    #plus TextGrid 'myobject_sil$'_part
    #Extract intervals where... 1 no "is equal to" sounding
    #Concatenate
    #dur_chain = Get total duration

    ## do stuff here

    ## pitch stuff
    # set 500 for female voices
    # set 300 for male voices
    #To Pitch... 0.0 75 'pitch_range'
    #mean_p = Get mean... 0 0 Hertz
    #sd_p = Get standard deviation... 0 0 Hertz
    # min = 5th percentile
    # max = 95th percentile
    #min_p = Get quantile... 0 0 0.05 Hertz
    #max_p = Get quantile... 0 0 0.95 Hertz
    #range_p = max_p - min_p
    #slope_p = Get mean absolute slope... Hertz

    #print "'name_id$'";'number_id$';'number_gender';"'label$'";'j';'starttime:2';'endtime:2';'dur_part:2';'mean_p:4';'sd_p:4';'min_p:4';'max_p:4';'range_p:4';'slope_p:4';

    ## intensity stuff over only speech part
    #select Sound chain
    #To Intensity... 100 0 yes
    #mean_intens = Get mean... 0 0 energy
    #sd_intens = Get standard deviation... 0 0
    # min = 5th percentile
    # max = 95th percentile
    #min_intens = Get quantile... 0 0 0.05
    #max_intens = Get quantile... 0 0 0.95
    #range_intens = max_intens - min_intens

    #print 'mean_intens:4';'sd_intens:4';'min_intens:4';'max_intens:4';'range_intens:4';

    ## intensity stuff over whole part
    #select Sound 'myobject$'_part
    #To Intensity... 100 0 yes
    #mean_intens_all = Get mean... 0 0 energy
    #sd_intens_all = Get standard deviation... 0 0
    # min = 5th percentile
    # max = 95th percentile
    #min_intens_all = Get quantile... 0 0 0.05
    #max_intens_all = Get quantile... 0 0 0.95
    #range_intens_all = max_intens_all - min_intens_all

    #print 'mean_intens_all:4';'sd_intens_all:4';'min_intens_all:4';'max_intens_all:4';'range_intens_all:4';

    ## voice quality stuff
    #select Sound chain
    #To Ltas... 100
    #max_low_band = Get maximum... 'begin_low_band' 'end_low_band' None
    #max_high_band = Get maximum... 'begin_high_band' 'end_high_band' None
    #hammarberg = max_low_band - max_high_band
    #slope_ltas = Get slope... 'begin_low_band' 'end_low_band' 'begin_high_band' 'end_high_band' energy

    #select Sound chain
    #To Spectrum... yes
    #cog = Get centre of gravity... 2

    #print 'hammarberg:4';'slope_ltas:4';'cog:4';

    #Save as WAV file... /Users/khiet/work/deniece/test/chain.syllables.wav
    ## count syllables
    #select Sound chain
    #@countSyll
    #ar = countSyll.result/dur_chain
    #sr = countSyll.result/dur_part
    #print 'countSyll.result';'ar:4';'sr:4';

    ## pause stuff
    #select TextGrid 'myobject_sil$'_part
    #tot_dur_silent = Get total duration of intervals where... 1 "is equal to" silent
    #tot_dur_talkspurt = Get total duration of intervals where... 1 "is equal to" sounding
    #n_silent = Count intervals where... 1 "is equal to" silent
    #n_talkspurt = Count intervals where... 1 "is equal to" sounding
    #if (n_silent > 0)
    #  mean_dur_silent = tot_dur_silent/n_silent
    #else
    #  mean_dur_silent = 0
    #endif
    #mean_dur_talkspurt = tot_dur_talkspurt/n_talkspurt
    #ratio_dur_sil_talkspurt = tot_dur_silent/tot_dur_talkspurt
    #talkspurt_rate = n_talkspurt/dur_part
    #sil_rate = n_silent/dur_part
  
    #print 'mean_dur_silent:4';'mean_dur_talkspurt:4';'ratio_dur_sil_talkspurt:4';'talkspurt_rate:4';'sil_rate:4'
    
    #print 'newline$'

    select Sound 'myobject$'_part
    #plus Pitch chain
   #plus Sound chain
    #plus Ltas chain
    #plus Intensity chain
    #plus Intensity 'myobject$'_part
    #plus Spectrum chain
    #plus TextGrid 'myobject_sil$'_part

    Remove

  endif


endfor
