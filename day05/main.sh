#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    part1 "$input"
    part2 "$input"
}

function part1 {
    IFS=$'\n' local arr=($1)

    local index=0
    local steps=0

    while [[ index -ge 0 && index -lt "${#arr[@]}" ]]; do
        local offset=${arr[$index]}
        arr[$index]=$((offset + 1))
        index=$((offset + index))

        steps=$((steps + 1))
    done

    echo "$steps"
}

function part2 {
    IFS=$'\n' local arr=($1)

    local index=0
    local steps=0

    while [[ index -ge 0 && index -lt "${#arr[@]}" ]]; do
        local offset=${arr[$index]}
        if [[ offset -ge 3 ]]; then
            arr[$index]=$((offset - 1))
        else
            arr[$index]=$((offset + 1))
        fi

        index=$((offset + index))

        steps=$((steps + 1))
    done

    echo "$steps"
}

main
