import pprint

import re
import os
import tempfile
import commands

# os.system("open https://developers.google.com/android/nexus/images?hl=en#shamu")
# build_number = raw_input("Enter your build number: ")
# build_number = 'LVY48E'

# base_url = "https://dl.google.com/dl/android/aosp/shamu-{}".format(build_number.lower())

response = commands.getoutput('curl https://developers.google.com/android/nexus/images?hl=en#shamu 2> /dev/null')
# print(response)

# https://dl.google.com/dl/android/aosp/shamu-lvy48e-factory-5e7c69da.tgz
# 5.1.1 (For Project Fi ONLY) (LVY48C)

# want all build numbers
results = re.findall(r'shamu[a-z0-9]{6}">\n\s{0,10}<td>(\d\.\d\.\d) \(([^)]+)\) \(([^)]+)\)', response)
results += re.findall(r'shamu[a-z0-9]{6}">\n\s{0,10}<td>(\d\.\d\.\d) \((L[^)]+)\)\n', response)

def hello(stuff):
    print(stuff)

versions = list(reversed(sorted(set(results))))
max_version_number = versions[0][0]
# versions = [('a', 'b', 'c'), ('a', 'b', 'c')]
versions = [i for i in versions if i[0] == max_version_number]
# versions = filter(lambda x: x[0] == max_version_number, versions)
pprint.pprint(versions)

## choose your version number


# match = re.search(r'%s-factory-([a-z0-9]{8}).(tgz)' % base_url, response)

# # https://dl.google.com/dl/android/aosp/shamu-lvy48e-factory-5e7c69da.tgz
# img_url = match.group(0)
# print(img_url)

# tempfile.mkdir("tmp")
# os.system("curl -O {} > ".format(img_url))
