# This Dockerfile is based on the dockerfiles 'crn_base' and 'crn_nipype' from
# the Poldrack Lab (https://github.com/poldracklab/crn_base), the dockerfiles
# from neurovault (https://github.com/NeuroVault/NeuroVault) and the dockerfile
# biss2016-notebook from Oscar Esteban under https://hub.docker.com/u/oesteban.
#
# This means that the same copyrights apply to this Dockerfile, as they do for
# the above mentioned dockerfiles. For more information see:
# https://github.com/miykael/nipype_env

MAINTAINER Michael Notter <michaelnotter@hotmail.com>

# Switch to root user for installation
USER root

# Preparations
RUN ln -snf /bin/bash /bin/sh
ARG DEBIAN_FRONTEND=noninteractive

# Update packages and install the minimal set of tools
RUN apt-get update && \
    apt-get install -y curl \
                       git \
                       xvfb \
                       bzip2 \
                       unzip \
                       apt-utils \
                       gfortran \
                       fusefat \
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
                       libyaml-dev -qq

# Enable neurodebian
RUN curl -sSL http://neuro.debian.net/lists/jessie.de-md.full | tee /etc/apt/sources.list.d/neurodebian.sources.list && \
    curl -sSL http://neuro.debian.net/lists/jessie.us-tn.full >> /etc/apt/sources.list.d/neurodebian.sources.list
RUN apt-key adv --recv-keys --keyserver hkp://pgp.mit.edu:80 0xA5D32F012649A5A9
RUN apt-get update -qq
RUN apt-get install -y fsl afni -qq

# Set-up environment
RUN echo '#!/bin/bash' > /etc/profile.d/neuro_env.sh && \
    echo 'FSLDIR=/usr/share/fsl' >> /etc/profile.d/neuro_env.sh && \
    echo 'source /etc/fsl/fsl.sh' >> /etc/profile.d/neuro_env.sh && \
    echo 'PATH=$FSLDIR/5.0/bin:$PATH' >> /etc/profile.d/neuro_env.sh && \
    echo 'export FSLDIR PATH' >> /etc/profile.d/neuro_env.sh && \
    echo 'export PATH=/usr/lib/afni/bin:$PATH' >> /etc/profile.d/neuro_env.sh && \
    echo 'source /etc/profile.d/neuro_env.sh' >> /etc/bash.bashrc
#RUN source activate neuro_env

# Update conda and install relevant dependencies
RUN conda update conda --yes --quiet
RUN conda update anaconda --yes --quiet
RUN conda install --yes --quiet cython \
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
                        seaborn
RUN python -c "from matplotlib import font_manager"
RUN conda clean -a

# Install dependencies in pip
RUN pip install --upgrade pip && \
    pip install --upgrade dipy \
                          graphviz \
                          nibabel \
                          nipy \
                          pydotplus \
                          rdflib \
                          xvfbwrapper \
                --ignore-installed

# Install nipype
RUN pip install -e git+https://github.com/nipy/nipype#egg=nipype

# Clear apt cache and other empty folders
RUN apt-get clean remove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /boot /media /mnt /opt /srv

ENV SHELL /bin/bash

CMD ["/bin/bash"]
