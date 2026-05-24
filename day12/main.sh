#!/usr/bin/env bash

# TODO: make it similar to a garbage collector. first, create some kind of a tree (maybe it will be a graph),
#       then start from node 0 and try to reach as many nodes as possible. maybe a BFS will work well here.
#       track the visited nodes using some kind of a map

set -e

INPUT_TARGET=${1:-./input}

declare -a node_nbors

function main {
    parse < "$INPUT_TARGET"
    time part1
    echo
    time part2
}

function parse {
    IFS=' '
    while read -r index _weird_arrows nbors; do
        nbors="${nbors//,/}"
        node_nbors["$index"]="$nbors"
    done
}

function part1 {
    declare -a seen
    visit_group 0
    echo "${#seen[@]}"
}

function part2 {
    declare -a seen

    for key in "${!node_nbors[@]}"; do
        visit_group "$key"
    done

    grep -o "lawa" <<< "${seen[@]}" | wc -l
}

function visit_group {
    local head="$1"

    if [[ -n "${seen["$head"]}" ]]; then
        return
    fi

    seen["$head"]="mi lawa e kulupu"
    local heads=("$head")

    while [[ "${#heads[@]}" -gt 0 ]]; do
        local new_heads=()

        local heads_text="${heads[@]}"
        for head in $heads_text; do
            local nbors_text="${node_nbors["$head"]}"
            for nbor in $nbors_text; do
                if [[ -z "${seen["$nbor"]}" ]]; then
                    seen["$nbor"]="mi lon insa kulupu"
                    new_heads+=("$nbor")
                fi
            done
        done

        local heads_text="${new_heads[@]}"
        heads=($heads_text)
    done
}

main
