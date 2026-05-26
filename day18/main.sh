#!/usr/bin/env bash

INPUT_TARGET=${1:-./input}

function main {
    local input=$(< "$INPUT_TARGET")
    time part1 "$input"
    echo
    time part2 "$input"
}

function part1 {
    declare -a instructions inst
    declare -A regs
    local temp result

    readarray -t instructions <<< "$1"
    declare -i length="${#instructions[@]}"

    declare -i ip=0
    while ((ip>=0 && ip<length)) && [[ -z "$result" ]]; do
        inst=(${instructions["$ip"]})
        result=${ run_inst ${inst[@]}; }
        let ip++
    done

    echo "$result"
}

function part2 {
    echo "$FUNCNAME: TODO" 1>&2
}

function run_inst {
    declare -i value
    case "$1" in
        snd)
            value=${ fetch "$2"; }
            pushd -n "$value" 1>/dev/null
            ;;
        set)
            value=${ fetch "$3"; }
            (( regs[$2] = value ))
            ;;
        add)
            value=${ fetch "$3"; }
            (( regs[$2] += value ))
            ;;
        mul)
            value=${ fetch "$3"; }
            (( regs[$2] *= value ))
            ;;
        mod)
            value=${ fetch "$3"; }
            (( regs[$2] %= value ))
            ;;
        rcv)
            value=${ fetch "$2"; }
            if ((value > 0)); then
                dirs +1 # print the recovered sound
                popd -n 1>/dev/null
            fi
            ;;
        jgz)
            value=${ fetch "$3"; }
            if (( regs[$2] > 0 )); then
                (( ip += value - 1 ))
            fi
            ;;
        *)
            echo "unknown instruction: $1" 1>&2
            exit 1
    esac
}

function fetch {
    if is_number "$1"; then
        echo "$1"
    else
        echo "${regs["$1"]:-0}"
    fi
}

function is_number {
    [[ -z "${1//[-0-9]/}" ]]
}

main
