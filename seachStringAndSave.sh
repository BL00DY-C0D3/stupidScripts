#!/bin/bash

# Usage: ./find_string_with_strings.sh "search_string" [directory]
# Example: ./find_string_with_strings.sh "mysecret" /var/log

SEARCH_STRING="$1"
SEARCH_DIR="${2:-.}"

rm ./searchResults/.* > /dev/null 2>&1
mkdir ./searchResults/ > /dev/null 2>&1


if [ -z "$SEARCH_STRING" ]; then
  echo "Usage: $0 \"search_string\" [directory]"
  exit 1
fi

find "$SEARCH_DIR" -type f -print0 | while IFS= read -r -d '' file; do
  # Use strings to extract printable strings and grep for the search string
  result=$(strings "$file" | grep  "$SEARCH_STRING")
  if ! [[ "$result" == "" ]]; then
  cleanFileName=$(echo $file | sed -e "s/\//-/g" )
  echo $cleanFileName
  echo "$result" > "./searchResults/$cleanFileName.txt"
  fi
done
