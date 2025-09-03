#!/bin/bash
# This downloads multiple versions of an oculus game
# ./bulkDownload.sh ./file.codes

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

function help() {
    echo -e "${BOLD}bulkDownload.sh - Download multiple versions of an Oculus game using codes.${RESET}"
    echo ""
    echo -e "${CYAN}Usage:${RESET}"
    echo -e "  bash ./bulkDownload.sh <Path to code file> [--ignore-done] [--verify-done] [--verbose]"
    echo ""
    echo -e "${CYAN}Arguments:${RESET}"
    echo -e "  <Path to code file>   File containing the codes to download."
    echo -e "  --ignore-done         Download/verify all codes, ignoring the .downloadDone log."
    echo -e "  --verify-done         Only download/verify codes already logged in .downloadDone."
    echo -e "  --verbose             Print extra output from Oculus Downgrader as it runs."
    echo ""
    echo -e "${CYAN}Description:${RESET}"
    echo -e "  The script reads codes from the specified file and downloads each using Oculus Downgrader."
    echo -e "  Codes that have already been downloaded are tracked in .downloadDone."
    echo -e "  The script can filter codes based on download status using flags."
    echo ""
    echo -e "${CYAN}Examples:${RESET}"
    echo -e "  bash ./bulkDownload.sh ./file.codes"
    echo -e "  bash ./bulkDownload.sh ./file.codes --ignore-done"
    echo -e "  bash ./bulkDownload.sh ./file.codes --verify-done --verbose"
}

function postInstall() {
    echo -e "${GREEN}DONEEEE${RESET}"
}

function download(){
    for code in "$@"
    do
        echo -e "${BLUE}Starting Download: ${YELLOW}$code${RESET}"
        if [[ "$flag__verbose" -eq 1 ]]
        then
            ./Oculus\ Downgrader $code --password "$password" 2>&1 | tee .bulky.log
        else
            ./Oculus\ Downgrader $code --password "$password" >> .bulky.log 2>&1
        fi
        saveCodeAsDone $code
        sleep 10
    done
}

function saveCodeAsDone(){
    if [[ "$(grep -c "$1" ./downloadDone)" -eq "0" ]]
    then
        echo -e "${GREEN}Download done!. Saving to log${RESET}"
        echo "$@" >> ./.downloadDone
    else
        echo -e "${YELLOW}Download already logged${RESET}"
    fi
}

function stringInArrayCheck(){
    local string="$1"
    shift
    for object in "$@"
    do
        if [[ "$object" == "$string" ]]
        then
            echo 1
            return
        fi
    done
    echo 0
    return
}

function checkArguments(){
    if [[ "$#" -lt "1" ]]
    then
        echo -e "${RED}Missing arguments! :333${RESET}"
        echo -e "${YELLOW}bash ./bulkDownload.sh <Path to code file> <arguments>${RESET}"
        help
        exit 3
    fi

    if [[ ! -f "$1" ]]
    then
        echo -e "${RED}File not found or argument is not a file${RESET}"
        echo -e "${YELLOW}$1${RESET}"
        help
        exit 33
    fi

    for flag in "$@"
    do
        case "$flag" in
        "--ignore-done")
            flag__ignore_done=1
            ;;
        "--verify-done")
            flag__verify_done=1
            ;;
        "--verbose")
            flag__verbose=1
            ;;
        *)
            flag__none=1
            ;;
        esac
    done

    if [[ "$flag__ignore_done" -eq "1" ]] &&  [[ "$flag__verify_done" -eq "1" ]]
    then
        echo -e "${RED}Wrongly used arguments! :3${RESET}"
        help
        exit 333
    fi
}

checkArguments "$@"
password="$(cat ./.password)"

rm -f .bulky.log
touch .bulky.log
touch ./.downloadDone

readarray -t codes < <(cat $1)
readarray -t doneCodes < <(cat ./.downloadDone)

if [[ "$flag__ignore_done" -eq "1" ]]
then
    echo -e "${MAGENTA}Ignoring .downloadDone-file and verifying/downloading all codes${RESET}"
    download "${codes[@]}"

elif [[ "$flag__verify_done" -eq "1" ]]
then
    echo -e "${MAGENTA}Verifying/Downloading only already done Codes${RESET}"
    download "${doneCodes[@]}"
else
    echo -e "${MAGENTA}Downloading unfinished Codes${RESET}"
    filtered=()

    for code in "${codes[@]}"
    do
        compareString=$(stringInArrayCheck "$code" "${doneCodes[@]}")
        if [[ "$compareString" -eq "0" ]]; then
            filtered+=("$code")
        fi
    done

    if [[ "${#filtered[@]}" -eq "0" ]]; then
        echo -e "${YELLOW}No downloads found in unfinished Codes${RESET}"
        exit 1337
    fi
    download "${filtered[@]}"
fi
