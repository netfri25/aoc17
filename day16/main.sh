#!/usr/bin/env bash

INPUT_TARGET=${1:-./input}

function main {
    local input=$(< "$INPUT_TARGET")
    time part1 <<< "$input"
    echo
    time part2 <<< "$input"
}

function part1 {
    declare -a group
    if [[ "$INPUT_TARGET" == "./input" ]]; then
        group="a b c d e f g h i j k l m n o p"
    else
        group="a b c d e"
    fi

    local result=${ dance "$group"; }
    echo "${result// /}"
}

function part2 {
    local iteration result current start ops i

    read -r ops

    start="a b c d e f g h i j k l m n o p"
    current="$start"

    iteration=0
    while :; do
        result=${ dance "${current[@]}" <<< "$ops"; }
        current="$result"

        (( iteration += 1 ))

        if [[ "$current" == "$start" ]]; then
            break
        fi
    done

    for ((i=0; i<1000000000%iteration; i++)); do
        result=${ dance "${current[@]}" <<< "$ops"; }
        current="$result"
    done

    echo "${current// /}"
}

function dance {
    local ops amount split_index length temp a b
    IFS=','
    read -ra ops

    IFS=' '
    local arg="$1"
    local group=($arg)

    length="${#group[@]}"

    for op in "${ops[@]}"; do
        case "$op" in
            s*)
                amount="${op:1}"
                (( split_index = length - amount % length ))
                IFS=' '
                group=("${group[@]:split_index}" "${group[@]:0:split_index}")
                ;;
            x*)
                IFS='/'
                read -r a b <<< "${op:1}"
                temp="${group[$a]}"
                group[$a]="${group[$b]}"
                group[$b]="$temp"
                ;;
            p*)
                a="${op:1:1}"
                b="${op:3:1}"
                temp="${group[@]}"
                temp="${temp/$a/x}"
                temp="${temp/$b/$a}"
                temp="${temp/x/$b}"
                IFS=' '
                group=($temp)
                ;;
        esac
    done

    echo "${group[@]}"
}

main
