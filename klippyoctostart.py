#!/usr/bin/env python

import subprocess
import time
import os

OCTOPRINT = ["/opt/octoprint/venv/bin/octoprint", "serve"]

def main():
    os.environ['HOME'] = '/home/octoprint'

    # Start klipper
    klipper = subprocess.Popen(['/home/octoprint/klippy-env/bin/python', '/home/octoprint/klipper/klippy/klippy.py', '/home/octoprint/.octoprint/printer.cfg'])

    # Run in a loop so Octoprint can restart in the container
    while 1:
        Poctoprint = subprocess.Popen(OCTOPRINT)
        Poctoprint.wait()
        time.sleep(1)

if __name__ == '__main__':
    main()

