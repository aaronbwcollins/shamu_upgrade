import pprint

import re
import os
import shutil
import tempfile
import zipfile
import commands
import hashlib


def generate_file_md5(filepath):
    hsh = hashlib.md5()
    with open(filepath) as f:
        for chunk in iter(lambda: f.read(10240), ""):
            hsh.update(chunk)
    return hsh.hexdigest()

#### UNCOMMENT THESE LINES TODO ####

# os.system("open https://developers.google.com/android/nexus/images?hl=en#shamu")
# build_number = raw_input("Enter your build number: ")
build_number = 'LVY48E'

# base_url = "https://dl.google.com/dl/android/aosp/shamu-{}".format(build_number.lower())

response = commands.getoutput('curl https://developers.google.com/android/nexus/images?hl=en#shamu 2> /dev/null')
# print(response)

# https://dl.google.com/dl/android/aosp/shamu-lvy48e-factory-5e7c69da.tgz
# 5.1.1 (For Project Fi ONLY) (LVY48C)

# want all build numbers
results = re.findall(r'shamu[a-z0-9]{6}">\n\s{0,10}<td>(\d\.\d\.\d) \(([^)]+)\) \(([^)]+)\)\n\s{0,10}<td><a href="([^"]*)">Link</a>\n\s{0,10}<td>([a-z0-9]{32})', response)
results += re.findall(r'shamu[a-z0-9]{6}">\n\s{0,10}<td>(\d\.\d\.\d) \((L[^)]+)\)\n\s{0,10}<td><a href="([^"]*)">Link</a>\n\s{0,10}<td>([a-z0-9]{32})', response)

print(results)
# TODO
# Add md5 sum to results and run against downloaded file


builds = list(reversed(sorted(set(results))))
max_build_number = builds[0][0]
print (builds)
# builds = [('a', 'b', 'c'), ('a', 'b', 'c')]
builds = [i for i in builds if i[0] == max_build_number]
# builds = filter(lambda x: x[0] == max_build_number, builds)
# pprint.pprint(builds)

# build_number = 'LVY48E' ## HARDCODED FOR TESTING TODO
chosen_set = None
print(builds)
for build in builds:
    print(build[-3], build_number, build[-3] == build_number)
    if build[-3] == build_number:
        chosen_set = build
        break
print(chosen_set)
assert chosen_set

build_number = chosen_set[-3]
build_link = chosen_set[-2]
# Getting Traceback errors
build_md5 = chosen_set[-1]
# link is at -1, version is at -2
print (build_number)
print (build_link)
print (build_md5)


tmpdir_path = tempfile.mkdtemp()
tools_dir = os.path.join(tmpdir_path, 'nexus6')
image_dir = os.path.join(tmpdir_path, 'images')

os.mkdir(tools_dir)
os.mkdir(image_dir)

with zipfile.ZipFile('tools.zip', 'r') as tools:
    tools.extractall()

os.system("open {}".format(tmpdir_path))
# print("curl -o {filename} {link}".format(filename="{}/{}.tgz".format(image_dir, build_number), link=build_link))
filepath = "{}/{}.tgz".format(image_dir, build_number)
os.system("curl -o {filename} {link}".format(filename=filepath, link=build_link))

md5_returned = generate_file_md5(filepath)

# check file was downloaded properly
# def generate_file_md5(rootdir, filename, blocksize=2**20):
# 	m = hashlib.md5()
# 	with open(os.path.join(image_dir, filename) , 'rb') as file_to_check:
# 		while True:
# 			data = file_to_check.read(blocksize)
# 			if not data:
# 				break
# 			m.update(data)
# 	md5_returned = m.hexdigest()

if build_md5 == md5_returned:
    print("md5 verifed")
else:
    print("md5 verification failed")
    exit()

tool_path = '~/Library/Android/sdk/platform-tools/'

def tool_check(tool_path):
    if os.path.exists(tool_path) == "False":
    ## copy adb and fastboot tools to /usr/local/bin
    else:
        ## Symlink adb and fastboot to /usr/local/bin
        subprocess.call('ln', '-s', '~/Library/Android/sdk/platform-tools/adb', '/usr/local/bin/adb')
        subprocess.call('ln', '-s', '~/Library/Android/sdk/platform-tools/fastboot', '/usr/local/bin/adb')
    ## test that adb and fastboot are functioning properly
    try:
       devnull = open(os.devnull)
       subprocess.Popen(adb, stdout=devnull, stderr=devnull).communicate()
    except OSError as e:
        if e.errno == os.errno.ENOENT:
            return OSError
    try:
        subprocess.Popen(fastboot, stdout=devnull, stderr=devnull).communicate()
    except OSError as e:
        if e.errno == os.errno.ENOENT:
            return OSError

## Check to see if phone is connected
def connect_check():
    serial = subprocess.Popen(('adb', 'devices'), stdout=subprocess.PIPE)
    serial_output1 = subprocess.check_serial_ouput1(('cut', '-c1-10'), stdin=serial.stdout, stdout=subprocess.PIPE)
    serial_output2 = subprocess.check_serial_ouput2(('sed', '1d'), stdin=serial_output1)
    serial.wait()

def boot_verify():
    connect_check
    while serial == '':
        os.system("sleep 1")
        connect_check

## TODO Enter Bootloader
## Flash Radio
## Reboot Phone
## boot_verify
os.system("sleep 5")
## BOOTLOADER_RECOVERY_BOOT_SYSTEM
## Reboot Phone
## Root Device

# shutil.rmtree(tmpdir_path)

# choose your version number


# match = re.search(r'%s-factory-([a-z0-9]{8}).(tgz)' % base_url, response)

# # https://dl.google.com/dl/android/aosp/shamu-lvy48e-factory-5e7c69da.tgz
# img_url = match.group(0)
# print(img_url)

# tempfile.mkdtemp("tmp")
# os.system("curl -O {} > ".format(img_url))
