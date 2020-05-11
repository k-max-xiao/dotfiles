# ROS (Robot Operating System) tips

This note is responsible for storing all the gained experiences of using ROS in a single place.
Those experiences are mainly gained on the ROS Kinetic and nearly all of them should be transferable to the later versions of ROS.

------

## Overlaying or Switching workspaces

- `catkin_make` will automatically detect the already sourced workspace and overlay the current workspace on top of it
  - the result of this is the *devel/setup.bash*
  - this overlay mechanism is static, which means if you later add or remove a sourced workspace before you source this workspace's *setup.bash*, the overlay structure will not change as it has been decided during `catkin_make` and the add or remove of workspace may even bring potential conflicts in environment variables.
  - as a consequence, you will always see `-- This workspace overlays: /opt/ros/kinetic` during a `catkin_make`, even for a brand new first workspace.
- If I want to switch between workspace A and B, I need to ensure that the other workspace is not sourced during the `catkin_make` process. Later, I just need to source the wanted workspace's *setup.bash* before using the workspace.
  - in order to not accidentally overlaying the switching workspaces, it's better to only source ROS's *setup.bash* in *.bashrc*, make a virtualenv for each workspace and source the workspace's *setup.bash* during the initiation of the virtualenv.
  - the above can be done by source `setup.bash` in the `$VIRTUAL_ENV/bin/postactivate` (to create this file if it does not exist)

------

## Quick Tips

- To install all the system dependencies for the packages in the workspace:

    ```bash
    sudo rosdep install --from-path src --ignore-src -r -y --rosdistro kinetic
    ```

- To ignore a package of the current workspace for `catkin_make`, one can simply create an empty file called `CATKIN_IGNORE` in the root folder of the package.
- There is a security incident with the old GPG key for ROS repository, which makes **apt install ros-kinetic-xxx** fails. The solution is to delete the old key and use the new key by the following: (more details can be found [here](http://answers.ros.org/question/325039/apt-update-fails-cannot-install-pkgs-key-not-working/)

    ```bash
    # delete the old key
    sudo apt-key del 421C365BD9FF1F717815A3895523BAEEB01FA116
    # add the new key
    sudo -E apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
    ```

------

## Differences between *catkin*, *rosdep* and *wstool*

- [*rosdep*](http://wiki.ros.org/rosdep) is a command-line tool for installing system dependencies
  - it is used to make sure that you have all the necessary system dependencies (typically the binary pkgs, i.e. the *debs* on Ubuntu/Debian) installed on your system
  - it is used at the packaging level to allow the user or build farm to make sure that all the dependencies are installed. The dependencies are declared at the level of installation units. However they are not used by cmake/catkin at configure/compile time
- [*wstool*](http://wiki.ros.org/wstool) is command-line tools for maintaining a workspace of projects from multiple version-control systems
  - it manages source checkouts/git clones in a workspace
  - it is used to get the sources of the packages that you wish to work on (or need to compile, if there are no binaries for your platform)
  - it provides commands to manage several local SCM repositories (git, mercurial, subversion, bazaar) based on a single workspace definition file (.rosinstall)
  - as catkin workspaces create their own setup file and environment, wstool is reduced to version control functions only
- [*catkin*](http://wiki.ros.org/catkin) is the build system for ROS, especially used for building/compiling the development workspace
- Use *rosdep* to install the system dependencies, then use *wstool/rosinstall* to manage the source code type package dependencies (even checkout the packages in development from remote repositories), lastly use *catkin* to build the system at local.

------

### Configuring PyCharm for ROS project

- The following [link](http://wiki.ros.org/IDEs) gives guidance on how to set PyCharm compatible with ROS development
- Adding `bash -i -c` to the start of the Snap PyCharm .desktop file
- Setting up a virtualenv inside PyCharm specifically for ROS project
