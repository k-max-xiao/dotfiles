#!/bin/bash
# This install file will execute the following tasks:
# 1. clean and setup soft links for dotfiles

###### to import the funtions of setting up soft links
source setup_symlinks.sh
# actually call and execute the task
dir=${1:-$HOME}
setup_symlinks $dir
# source the updated .bashrc file
source $dir/.bashrc

###### to install the necessary softwares

### to install Python3, pip and virtual environment tools
source ./installers/python3.sh
install_latest_python3
# source the updated .bashrc file
source $dir/.bashrc

### to install Docker and to execute post installation steps
source ./installers/docker.sh
install_docker_all_in_one
# source the updated .bashrc file
source $dir/.bashrc

### to install all apt applications
source ./installers/apt.sh
# install all applications one by one
install_apt_all_in_one

### to install all snap applications
# this should be placed after apt installations as snapd will be installed via 
# apt
source ./installers/snap.sh
# install all applications one by one
install_snap_all_in_one

### to install TensorFlow 2.0 with GPU, Python3 and Jupyter supports
### this requires that Docker is already installed
### this step may take long time as nVidia docker image and tensorflow docker
###     image are very large
source ./installers/tensorflow_docker.sh
install_tensorflow_all_in_one

### to install the appropriate nvidia driver via ubuntu-drivers
source ./installers/nvidia_driver.sh
install_nvidia_driver

# source the updated .bashrc file
source $dir/.bashrc