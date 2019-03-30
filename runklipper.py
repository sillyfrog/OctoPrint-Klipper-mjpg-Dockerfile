#!/usr/bin/env python

import subprocess
import time
import os
import pwd

def main():
    while 1:
        klipper = subprocess.Popen(['/home/octoprint/klippy-env/bin/python', '/home/octoprint/klipper/klippy/klippy.py', '/home/octoprint/.octoprint/printer.cfg'])
        if klipper.wait() == 0:
            # Exited cleanly, don't sleep for long
            time.sleep(1)
        else:
            # Something went wrong, wait a bit before trying again
            time.sleep(30)


if __name__ == '__main__':
    main()

