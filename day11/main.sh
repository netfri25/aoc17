#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}

function main {
    local input=$(< $INPUT_TARGET)
    time solve "$input"
}

function solve {
    declare -a input
    ${ IFS=','; read -ra input <<< "$1"; }

    local x=0
    local y=0
    local z=0

    local max_reached=0

    for direction in "${input[@]}"; do
        step "$direction"
        max_reached=${ maximum_abs "$max_reached" "$x" "$y" "$z"; }
    done

    local distance="$(maximum_abs "$x" "$y" "$z")"

    echo "$distance"
    echo "$max_reached"
}

function step {
    case "$1" in
        nw)
            x=$((x+1))
            y=$((y-1))
            ;;
        n)
            x=$((x+1))
            z=$((z-1))
            ;;
        ne)
            y=$((y+1))
            z=$((z-1))
            ;;
        se)
            x=$((x-1))
            y=$((y+1))
            ;;
        s)
            x=$((x-1))
            z=$((z+1))
            ;;
        sw)
            y=$((y-1))
            z=$((z+1))
            ;;
    esac
}

function maximum_abs {
    local result="$1"

    for item; do
        item="${item/-/}"
        if (( item > result )); then
            result="$item"
        fi
    done

    echo "$result"
}

main
