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
    time part1
    echo
    time part2
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
    function rec_eval_node_sum {
        local node_name="$1"

        if [[ -n "${node_sum["$node_name"]}" ]]; then
            return
        fi

        IFS=' '
        local children_text="${node_children["$node_name"]}"
        for child in $children_text; do
            rec_eval_node_sum "$child"
        done

        local total="${node_value["$node_name"]}"
        local children_text="${node_children["$node_name"]}"
        for child in $children_text; do
            local value="${node_sum["$child"]}"
            total=$((total + value))
        done

        node_sum["$node_name"]="$total"
    }

    local parent="$(find_highest_parent)"
    rec_eval_node_sum "$parent"


    heads=("$parent")
    local head="${heads[0]}"

    while [[ -n "$head" ]]; do
        heads+=("$head")
        local children="${node_children["$head"]}"
        head="$(find_odd_node "${children[@]}")"
    done

    local target_name="${heads[-1]}"
    local target_parent_name="${heads[-2]}"
    local siblings="${node_children["$target_parent_name"]}"
    siblings="${siblings/"$target"/}"
    siblings="${siblings/  / }"
    siblings=($siblings)

    local sibling_name="${siblings[0]}"
    local sibling_sum="${node_sum["$sibling_name"]}"
    local target_sum="${node_sum["$target_name"]}"
    local diff=$((sibling_sum - target_sum))
    local target_value="${node_value["$target_name"]}"
    local new_target_value=$((target_value + diff))
    echo "$new_target_value"
}

function find_odd_node {
    local names=($@)

    declare -A value_to_name
    declare -a values

    for name in "${names[@]}"; do
        local value="${node_sum["$name"]}"
        value_to_name["$value"]="$name"
        values+=("$value")
        # echo "name: $name, value: $value"
    done

    local unique_value=$(IFS=$'\n'; echo "${values[*]}" | sort | uniq -u)
    if [[ -n "$unique_value" ]]; then
        echo "${value_to_name["$unique_value"]}"
    fi
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
