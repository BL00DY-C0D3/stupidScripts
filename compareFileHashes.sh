#!/bin/bash
# :3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3
# :3                          _                     _ _                           _       :3
# :3 _ __ ___   __ _ _ __ ___| |__  _ __ ___   __ _| | | _____      __  _ __ ___ (_) __ _ :3
# :3| '_ ` _ \ / _` | '__/ __| '_ \| '_ ` _ \ / _` | | |/ _ \ \ /\ / / | '_ ` _ \| |/ _` |:3
# :3| | | | | | (_| | |  \__ \ | | | | | | | | (_| | | | (_) \ V  V /  | | | | | | | (_| |:3
# :3|_| |_| |_|\__,_|_|  |___/_| |_|_| |_| |_|\__,_|_|_|\___/ \_/\_/___|_| |_| |_|_|\__,_|:3
# :3                                                               |_____|                :3
# :3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3
#          ____________________________________________ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
#  __     / Description: compares file in 2 dirs and gives out files with different 
# /  \    | hashes and files that only exists in one of the dirs
# |  |    | Usage: ./compare_dirs.sh DIR1 DIR2
# @  @    |
# || || <-| Name       : Mia Hentschel
# || ||   | Org        : EVRCE
# |\_/|   | Date       : 10-04-25 DD-MM-YY
# \___/   | Version    : 0.1
#         \____________________________________________ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# :3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3:3


DIR1="$1"
DIR2="$2"

if [[ -z "$DIR1" || -z "$DIR2" ]]; then
  echo "Usage: $0 DIR1 DIR2"
  exit 1
fi

# Get lists of files (filenames only) in each directory
FILES1=$(find "$DIR1" -type f -printf "%f\n" | sort)
FILES2=$(find "$DIR2" -type f -printf "%f\n" | sort)

# Files that exist in both directories
COMMON=$(comm -12 <(echo "$FILES1") <(echo "$FILES2"))

# List files with different hashes
DIFF_HASH=()
for f in $COMMON; do
  HASH1=$(sha256sum "$DIR1/$f" | awk '{print $1}')
  HASH2=$(sha256sum "$DIR2/$f" | awk '{print $1}')
  if [[ "$HASH1" != "$HASH2" ]]; then
    DIFF_HASH+=("$f")
  fi
done

# List files only in DIR1
ONLY1=$(comm -23 <(echo "$FILES1") <(echo "$FILES2"))

# List files only in DIR2
ONLY2=$(comm -13 <(echo "$FILES1") <(echo "$FILES2"))

echo "Files with different hash:"
for f in "${DIFF_HASH[@]}"; do
  echo "$f"
done

echo
echo "Files only in $DIR1:"
for f in $ONLY1; do
  echo "$f"
done

echo
echo "Files only in $DIR2:"
for f in $ONLY2; do
  echo "$f"
done
