#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    part1 "$input"
    part2 "$input"
}

function part1 {
    local input=$1

    local total=0
    while read -r line; do
        if [[ -z $(echo "$line" | tr " " "\n" | sort | uniq -d) ]]; then
            total=$((total+1))
        fi
    done <<< "$input"

    echo $total
}

function part2 {
    local input=$1

    local total=0
    while read -r line; do
        if [[ -z $(echo $line | tr " " "\n" | sort_each_line | sort | uniq -d) ]]; then
            total=$((total+1))
        fi
    done <<< "$input"

    echo $total
}

function sort_each_line {
    while read -r line; do
        echo "$(echo $line | fold -w1 | sort | tr -d "\n")"
    done
}

main
