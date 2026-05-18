#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    part1 $input
    part2 $input
}

function part1 {
    solve_with_offset $1 1
}

function part2 {
    solve_with_offset $1 $((${#1} / 2))
}

function solve_with_offset {
    local input=$1
    local offset=$2

    local length=${#input}

    local total=0

    for ((i=0; i<length; i++)); do
        c1=${input:i:1}
        c2=${input:(i+offset)%length:1}
        if [[ $c1 == $c2 ]]; then
            total=$((total + c1))
        fi
    done

    echo $total
}

main
