#!/usr/bin/env bash

INPUT_TARGET=${1:-./input}

function main {
    local input=$(< "$INPUT_TARGET")
    time part1 "$input"
    echo
    time part2 "$input"
}

function part1 {
    local step_size="$1"
    local index=0

    declare -a state
    state=(0)

    for value in $(seq 2017); do
        (( index = 1 + (index + step_size) % value ))
        state=("${state[@]:0:$index}" $value "${state[@]:$index}")
    done

    echo "${state[$((index + 1))]}"
}

function part2 {
    local step_size="$1"
    local index=0
    local after_zero=0

    for value in $(seq 50000000); do
        if (( (index = 1 + (index + step_size) % value) == 1 )); then
            (( after_zero = value ))
        fi
    done

    echo "$after_zero"
}

main
