#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(cat $INPUT_TARGET)
    time solve "$input"
}

function solve {
    IFS=$'\t' local items=($1)
    local length="${#items[@]}"
    local count=0

    declare -A visited

    function already_visited {
        (IFS='-'; [[ -n "${visited["${items[*]}"]}" ]])
    }

    function mark_visited {
        IFS='-' visited["${items[*]}"]=$count
    }

    function index_of_largest {
        local result_index=0

        for i in "${!items[@]}"; do
            if [[ "${items[$i]}" -gt "${items[$result_index]}" ]]; then
                result_index="$i"
            fi
        done

        echo "$result_index"
    }

    function redistribute_from {
        local index=$1
        local value="${items[$index]}"
        items[$index]=0

        IFS=$'\n'; for _ in $(seq "$value"); do
            index=$(( (index + 1) % length ))
            local x=${items[$index]}
            items[$index]=$((x + 1))
        done
    }


    until already_visited; do
        mark_visited
        local index=$(index_of_largest)
        redistribute_from "$index"
        count=$((count + 1))
    done

    echo "$count"

    IFS='-'
    local part2=$(( count - "${visited["${items[*]}"]}" ))

    echo "$part2"
}

main
