#!/usr/bin/env bash

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    part1 $input
    part2 $input
}

function part1 {
    echo "$FUNCNAME: TODO" 1>&2
}

function part2 {
    echo "$FUNCNAME: TODO" 1>&2
}

main
