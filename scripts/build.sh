#!/bin/bash

docker build . -t erd-etl
docker save erd-etl > ../erd-etl.tar
