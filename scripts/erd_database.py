from sqlalchemy import Table, Column, Integer, Float, String, MetaData, create_engine
import re

class ERD_Database:

    def __init__(self):
        self.engine = create_engine('postgresql://postgres:postgrespassword@127.0.0.1:5445/postgres')
        self.create_tables()

    def create_tables(self):
        self.metadata = metadata = MetaData()
        
        self.videos = Table('videos', metadata, 
            Column('id', Integer, primary_key=True),
            Column('study', String),
            Column('participant', Integer),
            Column('session', Integer),
            Column('experiment', String),
            Column('memory_type', String),
            Column('memory_index', Integer))

        self.topics = Table('topics', metadata,
            Column('video', Integer, primary_key=True),
            Column('index', Integer, primary_key=True),
            Column('start_time', Float),
            Column('end_time', Float),
            Column('description', String))

        metadata.create_all(self.engine)

    def insert_video(self, filename):
        # Get meta data from filename
        r = r"P([0-9]+)_S([0-9]+)_([a-zA-Z]+)_([a-zA-Z]+)([0-9]+)([^\/]+)$"
        matches = re.findall(r, filename)
        participant, session, experiment, memory_type, memory_index, _ = matches[0]

        # Insert video
        ins = self.videos.insert().values(study="ERD", participant=participant, \
            session=session, experiment=experiment, memory_type=memory_type, \
            memory_index=memory_index)
        conn = self.engine.connect()
        result = conn.execute(ins)
        return result.inserted_primary_key[0]
