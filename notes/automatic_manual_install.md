# Automated Manual Installations

This note is a graveyard for the outdated sections in `manual_install.md`. An outdated section is a section that the installation of the correspondent software has been automated, which makes the manual installation instructions useless.

However, these sections may still have values, so they are moved hese for the potential future reference.

------

## Docker

Docker is often the easiest way to run a complicated system without spending hours or days to install or build it and its dependencies. Docker is a must if one wants to directly jump into the actual development instead of solving dependency hell in many situations, like using TensorFlow.

1. Follow the official guide to install Docker.
2. Follow the official guide to configure the settings.

------

## Infrastructure for GPU Computing and Deep Learning

Enable GPU computing and programming can be hugely beneficial to robotic, computer vision, machine learning or scientific projects. However, it is not that easy to set up all the required infrastructures and to release the power of GPU, especially if deep learning frameworks are also required.

This large section describes how enable GPU computing and set up deep learning framework in two ways:

1. Install nVidia Docker support and install TensorFlow-GPU docker.
2. Install required software one by one while these software respect the inter-dependencies.

Please be aware that, at least for Ubuntu 16.04 and TensorFlow 2.0, the deep learning framework requires a specific version of CUDA package and this dependency is not backwards compatible. So please take care into the software version and **always check the official guide** if one wants to follow the way #2.

Fortunately, with dockers, one can simply achieve the installation by way #1:

