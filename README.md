# forceful-InMusic2022

Software used for a study on touchless interface design, to be presented at the 2022 Innovation in Music conference in Stockholm.

## Getting started

### Installing

Prerequisites:

- [Node.js](https://nodejs.org/)
- [SuperCollider](https://supercollider.github.io/)
- [Leap Motion controller driver](https://developer.leapmotion.com/setup/desktop) (only tested with the legacy version)
- [Git](https://git-scm.com/)
- Windows

To download and run the software, open a terminal (PowerShell is recommended on windows) and navigate to a folder where the software can be downloaded. Then run these commands:

```PowerShell
git clone --recursive https://github.com/sparkletop/forceful-InMusic2022
.\forceful-InMusic2022\start.ps1
```

This will download necessary node modules and launch begin to pull data from the Leap Motion controller. In the SuperCollider IDE, place the cursor on any line in the init.scd document and press Ctrl+Enter. This will launch the synthesis engine and graphical user interface.

## Removing the software

To uninstall, simply delete the folder "forceful-InMusic2022" where the software resides. This will remove the downloaded node modules as well. For the other required software (node.js, SuperCollider, Leap Motion driver), see their respective documentation for uninstall instructions.
