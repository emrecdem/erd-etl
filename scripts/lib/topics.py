import codecs

def get_topics_from_txt(topics_path):
    topics = []
    # TODO: automatically determine encoding...
    with codecs.open(topics_path, 'r', encoding='cp1252') as file:
        for line in file:
            if not line.lower().startswith('timestamp'):
                continue
            
            # Extract start and end time, topic index and description
            line = line.strip()
            split = line.split(' ')
            start_time = parseTimeToSeconds(split[-2])
            end_time = parseTimeToSeconds(split[-1])
            topic_index = int(split[1].replace('.', ''))
            topic_label = ' '.join(split[2:-2])
            topics.append((start_time, end_time, topic_index, topic_label))
    return topics

def parseTimeToSeconds(s):
    split = s.split(':')
    minutes = int(split[0])
    seconds = float(split[1])
    total_seconds = 60 * minutes + seconds
    return total_seconds

def extract_fragment(time_series, start_time, end_time):
    """
    Extracts the frames within the specified time interval
    """
    filter_timerange = (time_series['timestamp'] >= start_time) & (time_series['timestamp'] < end_time)
    fragment = time_series[filter_timerange]
    fragment.reset_index(drop=True, inplace=True)
    return fragment
