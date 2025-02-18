ARG BASE_IMAGE=condaforge/mambaforge

FROM $BASE_IMAGE

MAINTAINER "Giacomo Nodjoumi <giacomo.nodjoumi@hyranet.info>"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root
ARG ISISDATA=/isis/data
ARG ISISTESTDATA=/isis/testdata

RUN mkdir -p $ISISDATA && \
    mkdir -p $ISISTESTDATA

ARG ASP_VERSION="3.0.0"
ARG ISIS_VERSION="5"
ARG CONDA_DIR='/opt/conda'

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PATH="${CONDA_DIR}/bin:${PATH}"

RUN DEBIAN_FRONTEND=noninteractive        \
    && apt-get update --fix-missing       \
    && apt-get install --no-install-recommends -y \
          bzip2           \
          ca-certificates \
          curl            \
          git             \
          libgl1-mesa-glx \
          libjpeg9        \
          libjpeg9-dev    \
          python3-pip     \
          rsync           \
          wget            \
          vim             \
    && rm -rf /var/lib/apt/lists/*

RUN set -x && \
    conda update --all -y && \
    echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc && \
    conda create -n isis -c conda-forge -y python=3.6 && \
    source activate isis && \
    conda config --append channels usgs-astrogeology     && \
    conda config --append channels default                && \
    conda config --env --add channels nasa-ames-stereo-pipeline && \
    mamba install -n isis -c usgs-astrogeology isis=$ISIS_VERSION && \
    mamba install -n isis -c nasa-ames-stereo-pipeline stereo-pipeline==$ASP_VERSION && \
    conda clean -a && \
    python /opt/conda/envs/isis/scripts/isisVarInit.py \
    --data-dir=$ISISDATA  \
    --test-dir=$ISISTESTDATA

ENV JUPYTER_ENABLE_LAB='yes'
RUN echo "source activate isis" >> $HOME/.bashrc
