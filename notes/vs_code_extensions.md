# VS Code Extensions

The extensions, both official or community ones, are the most crucial advantage of **VS Code**.

It is a good idea that the usage experiences and the learned lessons about the **extensions** can be collected and stored in a central place, so we can easily review them or refer to them in the future.

This file is the main entry for the gained experiences, while there may be other files recording the gained experiences for specific aspect of using *VS Code*. All these note files will have a name starting with **vs_code_** followed by one or few words to describe the specific aspect.

*For example, there may be a file named **vs_code_python.md** to records the experiences of Python programming in VS Code.*

## Settings Synchronisation

The settings of the **VS Code** is currently synchronised via an extension named *Settings Sync* and the synced settings are stored in a private gist on GitHub.

*VS Code Insider* version has the built-in sync feature for settings either via a GitHub account or a Microsoft account, and this feature may be available in normal *VS Code* very soon as well.

## Manage extensions in command line

Fortunately, **VS Code** provides CLI options to manage extensions via command line. The followings are the available options and one can find the details [here](https://code.visualstudio.com/docs/editor/command-line#_working-with-extensions).

- `code -- install-extension [--force] <ext>`: install an extension. `--force` option can avoid any prompt.
- `code --uninstall-extension <ext>`: uninstall an extension.
- `code --disable-extensions`: disable **ALL** installed extensions.
- `code --list-extensions [--show-versions]`: list all installed extensions. `--show-versions` option can show versions in addition to the extensions full name.
- `code --enable-proposed-api <ext>`: enable proposed api features for an extension.

## List of installed extensions

With the `code --list-extensions` command, we can obtain the list of all installed extensions, like the one below:

```Shell
austin.code-gnu-global
DavidAnson.vscode-markdownlint
DavidSchuldenfrei.gtest-adapter
DotJoshJohnson.xml
eamodio.gitlens
Equinusocio.vsc-community-material-theme
Equinusocio.vsc-material-theme
equinusocio.vsc-material-theme-icons
foxundermoon.shell-format
GitHub.vscode-pull-request-github
hbenl.vscode-test-explorer
hdg.live-html-previewer
jetmartin.bats
mechatroner.rainbow-csv
mhutchie.git-graph
ms-azuretools.vscode-docker
ms-python.python
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode-remote.remote-wsl
ms-vscode-remote.vscode-remote-extensionpack
ms-vscode.cmake-tools
ms-vscode.cpptools
Shan.code-settings-sync
streetsidesoftware.code-spell-checker
tht13.html-preview-vscode
twxs.cmake
VisualStudioExptTeam.vscodeintellicode
vsciot-vscode.vscode-arduino
yzhang.markdown-all-in-one
```

We can separate these extensions into multiple groups, where each group has a common purpose.

### General

- Test Explorer UI (hbenl.vscode-test-explorer)
- Rainbow CSV (mechatroner.rainbow-csv)
- Docker (ms-azuretools.vscode-docker)
- Settings Sync (Shan.code-settings-sync)
- Code Spell Checker (streetsidesoftware.code-spell-checker)
- Visual Studio IntelliCode (VisualStudioExptTeam.vscodeintellicode)

### Git

- GitLens (eamodio.gitlens)
- Git Graph (mhutchie.git-graph)
- GitHub Pull Requests and Issues (GitHub.vscode-pull-request-github)

### Python

- Python (ms-python.python)

### C++

- C/C++ (ms-vscode.cpptools)
- CMake Tools (ms-vscode.cmake-tools)
- C++ Intellisense (austin.code-gnu-global)
- GoogleTest Adapter (DavidSchuldenfrei.gtest-adapter)
- CMake (twxs.cmake)

### Robot

- Arduino (vsciot-vscode.vscode-arduino)
  
### shell

- shell-format (foxundermoon.shell-format)
- Bats (jetmartin.bats)

### Markdown

- markdownlint (DavidAnson.vscode-markdownlint)
- Markdown All in One (yzhang.markdown-all-in-one)

### HTML

- XML Tools (DotJoshJohnson.xml)
- Live HTML Previewer (hdg.live-html-previewer)
- HTML Preview (tht13.html-preview-vscode)

### Remote Development

- Remote Development (ms-vscode-remote.vscode-remote-extensionpack)
- Remote - WSL (ms-vscode-remote.remote-wsl)
- Remote - SSH (ms-vscode-remote.remote-ssh)
- Remote - SSH: Editing Configuration Files (ms-vscode-remote.remote-ssh-edit)
- Remote - Containers (ms-vscode-remote.remote-containers)

### Theme

- Material Theme (Equinusocio.vsc-material-theme)
- Community Material Theme (Equinusociovsc-community-material-theme)
- Material Them Icons (equinusocio.vsc-material-theme-icons)
