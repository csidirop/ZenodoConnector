#!/bin/bash

# instance=https://zenodo.org
instance=https://sandbox.zenodo.org
# accessToken= #live
accessToken= #sandbox

record_id=184653

# mode=init
# mode=upload
# mode=discard
# mode=publish

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
    file=testfile
    filename=$(basename $file)
    bucket_url=$(curl $instance/api/deposit/depositions/$record_id?access_token=$accessToken | jq -r '.links.bucket')
    curl --upload-file $file $bucket_url/$filename?access_token=$accessToken
    echo -e "Uploaded file: $file \n"
elif [ "$mode" == "publish" ]; then 
    echo "Publishing..."
    curl -X POST $instance/api/deposit/depositions/$record_id/actions/publish \
        -H "Authorization: Bearer "$accessToken \
        -H "Content-Type: application/json" \
        -d '{}'
    echo -e "Published record ID: $record_id \n"
else
    echo "..."
fi
