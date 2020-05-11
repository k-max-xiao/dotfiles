# Dotfile Synchronisation and Auto Installer

**The main purpose of this repository is to make the switch from one laptop to the other seamless.**

When moving to a new laptop or desktop, installing the necessary software and libraries and configuring the settings according to personal preference will always cost a lot of time, and often the results are not perfect as some libraries or settings may be missing.

This repository aims to automate the stated installation and configuration process so ultimately one can just call one single script and then enjoy a coffee or do other things while the script will take care of all the burden works.

In addition, this script should be idempotent so that to run it for multiple times will lead to the same results without side effect. This means one can safely run it whenever it is necessary, for example to restore the default preferred settings or to reinstall missing dependencies after long use of the system.

Although the ultimate goal is to automate all the installation and configuration, some are not easy to automate, like installing *Chrome* or *Sougou Pinyin*. Therefore, one should follow the manual installation instructions to perform the manual operations after the successful running of the script. These manual operations will be automated in the future updates.

## How to use this repository

1. Run the `install.sh` script to automatically install necessary software and libraries and configure the settings according to preferences.
2. Perform necessary manual operations noted in `manual_install.md` to install the remained software and libraries and to configure the remained settings.

## Content and Structure of the repository

- `basics`: the basic dotfiles to be soft linked to the home folder
- `installers`: the sub installer scripts for different software or libraries
- `notes`: the notes of the gained experiences
- `tests`: the unit tests for the installer scripts
- `tests_snap`: the unit tests for installation via snap
- `Dockerfile`: the docker file for making a pure environment for unit testing
- `install.sh`: the file to execute by the user, the entry point of the project
- `manual_install.md`: the note including all the manual operations that the user need to follow after the successful running of the `install.sh` script
- `setup_symlinks.sh`: the script to safely soft link all dotfiles into the home folder and back up the original ones
- `util_funcs.sh`: the helper functions