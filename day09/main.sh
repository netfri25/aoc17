#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    time solve "$input"
}

function solve {
    local input="$1"
    local index=0
    local score=0
    local group_depth=0
    local trash_count=0

    consume_char

    echo "$score"
    echo "$trash_count"
}

function get_char {
    echo "${input:index:1}"
}

function read_garbage {
    while true; do
        case "${input:index:1}" in
            '>') break ;;
            '!') index=$((index + 1)) ;;
            *) trash_count=$((trash_count + 1)) ;;
        esac

        index=$((index + 1))
    done
}

function read_group {
    group_depth=$((group_depth + 1))

    while consume_char; do
        :
    done

    score=$((score + group_depth))
    group_depth=$((group_depth - 1))
}

function consume_char {
    local char="${input:index:1}"
    index=$((index + 1))

    case "$char" in
        '{') read_group ;;
        '<') read_garbage ;;
        '}') return 1 ;;
    esac
}

main
