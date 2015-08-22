import pprint

import re
import os
import shutil
import tempfile
import zipfile
import commands

#### UNCOMMENT THESE LINES TODO ####

# os.system("open https://developers.google.com/android/nexus/images?hl=en#shamu")
# build_number = raw_input("Enter your build number: ")
# build_number = 'LVY48E'

# base_url = "https://dl.google.com/dl/android/aosp/shamu-{}".format(build_number.lower())

response = commands.getoutput('curl https://developers.google.com/android/nexus/images?hl=en#shamu 2> /dev/null')
# print(response)

# https://dl.google.com/dl/android/aosp/shamu-lvy48e-factory-5e7c69da.tgz
# 5.1.1 (For Project Fi ONLY) (LVY48C)

# want all build numbers
results = re.findall(r'shamu[a-z0-9]{6}">\n\s{0,10}<td>(\d\.\d\.\d) \(([^)]+)\) \(([^)]+)\)\n\s{0,10}<td><a href="([^"]*)"', response)
results += re.findall(r'shamu[a-z0-9]{6}">\n\s{0,10}<td>(\d\.\d\.\d) \((L[^)]+)\)\n\s{0,10}<td><a href="([^"]*)"', response)

builds = list(reversed(sorted(set(results))))
max_build_number = builds[0][0]
# builds = [('a', 'b', 'c'), ('a', 'b', 'c')]
builds = [i for i in builds if i[0] == max_build_number]
# builds = filter(lambda x: x[0] == max_build_number, builds)
# pprint.pprint(builds)

## Pick build
# chosen_build = raw_input("Pick your build (ex: LVY48E):")
chosen_build = 'LVY48E' ## HARDCODED FOR TESTING TODO
chosen_set = None
print(builds)
for build in builds:
    print(build[-2], chosen_build, build[-2] == chosen_build)
    if build[-2] == chosen_build:
        chosen_set = build
        break
print(chosen_set)
assert chosen_set

build_number = chosen_set[-2]
build_link = chosen_set[-1]

# link is at -1, version is at -2

tmpdir_path = tempfile.mkdtemp()
tools_dir = os.path.join(tmpdir_path, 'nexus6')
image_dir = os.path.join(tmpdir_path, 'images')

os.mkdir(tools_dir)
os.mkdir(image_dir)

with zipfile.ZipFile('tools.zip', 'r') as tools:
    tools.extractall()
    
os.system("open {}".format(tmpdir_path))
# print("curl -o {filename} {link}".format(filename="{}/{}.tgz".format(image_dir, build_number), link=build_link))
os.system("curl -O {filename} {link}".format(filename="{}/{}.tgz".format(image_dir, build_number), link=build_link))

# shutil.rmtree(tmpdir_path)

# choose your version number


# match = re.search(r'%s-factory-([a-z0-9]{8}).(tgz)' % base_url, response)

# # https://dl.google.com/dl/android/aosp/shamu-lvy48e-factory-5e7c69da.tgz
# img_url = match.group(0)
# print(img_url)

# tempfile.mkdtemp("tmp")
# os.system("curl -O {} > ".format(img_url))
