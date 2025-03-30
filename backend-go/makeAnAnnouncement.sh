#!/bin/bash

serverURL="http://localhost:8000/announcements"

# Validate minimum required arguments before processing options
if [[ $# -lt 4 ]]; then
    echo "Usage: $0 title description createdBy imgPath [-t tag1 -t tag2] [-c category1 -c category2]"
    echo "Example: $0 \"Bash Script\" \"Do I really need one?\" \"Rayan\" ~/Pictures/Screenshot.png -t Lambda -t Kludge -c Announcements"
    exit 1
fi

title="$1"
description="$2"
createdBy="$3"
imgPath="$4"
createdAt=$(date +%s)

# Validate image file existence
if [[ ! -f "$imgPath" ]]; then
    echo "Error: Image file '$imgPath' not found!"
    exit 1
fi

# Shift past positional arguments to process options
shift 4  

tag_args=()
category_args=()

# Process optional -t (tags) and -c (categories) options
while getopts "t:c:" opt; do
    case "$opt" in
        t) tag_args+=("-F" "tags=${OPTARG}") ;;
        c) category_args+=("-F" "category=${OPTARG}") ;;
        *) echo "Usage: $0 title description createdBy imgPath [-t tag1 -t tag2] [-c category1 -c category2]" >&2; exit 1 ;;
    esac
done

# Debugging output
echo "Executing curl command:"
echo "curl -X POST \"${serverURL}\" -F 'title=${title}' -F 'description=${description}' -F 'createdAt=${createdAt}' -F 'createdBy=${createdBy}' -F 'image=@${imgPath}' ${tag_args[@]} ${category_args[@]}"

# Send POST request
curl -X POST "${serverURL}" \
    -F "title=${title}" \
    -F "description=${description}" \
    -F "createdAt=${createdAt}" \
    -F "createdBy=${createdBy}" \
    -F "image=@${imgPath}" \
    "${tag_args[@]}" \
    "${category_args[@]}"
