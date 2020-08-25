# Dotfile Synchronisation and Software Installer

![CI Status](https://github.com/mosckital/dotfiles/workflows/CI/badge.svg)

**This project mainly serves to facilitate the preference synchronisation and to automate the software installation on a new machine with Ubuntu 18.04 as the OS.**

The preference synchronisation is done via softly linking the dotfiles in the project to the `$HOME` folder of the user and then `source` these dotfiles in the `.bashrc` file.

Currently, this project only supports the Ubuntu 18.04, but the supports for Ubuntu 20.04 and macOS are in the plan once the need requires or the time permits.

As a personal project, the software and settings are totally personal tastes and probably will not fully satisfy other's requirements.

This project is designed to be **idempotent**, which means one can safely run it for multiple times and every time the installer will deliver the same result.

Although the project aims to automate every single step of setting up a new machine, some of the steps are not easy to automate for now. There will be a section below to describe how to manually execute such non-automatic steps with details. These manual steps will be automated in the future once the situation permits.

## How to use this repository

1. Run the `install.sh` script to automatically install necessary software and libraries and synchronise the preferences.
2. Following the instructions detailed in the section **Manual Installations** below to perform the software installation or preference configuration that cannot be automated now. Some of the manual steps are optional.

## Content and structure of the repository

- `basics`: the basic dotfiles to be soft linked to the home folder
- `installers`: the sub installer scripts for different software or libraries
- `notes`: the notes of the gained experiences
- `tests_in_vm`: the unit tests for the installer scripts, which will be executed in the VM during continuous integration step.
- `tests_in_docker`: the unit tests to execute in a docker container of the target OS
- `Dockerfile`: the docker file for making a pure environment for unit testing
- `install.sh`: the file to execute by the user, the entry point of the project
- `setup_symlinks.sh`: the script to safely soft link all dotfiles into the home folder and back up the original ones
- `util_funcs.sh`: the helper functions

## List of auto-installed software

- Python Series:
  - Latest Python, currently `Python3.8`
  - `pip`
  - `pipenv`
  - `pyenv` and `pyenv-virtualenv`
  - `virtualenv` and `virtualenvwrapper`
- Installation via `apt`:
  - `git`
  - `vim`
  - `snapd`
  - `unar`
  - `terminator`
  - `google-chrome-stable` (need to add the repository into the source list as a prerequisite step)
  - `wine` and `winetricks`
- Installation via `snap`:
  - `cmake`
  - ~~`pycharm`~~ (currently disabled)
  - `Slack`
  - `sublime`
  - `Git Kraken`
  - `VS Code`
  - `postman`
  - `ffmpeg`
  - `Skype`
  - `clementine`
  - `wonderwall`
  - `easy-disk-cleaner`
  - `nodejs` including `npm`
- `Docker`
  - `Tensorflow` via Docker
- Latest `Nvidia Driver`
- `Zsh`, `Oh My Zsh` and `Powerlevel10k`

## Manual Installations

Some software are not that easy to automate the installation and some others requires manual settings to achieve a good performance after installation. Therefore, some manual steps are necessary after the success running of the `install.sh` script, and this section will go into the details of these manual steps.

Each sub-section below will focus on one topic, but the user can perform the manual operations following the order although it's not forced. Please feel free to take your own order when needed.

### Configure Zsh and Powerlevel10k

Although `zsh` should have been set as the default shell by the `install.sh` script, it is still worth to check it by simply opening a terminal.

If it's set, you should in `zsh`, not `bash`, in the new terminal and it may ask you to configure `Powerlevel10k`. You can simply follow the wizard to configure the theme. If the wizard does not show up, you can start it by `p10k configure`.

### Chrome

The installation of *Chrome* is now automated, but it's recommended to:

1. Log in *Chrome* and sync the browser settings
2. Create shortcuts for the frequently used web pages like *Gmail*, *ToDo List* or *Google Keep*.

### Sougou Pinyin

Currently, *Sougou Pinyin* is the only good Chinese input on Ubuntu, since the Google Pinyin discontinued by March 2019.

1. Download the install package via the following [link](https://pinyin.sogou.com/linux/?r=pinyin)
2. Install the debian package via Software Center by double clicking
3. Resolve the broken dependencies (mainly the fcitx dependencies) via a terminal (`-f` means to fix the broken dependencies): `sudo apt-get install -f`
4. You may need to restart the system, change the input method to fcitx and add the Sogou Input into the list of available inputs

[This article](https://zhuanlan.zhihu.com/p/34270907) also describes the process in details with screenshots.

### Disable Recent Usage Recording

1. Open **System Settings**
2. Choose **Privacy** tab on the left
3. Click **Usage & History**
4. Clear all historic data by clicking **Clear Recent History** button
5. Turn off **Recently Used**

### Docker

Docker installation has been automated in the `install.sh` script. But one may need to restart the system to actually activate `docker` in the system, which is one required step in Docker's post-installation instructions.

### Baidu Pan

Baidu Pan is a very popular cloud in China. It now has a Linux client for Ubuntu 18.04. One can download and install it from its official website.

### Wine and winetricks

*wine* is necessary and sometimes very useful on Linux and *winetricks* is its good companion. Their installations are automated, but it's recommended to:

1. Run `winecfg` once after installation of *wine* for some initial configuration, like installing *Mono* and *Gecko*.
2. Create alias for different locales if necessary.

### ROS and ROS2 (Optional)

ROS (Robot Operating System) is necessary for any robotic project. ROS Kinetic is the version for Ubuntu 16.04 and it's ROS Melodic for Ubuntu 18.04. The ROS official website provides good installation instructions and one only needs to follow that.

ROS2 is the successor of ROS with a great improvement from design to implementation, making it more stable and a better option for robotic project, no matter personal or commercial, in long term. The community of ROS 1 will also transfer to the community of ROS 2 in long term.

It may be a good idea to try out ROS2 as it becomes more and more friendly and competent.

### OpenCV (Optional)

OpenCV now can be installed via the `opencv-python` or its sibling packages via `pip` with an easy command. This is the suggested method now instead of compiling it from source code.

### Scientific Libraries (Optional)

There are a lot of useful scientific libraries written in C or C++. They may be needed in scientific or robotic projects so it may be worth to install (or more often to compile) them. The following is an incomplete list and please refer to the official website of each library for correct installation.

- Eigen3
- Ceres
- g2o

### PyTorch (Optional)

`PyTorch` is another popular deep learning framework and it is getting more and more popularity. It is worth to install this as well so both of the two main stream deep learning frameworks will be available to use on the machine.

### Anaconda (Optional)

Anaconda is a platform for data science. The advantages includes one-stop solution for data science projects, `conda` replacing `virtualenv` and `pip`, some data science or finance libraries are newer or only available on `conda`. However, this software takes too much space, which sometimes can easily reach 10Gb or 20Gb, and lots of more general libraries are newer on `pip`.

It is worth to instal this software if the space is allowed or a library of a project is only available in `conda`. Even in such situation, `miniconda` may still be a better option than `anaconda`.
