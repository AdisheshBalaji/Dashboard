#!/bin/bash

serverURL="http://localhost:8000/announcements"
if [[ $# -le 4 ]]; then
    echo "Usage: ./makeAnAnnouncement.sh title description createdBy imgPath tag1 tag2 tag3 ....." 
    echo "Example: ./makeAnAnnouncement.sh \"Bash Script\" \"Do i really need one?\" \"Rayan\" ~/Pictures/Screenshots/Screenshot_20241209_052705.png \"Lambda\" \"Kludge\""
    exit 1
fi

createdAt=$(date +%s)

# Check if image file exists
if [[ ! -f "$4" ]]; then
    echo "Error: Image file '$4' not found!"
    exit 1
fi

# Process tags into multiple -F "tags=value" arguments
tag_args=()
for tag in "${@:5}"; do
    tag_args+=("-F" "tags=${tag}")
done
echo "Executing curl command:"
echo "curl -X POST \"${serverURL}\" -F 'title=${1}' -F 'description=${2}' -F 'createdAt=${createdAt}' -F 'createdBy=${3}' -F 'image=@${4}' ${tag_args[*]}"

# Send POST request
curl -X POST "${serverURL}" \
    -F "title=${1}" \
    -F "description=${2}" \
    -F "createdAt=${createdAt}" \
    -F "createdBy=${3}" \
    -F "image=@${4}" \
    "${tag_args[@]}"
