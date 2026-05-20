#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

# Node :: {
#     value: int
#     parent: string (can be unknown),
#     children: Array[string],
# }

declare -A node_parent
declare -A node_children
declare -A node_value
declare -A node_sum

function main {
    local input=$(cat $INPUT_TARGET)
    parse "$input"
    part1
    part2
}

function parse {
    local input="$1"
    while IFS='|' read -r node_name value children_text; do
        node_value["$node_name"]="$value"
        node_children["$node_name"]="$children_text"

        IFS=' '
        for child in $children_text; do
            node_parent["$child"]="$node_name"
        done
    done < <(echo "$input" | sed 's/,//g' | sed -r 's/^(\w+) \(([0-9]+)\)( -> ((\w+( \w+)*)+))?$/\1|\2|\4/')
}

function part1 {
    find_highest_parent
}

function part2 {
    echo "$FUNCNAME: TODO" 1>&2

    function rec_eval_node_sum {
        local node_name="$1"

        if [[ -z "${node_sum["$node_name"]}" ]]; then

            IFS=' '
            local children_text="${node_children["$node_name"]}"
            for child in $children_text; do
                eval_node_sum "$child"
            done

            local total="${node_value["$node_name"]}"
            local children_text="${node_children["$node_name"]}"
            for child in $children_text; do
                local value="${node_sum["$child"]}"
                total=$((total + value))
            done

            node_sum["$node_name"]="$total"

            if [[ -z "$children_text" ]]; then
                return
            fi
        fi
    }

    local parent="$(find_highest_parent)"
    rec_eval_node_sum "$parent"

    # TODO: automate this to print out the odd one.
    #       this can be done by going deeper to the non-similar child, until all children are equal.
    #       compare the sums.
    local queue="$parent"
    local depth=0
    while [[ -n "$queue" ]]; do
        local new_queue=""

        for node_name in $queue; do
            local children="${node_children["$node_name"]}"
            new_queue+=" $children"

            local indents=$((depth*4))
            printf "%*s sum: ${node_sum["$node_name"]}, value: ${node_value["$node_name"]}, $node_name\n" "$indents" ""
        done

        queue="$new_queue"
        depth=$((depth + 1))
    done
}

function find_highest_parent {
    for node_name in "${!node_value[@]}"; do
        if [[ -z "${node_parent["$node_name"]}" ]]; then
            echo "$node_name"
            break
        fi
    done
}

main
