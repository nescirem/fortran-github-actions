FROM debian:9.5-slim

MAINTAINER nescirem <nescirem@gmail.com>
LABEL description="github actions for fortran projects"

RUN apt update && apt install -y \
    build-essential gfortran makedepf90 \
    python3-pip python3-venv python-dev && \
    rm -rf /var/lib/apt/lists/*
RUN pip3 --no-cache-dir install ford FoBiS.py pygooglechart sh

COPY ../* /
ENTRYPOINT ["python3 ./test_all.py"]
