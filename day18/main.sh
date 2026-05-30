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
                cond=${ fetch "$lhs"; }
                value=${ fetch "$rhs"; }
                if ((cond > 0)); then
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
    local command

    rm /tmp/queue0 /tmp/queue1 2>/dev/null || true
    mkfifo /tmp/queue0
    mkfifo /tmp/queue1

    coproc PROG1 { program 0 "$1"; }
    pid1="$PROG1_PID"

    coproc PROG2 { program 1 "$1"; }
    pid2="$PROG2_PID"

    local value1="" value2=""

    local program2_send_count=0

    local q2len=0
    local q2index=0
    declare -a q2=()

    local done=0
    while ((done == 0)); do
        if [[ -n "$value1" ]]; then
            echo "$value1" >&"${PROG1[1]}"
            value1=""
        fi

        while echo >&"${PROG1[1]}" && read -r inst ip <&"${PROG1[0]}"; do
            case "$inst" in
                rcv) break;;
                snd)
                    read -r value2 <&"${PROG1[0]}"
                    ((q2[q2len++] = value2))
                    ;;
            esac
        done

        while echo >&"${PROG2[1]}" && read -r inst ip <&"${PROG2[0]}"; do
            case "$inst" in
                rcv)
                    if ((q2index == q2len)); then
                        ((done=1));
                        break
                    fi

                    echo "$((q2[$q2index]))" >&"${PROG2[1]}"
                    ((q2index++))
                    ;;
                snd)
                    read -r value1 <&"${PROG2[0]}"
                    ((program2_send_count++))
                    break;;
            esac
        done
    done

    echo "$program2_send_count"

    kill "$pid1"
    kill "$pid2"
}

function program {
    local program_id="$1"

    declare -a instructions inst
    declare -A regs
    local lhs rhs last_sound

    regs["p"]="$program_id"

    readarray -t instructions <<< "$2"
    declare -i value ip=0 length="${#instructions[@]}"

    while ((ip>=0 && ip<length)) && read -r _; do
        read -r inst lhs rhs <<< "${instructions["$ip"]}"
        ((ip++))

        echo "$inst $ip"

        case "$inst" in
            snd)
                value=${ fetch "$lhs"; }
                echo "$value"
                ;;
            rcv)
                read -r value
                regs["$lhs"]="$value"
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
            jgz)
                cond=${ fetch "$lhs"; }
                value=${ fetch "$rhs"; }
                if ((cond > 0)); then
                    (( ip += value - 1 ))
                fi
                ;;
            *)
                echo "unknown instruction inst $inst" 1>&2
                exit 1
        esac
    done
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
