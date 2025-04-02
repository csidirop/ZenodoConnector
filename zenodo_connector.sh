#!/bin/bash

# Zenodo Connector
# 
# This script is uses the Zenodo API to create, upload, discard and publish records.
# Usage:  ./zenodo_connector.sh --mode=[init|upload|discard|publish] --record_id=[id] --file=[file] --access_token=[path/to/token|token]
# Example:
#   ./zenodo_connector.sh --mode=init --access_token=[path/to/token|123456token]
#   ./zenodo_connector.sh --mode=upload --record_id=1234 --file=path/to/example.txt --access_token=[path/to/token|123456token]
#   ./zenodo_connector.sh --mode=discard --record_id=1234 --access_token=[path/to/token|123456token]
#   ./zenodo_connector.sh --mode=publish --record_id=1234 --access_token=[path/to/token|123456token]

set -euo pipefail # exit on: error, undefined variable, pipefail

# Set default values:
instance=https://zenodo.org
access_token=""
mode=""
record_id=""

# Parse arguments:
for arg in "$@"; do
    case $arg in
    -m=* | --mode=*)
        mode="${arg#*=}"
        shift
        ;;
    -r=* | --record_id* | --id=*)
        record_id="${arg#*=}"
        shift
        ;;
    -f=* | --file=*)
        file="${arg#*=}"
        shift
        ;;
    -t=* | --access_token=* | --token=*)
        access_token="${arg#*=}"
        shift
        ;;
    --sandbox)
        instance=https://sandbox.zenodo.org
        echo " -- Using sandbox instance! --"
        shift
        ;;
    *)
        if [ -z "$file" ]; then
            file="$arg"
        fi
    esac
done

# Check if curl is installed:
if ! command -v curl &>/dev/null; then
    echo "Curl is not installed. Please install Curl."
    exit 1
fi

# Check access token:
if [ -n "$access_token" ]; then # check if access token is not empty
    if [ -f "$access_token" ]; then # check if access token is a readable file
        access_token=$(cat $access_token)
        echo "Read access token from given file!"
    else
        echo "Access token provided!"
    fi
elif [ -f "token" ]; then # try to read access token from static file called 'token'
    access_token=$(cat token)
    echo "Read static access token!"
else
    echo "No access token provided!"
    exit 1
fi

# Main logic:
if [ "$mode" == "init" ]; then
    echo -e "Init ..."
    curl -sS -X POST $instance/api/deposit/depositions \
        -H "Authorization: Bearer "$access_token \
        -H "Content-Type: application/json" \
        -d '{}' > response.json
    # Check if response contains error:
    if [[ $(jq -r '.status' response.json) == 403 ]]; then
        echo "Zenodo Error: $(jq -r '.message' response.json)"
        exit 1
    fi
    record_id=$(jq -r '.record_id' response.json)
    mv response.json response_$record_id.json
    echo "Created record ID: $record_id"
    echo -e "-> $instance/uploads/$record_id \n"
elif [ "$mode" == "discard" ]; then 
    echo -e "\nDiscarding..."
    curl -sS -X POST $instance/api/deposit/depositions/$record_id/actions/discard \
        -H "Authorization: Bearer "$access_token \
        -H "Content-Type: application/json" \
        -d '{}'
    echo -e "\nDiscarded record ID: $record_id \n"
elif [ "$mode" == "upload" ]; then 
    echo -e "\nUploading file..."
    filename=$(basename $file)
    bucket_url=$(curl $instance/api/deposit/depositions/$record_id?access_token=$access_token | jq -r '.links.bucket')
    curl --progress-bar "$bucket_url/$filename" \
     --upload-file "$file" \
     -H "Authorization: Bearer $access_token"
    echo -e "\nUploaded file: $file \n"
elif [ "$mode" == "publish" ]; then 
    echo -e "\nPublishing..."
    curl -sS -X POST $instance/api/deposit/depositions/$record_id/actions/publish \
        -H "Authorization: Bearer "$access_token \
        -H "Content-Type: application/json" \
        -d '{}'
    echo -e "\nPublished record ID: $record_id \n"
else
    echo "Invalid mode. Use '--mode=init', '--mode=upload', '--mode=discard' or '--mode=publish'."
    exit 1
fi
