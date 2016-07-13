# This Dockerfile is based on the dockerfiles 'crn_base' and 'crn_nipype' from
# the Poldrack Lab (https://github.com/poldracklab/crn_base),  the dockerfile
# biss2016-notebook from Oscar Esteban under https://hub.docker.com/u/oesteban
# and the dockerfiles from the vistalab (https://github.com/vistalab/docker).
# This means that the same copyrights apply to this Dockerfile, as they do
# for the files most of this content is coming from:
#
# Copyright (c) 2016, The developers of the Stanford CRN
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of crn_base nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM ubuntu:15.04
MAINTAINER Michael Notter <michaelnotter@hotmail.com>

# Switch to root user for installation
USER root

# Preparations
RUN ln -snf /bin/bash /bin/sh
ARG DEBIAN_FRONTEND=noninteractive

# Update packages and install the minimal set of tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl git xvfb bzip2 unzip tcsh \
                                               apt-utils \
                                               build-essential \
                                               gfortran \
                                               graphviz \
                                               liblapack-dev \
                                               libblas-dev \
                                               libatlas-dev \
                                               libatlas-base-dev \
                                               libblas3 \
                                               libblas-common \
                                               libopenblas-dev \
                                               libxml2-dev \
                                               libxslt1-dev \
                                               libfreetype6-dev \
                                               libpng12-dev \
                                               libqhull-dev \
                                               libxft-dev \
                                               libjpeg-dev \
                                               libyaml-dev

# Enable neurodebian
RUN curl -sSL http://neuro.debian.net/lists/vivid.de-md.full | tee /etc/apt/sources.list.d/neurodebian.sources.list && \
    curl -sSL http://neuro.debian.net/lists/vivid.us-tn.full >> /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key adv --recv-keys --keyserver hkp://pgp.mit.edu:80 0xA5D32F012649A5A9 && \
    apt-get update && \
    apt-get install -y fsl afni

# Set-up environment
RUN echo '#!/bin/bash' > /etc/profile.d/neuro_env.sh && \
    echo 'export FSLDIR=/usr/share/fsl' >> /etc/profile.d/neuro_env.sh && \
    echo 'export PATH=$FSLDIR/5.0/bin:$PATH' >> /etc/profile.d/neuro_env.sh && \
    echo 'source $FSLDIR/5.0/etc/fslconf/fsl.sh' >> /etc/profile.d/neuro_env.sh && \
    echo 'export PATH=/usr/lib/afni/bin:$PATH' >> /etc/profile.d/neuro_env.sh && \
    echo 'source /etc/profile.d/neuro_env.sh' >> /etc/bash.bashrc

# # Download and install FreeSurfer
# RUN wget ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/5.3.0/freesurfer-Linux-centos6_x86_64-stable-pub-v5.3.0.tar.gz && \
#     /bin/bash -c "tar -xvzf freesurfer-Linux-centos6_x86_64-stable-pub-v5.3.0.tar.gz \
#                       -C /usr/local \
#                       --exclude='freesurfer/average/mult-comp-cor' \
#                       --exclude='freesurfer/subjects/bert' \
#                       --exclude='freesurfer/subjects/cvs_avg35' \
#                       --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
#                       --exclude='freesurfer/subjects/fsaverage3' \
#                       --exclude='freesurfer/subjects/fsaverage4' \
#                       --exclude='freesurfer/subjects/fsaverage5' \
#                       --exclude='freesurfer/subjects/fsaverage6' \
#                       --exclude='freesurfer/subjects/fsaverage_sym' \
#                       --exclude='freesurfer/subjects/lh.EC_average' \
#                       --exclude='freesurfer/subjects/rh.EC_average' \
#                       --exclude='freesurfer/subjects/V1_average' \
#                       --exclude='freesurfer/trctrain' \
#                       --exclude='freesurfer/average/3T18yoSchwartzReactN32*' \
#                       --exclude='freesurfer/average/711-2*' \
#                       --exclude='freesurfer/average/RB_all_*'" && \
#     rm freesurfer-Linux-centos6_x86_64-stable-pub-v5.3.0.tar.gz && \
#     /bin/bash -c 'echo "michaelnotter@hotmail.com\n14685\n *C4oZU2irTfPc" > /usr/local/freesurfer/.license'
# 
# # Set-up FreeSurfer environment
# RUN echo '#!/bin/bash' > /etc/profile.d/freesurfer_env.sh && \
#     echo 'export FREESURFER_HOME=/usr/local/freesurfer' >> /etc/profile.d/freesurfer_env.sh && \
#     echo 'export SUBJECTS_DIR=/usr/local/freesurfer/subjects' >> /etc/profile.d/freesurfer_env.sh && \
#     echo 'export MNI_DIR=/usr/local/freesurfer/mni' >> /etc/profile.d/freesurfer_env.sh && \
#     echo 'export FSF_OUTPUT_FORMAT=nii.gz' >> /etc/profile.d/freesurfer_env.sh && \
#     echo 'export FSFAST_HOME=/usr/local/freesurfer/fsfast' >> /etc/profile.d/freesurfer_env.sh && \
#     echo 'source $FREESURFER_HOME/FreeSurferEnv.sh' >> /etc/profile.d/freesurfer_env.sh && \
#     echo 'source /etc/profile.d/freesurfer_env.sh' >> /etc/bash.bashrc

# Install miniconda
RUN curl -sSLO https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda-latest-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda-latest-Linux-x86_64.sh && \
    echo '#!/bin/bash' > /etc/profile.d/conda_env.sh && \
    echo 'export PATH=/usr/local/miniconda/bin:$PATH' >> /etc/profile.d/conda_env.sh && \
    echo 'source /etc/profile.d/conda_env.sh' >> /etc/bash.bashrc

ENV PATH /usr/local/miniconda/bin:$PATH

# Install dependencies in conda
RUN conda install --yes cython \
                        h5py \
                        ipython \
                        jupyter \
                        matplotlib \
                        networkx \
                        nose \
                        numpy \
                        pandas \
                        scikit-image \
                        scikit-learn \
                        scipy \
                        seaborn && \
    python -c "from matplotlib import font_manager" && \
    conda clean -tipy

# Install dependencies in pip
RUN pip install --upgrade pip && \
    pip install --upgrade dipy \
                          nibabel \
                          nipy \
                          pydotplus \
                          rdflib \
                          xvfbwrapper

# Install graphviz and pygraphviz
RUN apt-get install -y graphviz libgraphviz-dev && \
    pip install --upgrade pygraphviz graphviz

# Install nipype
RUN pip install -e git+https://github.com/nipy/nipype#egg=nipype

# Clear apt cache and other empty folders
RUN apt-get clean remove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /boot /media /mnt /opt /srv

# Switch back to main user
USER main

# Switch working directory to /home
WORKDIR /home

CMD ["/bin/bash"]
