#!/usr/bin/env python

import re
import urllib
page = urllib.urlopen('https://dl.slic3r.org/linux/').read()
print(re.search(r'slic3r-.+?-linux-x64\.tar\.bz2', page).group(0))
