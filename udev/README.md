# udev Rules and Commands

This directory contains the commands and rules I add to udev to make turning the printer on and off go smoothly, including re-connecting (my Docker container runs 24x7, however I turn off the printer when not in use).

The `okmd-udev.rules` file should be copied to `/etc/udev/rules.d/`, and updated to have the correct paths and device names for your environment.

The commands (`printer-*`), should also be updated to match your device names, and include your OctoPrint API key.
