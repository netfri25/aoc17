#!/usr/bin/env bash

INPUT_TARGET=${1:-./input}

function main {
    local input=$(< "$INPUT_TARGET")
    time part1 <<< "$input"
    echo
    time part2 <<< "$input"
}

function part1 {
    local line gen_a gen_b mask total equals
    ((total=0))

    read -r line
    gen_a="${line/Generator A starts with /}"

    read -r line
    gen_b="${line/Generator B starts with /}"

    for ((i=0; i<40000000; i++)); do
        ((
            gen_a = (gen_a * 16807) % 0x7fffffff,
            gen_b = (gen_b * 48271) % 0x7fffffff,
            total += (gen_a & 0xffff) == (gen_b & 0xffff)
        ))
    done

    echo "$total"
}

function part2 {
    local line gen_a gen_b mask total equals
    ((total=0))

    read -r line
    gen_a="${line/Generator A starts with /}"

    read -r line
    gen_b="${line/Generator B starts with /}"

    for ((i=0; i<5000000; i++)); do
        while (( (gen_a = (gen_a * 16807) % 0x7fffffff) & 3 )); do :; done
        while (( (gen_b = (gen_b * 48271) % 0x7fffffff) & 7 )); do :; done
        (( total += (gen_a & 0xffff) == (gen_b & 0xffff) ))
    done

    echo "$total"
}

main
