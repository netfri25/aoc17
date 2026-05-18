#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    part1 $input
    part2 $input
}

function part1 {
    local n=$1
    local r=$(find_ring_level $n)
    local max=$(( (2*r + 1) * (2*r + 1) ))

    local closest=$(abs "$((n - (max - r)))")
    for k in $(seq 1 3); do
        local mid=$((max - r - 2*r*k))
        local diff=$(abs "$((n - mid))")
        if [[ $diff -lt $closest ]]; then
            closest=$diff
        fi
    done

    local total_distance=$((closest + r))
    echo "$total_distance"
}

function part2 {
    local n=$1

    declare -A spiral
    local row=0
    local col=0

    spiral["$row,$col"]=1

    function current_sum {
        local total=0

        for i in $(seq $((row-1)) $((row+1))); do
            for j in $(seq $((col-1)) $((col+1))); do
                total=$((total + "${spiral["$i,$j"]:-0}"))
            done
        done

        echo $total
    }

    local result=0
    local step
    for ((step=1; 0==0; step=step+2)); do
        for _ in $(seq $step); do
            row=$((row+1)); result=$(current_sum); spiral["$row,$col"]=$result
            if [[ $result -gt $n ]]; then break 2; fi
        done

        for _ in $(seq $step); do
            col=$((col-1)); result=$(current_sum); spiral["$row,$col"]=$result
            if [[ $result -gt $n ]]; then break 2; fi
        done

        for _ in $(seq $((step+1))); do
            row=$((row-1)); result=$(current_sum); spiral["$row,$col"]=$result
            if [[ $result -gt $n ]]; then break 2; fi
        done

        for _ in $(seq $((step+1))); do
            col=$((col+1)); result=$(current_sum); spiral["$row,$col"]=$result
            if [[ $result -gt $n ]]; then break 2; fi
        done
    done

    echo $result
}

function find_ring_level {
    local n=$1
    local sqrt_res=$(echo "sqrt($((n - 1)))" | bc)
    echo "$(((sqrt_res + 1) / 2))"
}

# cursed
function abs {
    echo "${1/-/}"
}

main
