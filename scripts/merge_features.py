import argparse
import pandas as pd
import magic
import textgrid

import lib.topics as tp

def merge_features():

    openface_file, topics_file, silences_file, output_file = parse_arguments()
    
    # Load openface features
    time_series = pd.read_csv(openface_file, skipinitialspace=True)

    # Add columns for topics, silences
    load_topics(topics_file, time_series)
    load_silences(silences_file, time_series)

    time_series.to_csv(output_file, index=False)


def load_topics(topics_file, time_series):

    # Load file
    topic_list = tp.get_topics_from_txt(topics_file)

    # Add column
    time_series['topic'] = -1
    for (start_time, end_time, topic_index, topic_label) in topic_list:
        topic_range_filter = (time_series['timestamp'] >= start_time) & (time_series['timestamp'] < end_time)
        time_series.loc[topic_range_filter, 'topic'] = topic_index


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
        return silences.loc[filt, 'name'].iat[0] == 'silent'
    time_series['silence'] = time_series.apply(lambda row: isSilent(row.timestamp), axis=1)
    #TODO maybe filtering the dataframe on each start-stop and applying silent/sounding in one go might be faster?


def parse_arguments():

    parser = argparse.ArgumentParser( # See https://docs.python.org/3.7/library/argparse.html
                description='Merge raw video features',
                usage='python merge_features.py '+\
                    '[-i <input.csv>] '+\
                    '[-o <output.csv>] ')

    parser.add_argument( 
            '-of',
            #nargs=1, # expects one argument after -i
            required=True,
            #const=DEFAULT_IN, # default if -i is provided but no file specified
            #default=DEFAULT_IN, # default if -i is not provided
            help='Input csv',
            type=str #FileType('r', encoding="utf-8") # expect a filename
            )

    parser.add_argument('-tp', type=str)
    parser.add_argument('-sl', type=str)
    
    parser.add_argument( 
            '-o',
            # nargs='?', # expects one argument after -o
            # const=DEFAULT_OUT, # default if -o is provided but no file specified
            # default=DEFAULT_OUT, # default if -o is not provided
            help='Merged output as csv file',
            type=str #argparse.FileType('w', encoding="utf-8") # expect a filename
            )
    
    args = parser.parse_args()
    return args.of, args.tp, args.sl, args.o

if __name__ == "__main__":
    merge_features()
