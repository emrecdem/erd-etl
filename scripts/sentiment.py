#!/usr/bin/python3
from pattern.nl import singularize, sentiment
from nltk import sent_tokenize
import pandas as pd
import argparse
import magic
import textgrid

import nltk
nltk.download('punkt')

def analyze_sentiment():
    
    input_file, output_file = parse_arguments()

    # Load file
    blob = open(input_file, 'rb').read()
    m = magic.Magic(mime_encoding=True)
    encoding = m.from_buffer(blob)
    tgrid = textgrid.read_textgrid(input_file, encoding)
    df = pd.DataFrame(tgrid)

    # Filter for Transcripts, remove empty
    df = df[df['tier'] == 'Transcript']
    df = df[df['name'] != '']

    # Calculate sentiment
    # TODO: figure out how to unpack tuples to multiple columns:
    df['sentiment_polarity'] = df.apply(lambda row: sentiment(row['name'])[0], axis=1)
    df['sentiment_subjectivity'] = df.apply(lambda row: sentiment(row['name'])[1], axis=1)

    # Save final result
    print(df.head())
    df.to_csv(output_file, index=False)

def parse_arguments():
    parser = argparse.ArgumentParser( # See https://docs.python.org/3.7/library/argparse.html
                description='Analyze sentiment',
                usage='python sentiment.py '+\
                    '[-i <input.TextGrid>] '+\
                    '[-o <output.csv>] ')

    parser.add_argument('-i', type=str)
    parser.add_argument('-o', type=str)    
    args = parser.parse_args()
    return args.i, args.o

if __name__ == "__main__":
    analyze_sentiment()
