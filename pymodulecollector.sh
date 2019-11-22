#!/usr/bin/env bash
# Usage:
# This script can be used to bundle up all python modules required to be installed on machine through wheel distribution.
# 1. Create `requirements.txt` file in the same directory path
# 2. Enlist all required python modules name
# Example:
        # dnspython
        # netaddr
        # ansible==2.8.0
        # hvac
        # pyOpenSSL
        # ansible-modules-hashivault
        # pycrypto
        # cryptography
# 3. Execute this script
# Once execution is succeded, you will see a tar file under same directory path. This tar can be exported to install python modules on machine.
# command to install packages from local source
# 		pip install --no-index --find-links=file:/path/to/pymodules -r /path/to/requirements.txt

which pip > /dev/null
if [ $? -ne 0 ]; then
  echo "--> installing pip ..."
  yum install python-pip -y
fi

pip show wheel > /dev/null
if [ $? -ne 0 ]; then
    echo "--> installing pip wheel ..."
    pip install wheel
fi

if [ -d $(pwd)/pymodules ]; then
    rm -rf $(pwd)/pymodules
    mkdir -p $(pwd)/pymodules
else
    mkdir -p $(pwd)/pymodules
fi

pip wheel --wheel-dir=$(pwd)/pymodules -r $(pwd)/requirements.txt
if [ $? -eq 0 ]; then
  tar -cvzf $(pwd)/pymodules.tar.gz $(pwd)/pymodules
fi
