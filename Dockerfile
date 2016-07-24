# This Dockerfile is based on 'miykael/nipype_env', for more information see:
# https://hub.docker.com/r/miykael/nipype_env/

FROM miykael/nipype_env
MAINTAINER Michael Notter <michaelnotter@hotmail.com>

# Switch to root user
USER root

# Create main user and home folder
#RUN useradd -ms /bin/bash main
USER main
WORKDIR /home/main

#RUN find $HOME/notebooks -name '*.ipynb' -exec ipython trust {} \;

ENV SHELL /bin/bash
