import argparse
import pandas as pd
import magic
import textgrid

import lib.topics as tp
from erd_database import ERD_Database


def merge_features():

    openface_file, topics_file, silences_file, praat_file, sentiment_file, \
        video_file, job_id, output_file = parse_arguments()

    # Load openface features
    time_series = pd.read_csv(openface_file, skipinitialspace=True)

    # Load & merge audio features
    audio_df = pd.read_csv(praat_file, delimiter=';')
    merge_audio(audio_df, time_series)

    # Load & merge topics
    topics_list = tp.get_topics_from_txt(topics_file)
    topics_df = pd.DataFrame(topics_list, columns=['start_time', 'end_time', 'index', 'description'])
    merge_topics(topics_list, time_series)

    # Load and merge silences
    load_silences(silences_file, time_series)

    # Load and merge sentiment
    sentiment_df = pd.read_csv(sentiment_file)
    merge_sentiment(sentiment_df, time_series)

    # Prepare to load to database
    erd_database = ERD_Database()

    # Create new video entry, reference from other tables and load to database
    video_id = erd_database.insert_video(openface_file, video_file, job_id)

    topics_df['video'] = video_id
    topics_df.to_sql('topics', erd_database.engine, index=False, if_exists='append')

    time_series['video'] = video_id
    time_series.to_sql('data', erd_database.engine, index=False, if_exists='append')

    time_series.to_csv(output_file, index=False)


def merge_audio(audio_df, time_series):

    def getValueFromAudio(timestamp, column):
        matches = audio_df.loc[audio_df['time'] >= timestamp, column]
        if (matches.size == 0):
            return None
        else:
            return matches.iat[0]
    time_series['pitch'] = time_series.apply(lambda row: getValueFromAudio(row.timestamp, 'pitch'), axis=1)
    time_series['intensity'] = time_series.apply(lambda row: getValueFromAudio(row.timestamp, 'intensity'), axis=1)


def merge_topics(topic_list, time_series):
    # Add column to time series for topic
    time_series['topic'] = -1
    for (start_time, end_time, topic_index, topic_label) in topic_list:
        topic_range_filter = (time_series['timestamp'] >= start_time) & (time_series['timestamp'] < end_time)
        time_series.loc[topic_range_filter, 'topic'] = topic_index


def merge_sentiment(sentiment_df, time_series):
    time_series['sentiment_polarity'] = None
    time_series['sentiment_subjectivity'] = None
    for index, row in sentiment_df.iterrows():
        range_filter = (time_series['timestamp'] >= row['start']) & (time_series['timestamp'] < row['stop'])
        time_series.loc[range_filter, 'sentiment_polarity'] = row['sentiment_polarity']
        time_series.loc[range_filter, 'sentiment_subjectivity'] = row['sentiment_subjectivity']


def load_silences(silences_file, time_series):

    # Load file
    blob = open(silences_file, 'rb').read()
    m = magic.Magic(mime_encoding=True)
    encoding = m.from_buffer(blob)
    silences_tgrid = textgrid.read_textgrid(silences_file, encoding)
    silences = pd.DataFrame(silences_tgrid)
    
    # Add column
    def isSilent(timestamp):
        filt = (silences['start'] <= timestamp) & (timestamp < silences['stop'])
        silence = silences.loc[filt, 'name']
        if len(silence) > 0:
            return silence.iat[0] == 'silent'
        return True
    time_series['silence'] = time_series.apply(lambda row: isSilent(row.timestamp), axis=1)
    #TODO maybe filtering the dataframe on each start-stop and applying silent/sounding in one go might be faster?


def parse_arguments():
    parser = argparse.ArgumentParser( # See https://docs.python.org/3.7/library/argparse.html
                description='Merge raw video features',
                usage='python merge_features.py')
    parser.add_argument('-of', type=str, help='Openface output')
    parser.add_argument('-tp', type=str, help='Topics file')
    parser.add_argument('-sl', type=str, help='Silences TextGrid')
    parser.add_argument('-pr', type=str, help='Transcript TextGrid') # praat file
    parser.add_argument('-sm', type=str, help='Sentiment csv')
    parser.add_argument('-vi', type=argparse.FileType('rb'), help='Video file')
    parser.add_argument('-jid', type=str, help='Job id')
    parser.add_argument('-o', type=str, help='Merged output as csv file')
    args = parser.parse_args()
    return args.of, args.tp, args.sl, args.pr, args.sm, args.vi, args.jid, args.o

if __name__ == "__main__":
    merge_features()
