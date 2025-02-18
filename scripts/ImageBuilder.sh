#!/bin/bash

jupyter="y"
SHORT=J:,j:,G:,g:,h
LONG=JUPYTER:,jupyter:,help
OPTS=$(getopt -a -n jupyterhub --options $SHORT --longoptions $LONG -- "$@")
eval set -- "$OPTS"
while :
do
  case "$1" in
    -J | --JUPYTER )
      jupyter="$2"
      shift 2
      ;;
    -j | --jupyter )
      jupyter="$2"
      shift 2
      ;;
    -h | --help)
      echo -e "This is a script to build docker-isis-asp + jupyter:
            \n-j to install jupyter - default: $jupyter
            \n-g to install gispy - default: $gispy"
      exit 2
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option, using defaults"
      break
      ;;
  esac
done

ASP_VERSION='3.0.0'
ISIS_VERSION='5'
GDAL_VERSION='3.4.1'
JUPYTER_ENABLE_LAB='yes'
DOCKERFILE=isis5-asp3.dockerfile
GISPY_DOCKERFILE=gispy.dockerfile

BASE_IMAGE="condaforge/mambaforge"
ISIS_IMAGE="isis5-asp3:base"

echo "ISIS version $ISIS_VERSION will be installed"
echo "NASA_Ames Stereo Pipeline 3.0.0 will be installed"
echo "Jupyter + GIS-python install: $jupyter"

  if [[ $jupyter =~ ^[Yy1]$ ]]
    then
      BASE_IMAGE="jupyter/base-notebook:lab-3.2.8"
      JUPYTER_GISPY_IMAGE="jupyter-gispy:gdal"
      docker build -t "$JUPYTER_GISPY_IMAGE"               \
              --build-arg BASE_IMAGE="$BASE_IMAGE"        \
              -f $PWD/dockerfiles/$GISPY_DOCKERFILE .
      BASE_IMAGE=$JUPYTER_GISPY_IMAGE
      ISIS_IMAGE="isis5-asp3-gispy:lab"
    else
      JUPYTER_ENABLE_LAB='no'
  fi

  echo "Creating $ISIS_IMAGE image"
  docker build -t "$ISIS_IMAGE"                              \
          --build-arg BASE_IMAGE="$BASE_IMAGE"               \
          --build-arg ISIS_VERSION="$ISIS_VERSION"           \
          --build-arg ASP_VERSION="$ASP_VERSION"             \
          -f $PWD/dockerfiles/$DOCKERFILE .
  [ $? ] && echo "Docker image $ISIS_IMAGE built."
