# This Dockerfile is based on 'miykael/nipype_env', for more information see:
# https://hub.docker.com/r/miykael/nipype_env/

FROM miykael/nipype_env
MAINTAINER Michael Notter <michaelnotter@hotmail.com>

# Change to main user and specify home folder
USER main
WORKDIR /home/main

ENV SHELL /bin/bash
