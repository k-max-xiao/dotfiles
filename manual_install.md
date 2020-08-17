# Necessary Manual Installations or Settings

The `install.sh` could help us install a lot of the necessary software and configure a lot of useful settings, but not all can be easily done in automation.
Sometimes it may be worth to manually install few programs and manually configure some settings instead of spending too much time to automate them in an ugly way, especially when these manual operations are only needed in a very low frequency.

The following sections list the manual operations to execute after running the `install.sh` in a brand new Linux. It's better to go through all of them before actually starting to use the os for a much better seamless transfer experience.

------

## Chrome

Chrome is number one to install as it will be needed to download and install the other stuffs.

1. Download the `.deb` installer from the official website.
2. Install it
3. Login in Chrome and sync settings
4. Create shortcuts for the frequently used web pages, for example:
   1. Gmail
   2. Lookout
   3. ToDo List
   4. Google Keep

------

## Sougou Pinyin

Currently, Sougou Pinyin is the only good Chinese input on a Ubuntu system, since the Google Pinyin discontinued by March 2019.

1. Download the install package via the following [link](https://pinyin.sogou.com/linux/?r=pinyin)

2. Install the debian package via Software Center by double clicking

3. Resolve the broken dependencies (mainly the fcitx dependencies) via a terminal (`-f` means to fix the broken dependencies): `sudo apt-get install -f`

4. You may need to restart the system, change the input method to fcitx and add the Sogou Input into the list of available inputs

------

## nVidia Driver

nVidia driver is definitely a must if one wants to release the full power of the GPU or to use GPU for heavy scientific computations.

1. If *third party drivers* has been selected in Ubuntu installation, a NVidia driver should have already been installed
2. This driver may not be the latest long-live stable version, e.g. in this installation it is the version 384.130
3. You still need to manually switch to it via *System settings...->Software & Updates->Additional Drivers*

------

## Disable Recent Usage Recording

1. Open **System Settings** via clicking right top *setting* button
2. Choose **Security & Privacy** then **Files & Applications** tab
3. Clear All Usage Data
4. Turn off recording file and application usage

------

## Docker

Docker installation has been automated in the `install.sh` script. But one may need to restart the system to actually activate `docker` in the system, which is one required step in Docker's post-installation instructions.

------

## Baidu Pan

Baidu Pan is a very popular cloud in China. It now has a Linux client for Ubuntu 18.04. One can download and install it from its official website.

------

## Wine and winetricks

*wine* is necessary and sometimes very useful on Linux and *winetricks* is its good companion.

1. Install *wine* by following the instructions on its official website. Someone suggests the x86 version for compatibility but it may be worth to check if x64 version is now compatible with x86 now.
2. Install *winetricks*.
3. set up locales and alias for using wine in different locales

The following code snippet was used in the install script for Ubuntu 16.04 and only serves as a reference. The installation on Ubuntu 18.04 may be largely simplified.

```bash
### install wine
function install_wine {
    # to enable 32 bit architecture:
    dpkg --add-architecture i386
    # download and add the repository key
    wget -P $_tmp_download_folder -nc https://dl.winehq.org/wine-builds/winehq.key
    apt-key add $_tmp_download_folder/winehq.key
    # add the repository
    apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ xenial main'
    # update packages
    apt update >/dev/null
    # install the development branch
    apt install --install-recommends winehq-devel
    # remove the winekey file
    rm $_tmp_download_folder/winehq.key
}
```

------

## ROS

ROS (Robot Operating System) is necessary for any robotic project. ROS Kinetic is the version for Ubuntu 16.04 and it's ROS Melodic for Ubuntu 18.04.
The ROS official website provides good installation instructions and one only needs to follow that.

The following code snippet was used in the install script for Ubuntu 16.04 and ROS Kinetic and only serves as a reference.

```bash
### install ROS Kinetic
function install_ROS_Kinetic {
    # manually check the permissions to "restricted", "universe" and "multiverse" repositories via "System Settings -> Software & Updates"
    # to add the source repository and the ropository key to the system config
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
    # to update and install ROS Kinetic
    apt update >/dev/null
    apt -y install ros-kinetic-desktop-full || return 1
    # to initialise the rosdep
    rosdep init
    rosdep update
    # to setup ROS environment variables
    _dotfiles_dir=`dirname $0`/system/
    if [[ `grep "source /opt/ros/kinetic/setup.bash" ${_dotfiles_dir}sources | wc -l` -eq 0 ]]; then
        echo "" >> ${_dotfiles_dir}sources
        echo "###### export ROS Kinetic environment variables" >> ${_dotfiles_dir}sources
        echo "source /opt/ros/kinetic/setup.bash" >> ${_dotfiles_dir}sources
        echo "" >> ${_dotfiles_dir}sources
    fi
    unset _dotfiles_dir
    # to install tools and dependencies for building ROS packages
    apt -y install python-rosinstall python-rosinstall-generator python-wstool build-essential
}
```

------

## ROS 2

ROS 2 has already released some stable official versions. As the successor of ROS, ROS 2 has great improvement from design to implementation, making it more stable and a better option for robotic project, no matter personal or commercial, in long term. The community of ROS 1 will also transfer to the community of ROS 2 in long term. Therefore, it is worth to install ROS 2 on the machine as well, independent to the installation of ROS 1.

Please refer to the official website for the installation guidance.

------

## OpenCV

OpenCV is the most important library for Computer Vision projects. It is worth to install the latest version on machine. Please refer to the official website for the installation instructions.

The following code snippet was used in the install script for Ubuntu 16.04 and was for installing OpenCV 3. However, OpenCV 4 is available and installation on Ubuntu 18.04 may be simplified. So please only use the snippet as a reference.

```bash
### install OpenCV 3.4.6 for both Python 2 and Python 3, also enabling CUDA, DNN and CPU Optimisation
function install_OpenCV3_for_Py2_and_Py3 {
    # to install the required compiler
    apt -y install build-essential
    # to install the required packages
    apt -y install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
    # to install the optional packages
    apt -y install python-dev python3-dev python-numpy python3-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
    # to install other optional image/video packages
    apt -y install libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev
    apt -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
    apt -y install libxvidcore-dev libx264-dev
    # to install GTK for GUI features
    apt -y install libgtk-3-dev
    # to install optional packages for optimisations like matrix operations
    apt -y install libatlas-base-dev gfortran
    # to clone the opencv and opencv_contrib repositories
    git clone --branch 3.4.6 https://github.com/opencv/opencv.git $_tmp_download_folder/opencv
    git clone --branch 3.4.6 https://github.com/opencv/opencv_contrib.git $_tmp_download_folder/opencv_contrib
    # to set up the build
    _cwd=$(pwd)
    cd $_tmp_download_folder/opencv
    rm -rf build
    mkdir build
    cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D INSTALL_C_EXAMPLES=ON \
            -D INSTALL_PYTHON_EXAMPLES=ON \
            -D OPENCV_EXTRA_MODULES_PATH=$_tmp_download_folder/opencv_contrib/modules \
            -D BUILD_EXAMPLES=ON \
            -D BUILD_opencv_python2=ON \
            -D BUILD_opencv_python3=ON \
            -D BUILD_opencv_dnn=ON \
            -D WITH_V4L=ON \
            -D WITH_LIBV4L=ON \
            -D WITH_FFMPEG=ON \
            -D WITH_TIFF=ON \
            -D WITH_CUDA=ON \
            -D CUDA_GENERATION=Pascal \
            -D ENABLE_FAST_MATH=ON \
            -D CUDA_FAST_MATH=ON \
            -D WITH_CUBLAS=ON \
            -D WITH_LAPACK=OFF \
            -D ENABLE_AVX=ON \
            -D ENABLE_AVX2=ON \
            -D ENABLE_POPCNT=ON \
            -D ENABLE_SSE41=ON \
            -D ENABLE_SSE42=ON \
            -D ENABLE_SSSE3=ON \
            -D PYTHON2_EXECUTABLE=/usr/bin/python \
            -D PYTHON2_INCLUDE_DIR=/usr/include/python2.7 \
            -D PYTHON2_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython2.7.so \
            -D PYTHON2_NUMPY_INCLUDE_DIRS=/usr/lib/python2.7/dist-packages/numpy/core/include \
            -D PYTHON3_EXECUTABLE=/usr/bin/python3 \
            -D PYTHON3_INCLUDE_DIR=/usr/include/python3.5 \
            -D PYTHON3_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.5m.so \
            -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/lib/python3/dist-packages/numpy/core/include \
            ..
    # to make the build
    make -j6
    # to build the documents
    cd doc
    make -j6 doxygen
    cd ..
    # to actually install
    make install
    # to download and run tests
    git clone --branch 3.4.6 https://github.com/opencv/opencv_extra.git $_tmp_download_folder/opencv_extra
    set OPENCV_TEST_DATA_PATH=$_tmp_download_folder/opencv_extra/testdata
    ./bin/opencv_test_core
    unset OPENCV_TEST_DATA_PATH
    # go back to the normal working directory
    cd $_cwd
    # to change the name of the cv2.so installed by ros-kinetic-opencv3 so that both Python2&3 can use the newly built OpenCV3
    if [[ -f /opt/ros/kinetic/lib/python2.7/dist-packages/cv2.so ]]; then
        mv /opt/ros/kinetic/lib/python2.7/dist-packages/cv2.so /opt/ros/kinetic/lib/python2.7/dist-packages/cv2.so.backup
    fi
    true
}
function check_OpenCV3_installed {
    if [[ $(pkg-config --modversion opencv | grep "3.[4-9].[0-9]*" | wc -l) -gt 0 ]]; then
        echo "  ${cyan}opencv $(pkg-config --modversion opencv) has ALREADY been installed.${reset}"
        return
    else
        echo "  ${magenta}opencv3 has NOT been installed.${reset}"
    fi
    false
}
```

------

## Scientific Libraries

There are a lot of useful scientific libraries written in C or C++. They may be needed in scientific or robotic projects so it may be worth to install (or more often to compile) them. The following is an incomplete list and please refer to the official website of each library for correct installation.

- Eigen3
- Ceres
- g2o

------

## PyTorch (Optional)

`PyTorch` is another popular deep learning framework and it is getting more and more popularity. It is worth to install this as well so both of the two main stream deep learning frameworks will be available to use on the machine.

------

## Anaconda (Optional)

Anaconda is a platform for data science. The advantages includes one-stop solution for data science projects, `conda` replacing `virtualenv` and `pip`, some data science or finance libraries are newer or only available on `conda`. However, this software takes too much space, which sometimes can easily reach 10Gb or 20Gb, and lots of more general libraries are newer on `pip`.

It is worth to instal this software if the space is allowed or a library of a project is only available in `conda`. Even in such situation, `miniconda` may still be a better option than `anaconda`.
