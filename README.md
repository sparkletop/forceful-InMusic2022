# forceful-InMusic2022

Software used for a study on touchless interface design, to be presented at the 2022 Innovation in Music conference in Stockholm.

## Getting started

### Installing

Prerequisites:

- [Node.js](https://nodejs.org/)
- [SuperCollider](https://supercollider.github.io/)
- [Leap Motion controller driver](https://developer.leapmotion.com/setup/desktop) (tested with the legacy version)
- [Git](https://git-scm.com/)

This software has been tested under Windows.

### Running

To run the software, open a PowerShell terminal and navigate to a folder where the software can be downloaded. Then run these commands:

```PowerShell
git clone --recursive https://github.com/sparkletop/forceful-InMusic2022
cd forceful-InMusic2022
.\start.ps1
```

This will launch a small program that acts as a bridge between the Leap Motion controller and SuperCollider. In the SuperCollider IDE, place the cursor on any line in the init.scd document and press Ctrl+Enter to start the synthesis engine and graphical user interface. Examples can then be started and stopped with the user interface.

## Removing the software

To uninstall, simply delete the folder "forceful-InMusic2022" where the software resides. This will remove the downloaded node modules as well. For the other required software (Node.js, SuperCollider, Leap Motion driver, Git), see their respective documentation for uninstall instructions.
