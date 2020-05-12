#!/bin/bash
# This install script will install TensorFlow 2.0 with GPU support via Docker by
# following the below steps:
# 1. Install the NVIDIA Container Toolkit
#    https://github.com/NVIDIA/nvidia-docker
# 2. install the latest tensorflow docker with GPU, Python3 and Jupyter supports
#    https://www.tensorflow.org/install/docker

#######################################
# Install the nVidia Container Toolkit
# Details: https://github.com/NVIDIA/nvidia-docker
#######################################
function install_nvidia_container_toolkit {
    print_info "Ready to install nVidia Container Toolkit"
    # Add the package repositories
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

    sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
    sudo systemctl restart docker
    # print out message depending on result
    if [ $? -eq 0 ]; then
        print_success "nVidia Container Toolkit has been installed"
        return 0
    else
        print_error "Failed to install TensorFlow 2.0 with GPU support"
        return 1
    fi
}

#######################################
# Install TensorFlow 2.0 with GPU, python3 and Jupyter supports
# Details: https://www.tensorflow.org/install/docker
#######################################
function install_tensorflow_gpu_py3_jupyter {
    print_info "Ready to pull TensorFlow 2.0 with GPU support via Docker"
    docker pull tensorflow/tensorflow:latest-gpu-py3-jupyter
    # print out message depending on result
    if [ $? -eq 0 ]; then
        print_success "TensorFlow 2.0 with GPU support has been installed"
        return 0
    else
        print_error "Failed to install TensorFlow 2.0 with GPU support"
        return 1
    fi
}

#######################################
# TensorFlow's installer function, which combines the above two steps
#######################################
function install_tensorflow_all_in_one {
    print_info "Starting to install TensorFlow 2.0 with GPU support via Docker"
    install_nvidia_container_toolkit
    if [ $? -ne 0 ]; then
        print_error "Installing TensorFlow 2.0 failed at step 1: installing nVidia Container Toolkit"
        return 1
    fi
    install_tensorflow_gpu_py3_jupyter
    if [ $? -ne 0 ]; then
        print_error "Installing TensorFlow 2.0 failed at step 2: pull tensorflow docker"
        return 1
    fi
    print_success "Succeeded to install TensorFlow 2.0 with GPU support via Docker!"
}