#!/bin/bash

# instance=https://zenodo.org
instance=https://sandbox.zenodo.org
# accessToken= #live
accessToken= #sandbox

# mode=init
# mode=upload
# mode=discard
# mode=publish

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
    *)
        if [ -z "$file" ]; then
            file="$arg"
        fi
    esac
done

# Main logic:
if [ "$mode" == "init" ]; then
    echo "Init ..."
    curl -X POST $instance/api/deposit/depositions \
        -H "Authorization: Bearer "$accessToken \
        -H "Content-Type: application/json" \
        -d '{}' > response.json

    record_id=$(jq -r '.record_id' response.json)
    mv response.json response_$record_id.json
    echo "Created record ID: $record_id"
    echo -e "-> $instance/uploads/$record_id \n"
elif [ "$mode" == "discard" ]; then 
    echo "Discarding..."
    curl -X POST $instance/api/deposit/depositions/$record_id/actions/discard \
        -H "Authorization: Bearer "$accessToken \
        -H "Content-Type: application/json" \
        -d '{}'
    echo -e "Discarded record ID: $record_id \n"
elif [ "$mode" == "upload" ]; then 
    echo "Uploading file..."
    filename=$(basename $file)
    bucket_url=$(curl $instance/api/deposit/depositions/$record_id?access_token=$accessToken | jq -r '.links.bucket')
    curl --progress-bar --upload-file $file $bucket_url/$filename?access_token=$accessToken
    echo -e "Uploaded file: $file \n"
elif [ "$mode" == "publish" ]; then 
    echo "Publishing..."
    curl -X POST $instance/api/deposit/depositions/$record_id/actions/publish \
        -H "Authorization: Bearer "$accessToken \
        -H "Content-Type: application/json" \
        -d '{}'
    echo -e "Published record ID: $record_id \n"
else
    echo "Invalid mode. Use '--mode=init', '--mode=upload', '--mode=discard' or '--mode=publish'."
    exit 1
fi
