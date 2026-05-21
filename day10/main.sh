#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input="$(< "$INPUT_TARGET")"
    part1 "$input"
    part2 "$input"
}

function part1 {
    declare -a lengths
    ${ IFS=','; read -ra lengths <<< "$1"; }

    declare -a list
    if [[ "$INPUT_TARGET" == "./input" ]]; then
        list=({0..255})
    else
        list=({0..4})
    fi

    local current_position=0
    local skip_size=0
    local list_len="${#list[@]}"

    for length in "${lengths[@]}"; do
        reverse
        current_position=$((current_position + length + skip_size))
        skip_size=$((skip_size + 1))
    done

    local a="${list[0]}"
    local b="${list[1]}"
    echo "$((a * b))"
}

function part2 {
    readarray -t lengths < <(echo -n "$1" | od -An -v -t u1 -w1 | tr -d ' ')
    lengths+=(17 31 73 47 23)

    local list=({0..255})
    local current_position=0
    local skip_size=0
    local list_len="${#list[@]}"

    local i
    for ((i=0; i<64; i++)); do
        for length in "${lengths[@]}"; do
            reverse
            current_position=$(((current_position + length + skip_size) % list_len))
            skip_size=$(((skip_size + 1) % list_len))
        done
    done

    local hash=""

    local chunk
    for ((chunk=0; chunk<16; chunk++)); do
        local byte=0

        local offset
        for ((offset=0; offset<16; offset++)); do
            local index=$((chunk * 16 + offset))
            local value="${list["$index"]}"
            byte=$((byte ^ value))
        done

        hash="$hash$(printf "%02x" "$byte")"
    done

    echo "$hash"
}

function reverse {
    local front="$current_position"
    local back="$((front + length - 1))"

    local i
    for ((i=0; i < length/2; i++)); do
        local index="$((front % list_len))"
        local other="$((back % list_len))"
        swap
        front="$((front + 1))"
        back="$((back - 1))"
    done
}

function swap {
    local temp="${list["$index"]}"
    list["$index"]="${list["$other"]}"
    list["$other"]="$temp"
}

main
