#!/bin/bash

# Abort script at first error
set -o errexit

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

BOX_NAME="lostsnow/centos7"
BOX_PROVIDER="virtualbox"
ATLAS_API_URL=https://atlas.hashicorp.com/api/v1/box

# Flag paser
usage() {
    case "$1" in
        create | upload | release )
            echo -e "Usage: $( basename $0 ) $1 [arg...]"
            echo
            echo -e "Options:"
            echo -e "  -v <version>          box version"

            if [ $1 == "create" ] || [ $1 == "upload" ]; then
                echo -e "  -p <provider>         box provider, default: virtualbox"
            fi

            echo -e "  -n <name>             box name, default: lostsnow/centos7"

            if [ $1 == "upload" ]; then
                echo -e "  -f <file>             box file"
            fi

            echo
            exit 1
            ;;
        * )
            echo -e "Usage: $( basename $0 ) <command> [arg...]"
            echo
            echo -e "Commands:"
            echo -e "  help <command>   print command help message"
            echo -e "  create           create box version and provider"
            echo -e "  upload           upload box file"
            echo -e "  release          release box"
            echo
            echo -e "Options:"
            echo -e "  --help           give this help list"
            echo
            exit 1
            ;;
    esac
}

catch_all () {
    [[ ! -z "$1" ]] && warning "$1: command not found"
    exit 1
}

function_exists () {
    type $1 2> /dev/null | grep -q 'function'
}

cecho () {
    local MSG=$1
    local COLOR=$2
    local PREFIX=
    local SUFFIX="\e[0m"
    case "$COLOR" in
        red)
            PREFIX="\e[0;31m"
            ;;
        green)
            PREFIX="\e[0;32m"
            ;;
        brown)
            PREFIX="\e[0;33m"
            ;;
        purple)
            PREFIX="\e[0;35m"
            ;;
        *)
            PREFIX=""
            SUFFIX=""
        ;;
    esac
    MSG="$PREFIX$MSG$SUFFIX"
    set builtin
    echo -ne "$MSG"
}
ncecho () {
    cecho "$@"
    echo
}

now () {
    cecho `date "+%Y/%m/%d:%H:%M:%S"` $1;
}

fatal () {
    ncecho "[FATAL] $1" "red" && exit 1
}
error () {
    ncecho "[ERROR] $1" red
}
success () {
    ncecho "[SUCCESS] $1" green
}
info () {
    ncecho "[INFO] $1" purple
}

json_val() {
    temp=`echo $1 | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2`
    echo ${temp##*|}
}

# Checks for an Atlas API Error
check_error() {
    if  [[ $1 == '{"errors":'* ]] ;
    then
        error $1
        exit 1
    fi
}

run() {
    if function_exists _$(basename $0) ; then
        CMD=$(basename $0)
    elif function_exists _$1 ; then
        CMD=$1
        shift
    else
        catch_all $@
    fi

    while true; do
        case "$1" in
            -v )
                BOX_VERSION="$2"; shift 2 ;;
            -p )
                BOX_PROVIDER="$2"; shift 2 ;;
            -b )
                BOX_NAME="$2"; shift 2 ;;
            -f )
                BOX_FILE="$2"; shift 2 ;;
            -- )
                shift; break ;;
            * )
                break ;;
        esac
    done

    if [ -z "${ATLAS_TOKEN}" ]; then
        fatal "Atlas token required, Please set by environment variable: ATLAS_TOKEN."
    fi

    if [ -z "${BOX_VERSION}" ]; then
        error "Box version required!"
        usage $CMD
    fi

    if [ -z "${BOX_NAME}" ]; then
        error "Box name required!"
        usage $CMD
    fi

    _$CMD
}

_create() {
    if [ -z "${BOX_PROVIDER}" ]; then
        error "Box provider required!"
        usage create
    fi

    info "Create version"
    response=$(curl -s ${ATLAS_API_URL}/${BOX_NAME}/versions -X POST -d version[version]=${BOX_VERSION} -d access_token=${ATLAS_TOKEN})
    check_error $response
    echo $response

    info "Create provider"
    response=$(curl -s ${ATLAS_API_URL}/${BOX_NAME}/version/${BOX_VERSION}/providers -X POST -d provider[name]=${BOX_PROVIDER} -d access_token=${ATLAS_TOKEN})
    check_error $response
    echo $response
    success "Create success"
}

_upload() {
    if [ -z "${BOX_PROVIDER}" ]; then
        error "Box provider required!"
        usage upload
    fi

    if [ -z "${BOX_FILE}" ]; then
        error "Box file required!"
        usage upload
    fi

    if [ ! -f ${BOX_FILE} ]; then
        error "Box file ${BOX_FILE} not found!"
        usage upload
    fi

    case "$(uname -s)" in
        Darwin | Linux )
            null_device=/dev/null ;;
        CYGWIN* | MINGW* | MSYS* )
            null_device=NUL ;;
        *)
            fatal "OS not support: "$(uname -s)
        ;;
    esac

    info "Get upload token"
    RESPONSE=$(curl -s ${ATLAS_API_URL}/${BOX_NAME}/version/${BOX_VERSION}/provider/${BOX_PROVIDER}/upload?access_token=${ATLAS_TOKEN})
    check_error ${RESPONSE}
    echo ${RESPONSE}
    TOKEN=$(json_val ${RESPONSE}, "token")

    info "Using token: "$TOKEN
    info "Start upload"
    curl -X PUT --upload-file ${BOX_FILE} https://binstore.hashicorp.com/${TOKEN} --progress-bar -o ${null_device}
    result=$?
    if [ result != 0 ]; then
        fatal "Upload error"
    fi

    info "Upload success"
}

_release() {
    info "Release box"
    response=$(curl -s ${ATLAS_API_URL}/${BOX_NAME}/version/${BOX_VERSION}/release -X PUT -d access_token=${ATLAS_TOKEN})
    check_error $response
    echo $response
    success "Release success"
}

case "$1" in
    -h | --help | help ) usage $2 ;;
    create | upload | release ) run "$@" ;;
    * ) error "Invalid command -- $1"; usage ;;
esac
