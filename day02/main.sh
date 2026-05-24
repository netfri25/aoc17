#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    time part1 "$input"
    echo
    time part2 "$input"
}

function part1 {
    local input=$1

    local total=0
    while read -r -a items; do
        local l="$(minimum "${items[@]}")"
        local h="$(maximum "${items[@]}")"

        local diff=$((h - l))
        local total=$((total + diff))
    done <<< "$input"

    echo $total
}

function part2 {
    local input=$1

    local total=0
    while read -r -a items; do
        for numer in "${items[@]}"; do
            for denom in "${items[@]}"; do
                if [[ "$numer" -eq "$denom" ]]; then
                    continue
                fi

                if [[ "$((numer % denom))" -eq 0 ]]; then
                    total=$((total + numer / denom))
                    break 2
                fi
            done
        done
    done <<< "$input"

    echo $total
}

function minimum {
    local arr=("$@")
    local result="${arr[0]}"

    for value in "${arr[@]}"; do
        if [[ "$value" -lt "$result" ]]; then
            result="$value"
        fi
    done

    echo "$result"
}

function maximum {
    local arr=("$@")
    local result="${arr[0]}"

    for value in "${arr[@]}"; do
        if [[ "$value" -gt "$result" ]]; then
            result="$value"
        fi
    done

    echo "$result"
}


main
