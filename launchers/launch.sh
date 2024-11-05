#!/bin/bash

URL="http://localhost:8001"

if [ $# -eq 0 ]; then
    echo "Invalid number of input parameters specified"
    return 1
else
    if ! [ -d $1 ]; then
        echo "Folder $1 does not exist"
        return 2
    fi
fi

count="$(docker ps | grep bdlabs | wc -l | tr -d " \t\r\n")"
if [ $count -ge 1 ]; then
    echo -e "\e[1;31mFound a bigdatalab container already running... Either stop it with \"docker kill bdlabs\" or connect to it at $URL...\e[0m"
    return 1
fi

echo -e "\e[1;31mLaunching the service... open this URL on the browser $URL\e[0m"
echo -e "\e[1;31mYou can stop the container either with CTRL+C (CMD+C on mac) or with \"docker kill bdlabs\"\e[0m"
echo -e "\e[1;31mYou can check if the container is still running with \"docker ps -a\"\e[0m"
docker run -e BIGDATA_LISTEN_PORT=8001 -it --rm -p 8001:8001 -v $1:/vscode/workspace --name bdlabs bigdatalabs