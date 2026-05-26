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
    local lhs rhs last_sound

    readarray -t instructions <<< "$1"
    declare -i value ip=0 length="${#instructions[@]}"

    while ((ip>=0 && ip<length)) && [[ -z "$last_sound" ]]; do
        read -r inst lhs rhs <<< "${instructions["$ip"]}"
        ((ip++))

        case "$inst" in
            snd)
                value=${ fetch "$lhs"; }
                pushd -n "$value" 1>/dev/null
                ;;
            set)
                value=${ fetch "$rhs"; }
                (( regs[$lhs] = value ))
                ;;
            add)
                value=${ fetch "$rhs"; }
                (( regs[$lhs] += value ))
                ;;
            mul)
                value=${ fetch "$rhs"; }
                (( regs[$lhs] *= value ))
                ;;
            mod)
                value=${ fetch "$rhs"; }
                (( regs[$lhs] %= value ))
                ;;
            rcv)
                value=${ fetch "$lhs"; }
                if ((value > 0)); then
                    # print the recovered sound
                    last_sound=${ dirs +1; }
                    popd -n 1>/dev/null
                    break
                fi
                ;;
            jgz)
                value=${ fetch "$rhs"; }
                if [[ "${regs["$lhs"]}" -gt 0 ]]; then
                    (( ip += value - 1 ))
                fi
                ;;
            *)
                echo "unknown instruction" 1>&2
                exit 1
        esac
    done

    echo "$last_sound"
}

function part2 {
    echo "$FUNCNAME: TODO" 1>&2
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
