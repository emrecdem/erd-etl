import os
import re
import hashlib

from sqlalchemy import (Column, Float, Integer, MetaData, String, Table,
                        create_engine)


class ERD_Database:
    def __init__(self):
        self.engine = create_engine(os.environ['DB_CONNECTION'])
        self.create_tables()

    def create_tables(self):
        self.metadata = metadata = MetaData()

        self.videos = Table('videos', metadata,
                            Column('id', Integer, primary_key=True),
                            Column('hash', String, unique=True),
                            Column('study', String),
                            Column('participant', Integer),
                            Column('session', Integer),
                            Column('experiment', String),
                            Column('memory_type', String),
                            Column('memory_index', Integer),
                            Column('job_id', String))

        self.topics = Table('topics', metadata,
                            Column('video', Integer, primary_key=True),
                            Column('index', Integer, primary_key=True),
                            Column('start_time', Float),
                            Column('end_time', Float),
                            Column('description', String))

        metadata.create_all(self.engine)

    def insert_video(self, filename, video_file, job_id):
        participant = ""
        session = ""
        experiment = ""
        memory_type = ""
        memory_index = ""

        # Get meta data from filename
        try:
            r = r"P([0-9]+)_S([0-9]+)_([a-zA-Z]+)_([a-zA-Z]+)([0-9]+)([^\/]+)$"
            matches = re.findall(r, filename)
            participant, session, experiment, memory_type, memory_index, _ = matches[0]
        except:
            pass

        # Calculate hash
        chunkSize = 1 * 1024 * 1024  # 1 MB
        m = hashlib.sha256()
        m.update(video_file.read(chunkSize))
        sha256 = m.hexdigest()

        # Insert video
        ins = self.videos.insert().values(study="ERD", participant=participant, \
            session=session, experiment=experiment, memory_type=memory_type, \
            memory_index=memory_index, hash=sha256, job_id=job_id)
        conn = self.engine.connect()
        result = conn.execute(ins)
        return result.inserted_primary_key[0]