1. Install the [`Nvidia Container Toolkit`](https://github.com/NVIDIA/nvidia-docker/blob/master/README.md#quickstart) to add nVidia GPU support to Docker.
2. Install the GPU-enabled TensorFlow via Docker by following the official guide.
3. Configure necessary settings and start to use the docker by following the official guide.

The way #2 should only be the backup because, at least for Ubuntu 16.04 and TensorFlow 2.0, the deep learning framework requires a specific version of CUDA packages (version 10.0 for all relevant package and CUDA Toolkit) and this dependency is not backwards compatible. So one should keep taking care into the **software version**, **always check the official guide** and follow the step list below if one wants to follow the way #2.

1. Install CUDA
2. Install CuDNN
3. Install TensorRT
4. Install PyCuda (pip)
5. Install TensorFlow-GPU

The `TensorFlow` official website contains more information about how to correctly install all CUDA-related dependencies.

### CUDA

CUDA is the foundation of the whole infrastructure and thus the first one to install. The correct version of CUDA must be checked with TensorFlow official guide before the installation.

The following code snippet was used in the install script for Ubuntu 16.04 and only serves as a reference. The installation on Ubuntu 18.04 may be largely simplified.

```bash
### install Cuda
function install_cuda {
    ## pre-installation
    # to check if the nvidia driver has been installed
    if [[ `lspci | grep -i nvidia | wc -l` -eq 0 ]]; then
        >&2 echo "${red}Please enable the nvidia driver via \"System Settings->Software and Updates->Additional Drivers\"${reset}"
        false
        return
    fi
    # to manually verify if the Linux version is supported
    # uname -m && cat /etc/*release
    # to manually verify if the gcc version is supported
    # gcc --version
    # to manually verify if the kernel version is supported
    # uname -r
    # to install the kernel headers and development package
    echo "  ${cyan}Ready to install the kernel headers and development package${reset}"
    apt -y install linux-headers-$(uname -r) || return 1
    if [[ `ls $_tmp_download_folder/cuda-repo-ubuntu1604_$1*.deb | wc -l` -eq 0 ]]; then
        >&2 echo "${red}Please download the network version cuda repo debian package via official website${reset}"
        false
        return
    else
        _cuda_deb=$(ls $_tmp_download_folder/cuda-repo-ubuntu1604_$1*.deb | tail -1)
        # to manually check the MD5 sum
        echo "  ${cyan}The MD5 sum of the Cuda repo debian package is: $(md5sum $_cuda_deb)${reset}"
        echo "  ${cyan}Ready to install the Cuda repo deb package${reset}"
        dpkg -i $_cuda_deb || return 1
        apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
        apt update
        echo "  ${cyan}Ready to install the Cuda toolkit${reset}"
        apt -y install cuda-${1//./-} || return 1
        echo "  ${cyan}Ready to export the Cuda and Nsight path to PATH env"
        _dotfiles_dir=`dirname $0`/system/
        if [[ `grep "export PATH.*/usr/local/cuda/bin" ${_dotfiles_dir}exports | wc -l` -eq 0 ]]; then
            echo "" >> ${_dotfiles_dir}exports
            echo "###### export the Cuda and Nsight path to PATH env" >> ${_dotfiles_dir}exports
            # Warning: The cuda/bin has used softlink for convenience, but the NsightCompute-2019.3 is still hardcoded
            echo 'export PATH=/usr/local/cuda/bin:/usr/local/cuda/NsightCompute-2019.3${PATH:+:${PATH}}' >> ${_dotfiles_dir}exports
            echo "" >> ${_dotfiles_dir}exports
        fi
    fi
    unset _dotfiles_dir
    true
}
```

### CuDNN

CuDNN is also a must-have foundation and dependency for deep learning framework. Please be aware of the correct version as well.

Similarly, the following code snippet was used in the install script for Ubuntu 16.04 and only serves as a reference. The installation on Ubuntu 18.04 may be largely simplified.

```bash
### install CuDNN for Deep Learning Frameworks
function install_CuDNN {
    ## to download the runtime, developer and samples debian packages from https://developer.nvidia.com/rdp/cudnn-download
    _cudnn_deb=$(ls $_tmp_download_folder/libcudnn[0-9]_*+cuda$1_amd64.deb | tail -1)
    _cudnn_dev_deb=$(ls $_tmp_download_folder/libcudnn[0-9]-dev_*+cuda$1_amd64.deb | tail -1)
    _cudnn_doc_deb=$(ls $_tmp_download_folder/libcudnn[0-9]-doc_*+cuda$1_amd64.deb | tail -1)
    if [[ -f $_cudnn_deb ]] && [[ -f $_cudnn_dev_deb ]] && [[ -f $_cudnn_doc_deb ]]; then
        dpkg -i $_cudnn_deb
        dpkg -i $_cudnn_dev_deb
        dpkg -i $_cudnn_doc_deb
    else
        >&2 echo "${red}Please download the runtime, developer and samples CuDNN packages via official website${reset}"
        false
        return
    fi
}
```

### TensorRT

TensorRT is an SDK for high-performance deep learning inference. It is crucial for GPU programming and needed by TensorFlow. Please be aware of the correct version as well.

Similarly, the following code snippet was used in the install script for Ubuntu 16.04 and only serves as a reference. The installation on Ubuntu 18.04 may be largely simplified.

```bash
### install TensorRT for optimising TensorFlow and PyCUDA as CUDA Python wrapper
function install_TensorRT {
    # to check the local repo pack
    _tensorrt_deb=$(ls $_tmp_download_folder/nv-tensorrt-repo-*-cuda$1-*.deb | tail -1)
    if [[ -f $_tensorrt_deb ]]; then
        dpkg -i $_tensorrt_deb
        # to add the repo key
        apt-key add $(ls /var/nv-tensorrt-repo-cuda$1-*/*.pub | tail -1)
        apt update
        # to install tensorrt via its meta package
        apt -y install tensorrt
        # to install Python2, Python3 and TensorFlow supporting packages
        apt -y install python-libnvinfer-dev python3-libnvinfer-dev uff-converter-tf
    else
        >&2 echo "${red}Please download the TensorRT debian package via official website${reset}"
        false
        return
    fi
}
```

### PyCUDA

PyCUDA is only a Python wrapper for CUDA to facilitate the GPU programming in Python. It is recommended to install.

- PyCUDA is the Python wrapper for CUDA, which can be installed by `(g)pip install 'pycuda>=2017.1.1'`
- It may be better to install it in a virtualenv when needed
- Updating CUDA will break PyCUDA and will enforce to uninstall the old PyCUDA and then to install the new PyCUDA
- This Python wrapper only work for Python2 (importing it fails in Python3)

### TensorFlow

TensorFlow is the last one to install after all the prerequisites are satisfied. Please install the GPU version or otherwise the GPU computing will not contribute.

- Currently, TensorFlow debian installation only works with CUDA 10.0 suite (CUDA 10.0, CuDNN 7.4.1 and TensorRT 5.0.2)
- The TensorFlow can be installed via `(g)pip install tensorflow-gpu==2.0.0-alpha0`
- It may be better to install it in a virtualenv when needed
- `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64` may be needed

Similarly, the following code snippet was used in the install script for Ubuntu 16.04 and only serves as a reference. The installation on Ubuntu 18.04 may be largely simplified.

```bash
### install TensorFlow with GPU supporting
pip install tensorflow-gpu==2.0.0-alpha0
function tensorflow_set_ld_library_path {
    _dotfiles_dir=`dirname $0`/system/
    if [[ `grep "export LD_LIBRARY_PATH=.*/cuda/extras/CUPTI/lib64" ${_dotfiles_dir}exports | wc -l` -eq 0 ]]; then
        echo "" >> ${_dotfiles_dir}exports
        echo "###### export the CUDA's CUPTI lib path for TensorFlow with GPU" >> ${_dotfiles_dir}exports
        echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64' >> ${_dotfiles_dir}exports
        echo "" >> ${_dotfiles_dir}exports
    fi
}
```
