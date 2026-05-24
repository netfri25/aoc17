#!/usr/bin/env bash

INPUT_TARGET=${1:-./input}

declare -a firewall

function main {
    parse < "$INPUT_TARGET"
    time part1
    echo
    time part2
}

function parse {
    while IFS=": " read -r layer range; do
        (( firewall[layer] = range ))
    done
}

function part1 {
    local result range
    (( result = 0 ))

    for layer in "${!firewall[@]}"; do
        (( range =  firewall[layer] ))
        if is_caught 0 "$layer" "$range"; then
            (( result += layer*range ))
        fi
    done

    echo "$result"
}

function part2 {
    local offset=0

    while is_trip_non_safe "$offset"; do
        (( offset += 1 ))
    done

    echo "$offset"
}

function is_trip_non_safe {
    local range
    local offset="$1"

    for layer in "${!firewall[@]}"; do
        (( range = firewall[layer] ))
        if is_caught "$offset" "$layer" "$range"; then
            return 0
        fi
    done

    return 1
}

function is_caught {
    local offset="$1"
    local layer="$2"
    local range="$3"

    (( (offset + layer) % (2*range - 2) == 0 ))
}

main
