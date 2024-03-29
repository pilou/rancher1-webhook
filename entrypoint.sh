#!/bin/sh -l

if [ $# -lt 5 ]; then
    echo "Usage: $0 <host> <projectId> <key> <image> <tag> <extraHeaders>"
    exit 1
fi

set -ex

host=$1
projectId=$2
key=$3
image=$4
tag=$5
extraHeaders=$6

http_status_code=$(curl \
  --silent \
  --output /dev/null \
  --write-out '%{http_code}' \
  --location "$host/v1-webhooks/endpoint?key=$key&projectId=$projectId" \
  --header "${extraHeaders}" \
  --header 'Content-Type: application/json' \
  --header 'Cookie: PL=rancher' \
  --data '{
    "push_data": {
        "tag": "'"$tag"'"
    },
    "repository": {
        "repo_name": "'"$image"'"
    }
}')

curl_exit_code=$?

if [ $curl_exit_code -eq 0 ]; then
    echo "curl was successful."
    if expr "${http_status_code}" : '[45]..$' 1>/dev/null; then
        echo "Webhook failed with status code ${http_status_code}."
        exit 1
    else
        echo "Webhook was triggered successfully."
        exit 0
    fi
else
    echo "curl failed with exit code $curl_exit_code."
    exit 1
fi
