#!/usr/bin/env bash

set -e

INPUT_TARGET=${1:-./input}


declare -a targets_regs
declare -a actions
declare -a values
declare -a conds_regs
declare -a conds
declare -a conds_values


function main {
    parse <"$INPUT_TARGET"
    part1
    part2
}

function part1 {
    declare -A regs

    for i in "${!conds[@]}"; do
        eval_inst "$i"
    done

    (IFS=$'\n'; echo "${regs[*]}" | sort -n | tail -1)
}

function part2 {
    declare -A regs

    local all_values_ever=(0)

    for i in "${!conds[@]}"; do
        eval_inst "$i"
        all_values_ever+=("${regs[@]}")
    done

    (IFS=$'\n'; echo "${all_values_ever[*]}" | sort -n | tail -1)
}

function eval_inst {
    local i="$1"
    local cond_reg_name="${conds_regs["$i"]}"
    local cond="${conds["$i"]}"
    local cond_rhs="${conds_values["$i"]}"

    local cond_lhs="${regs["$cond_reg_name"]:-0}"

    if test "$cond_lhs" "$cond" "$cond_rhs"; then
        local action="${actions["$i"]}"
        local target="${targets_regs["$i"]}"
        local value="${values["$i"]}"

        local reg_value="${regs["$target"]:-0}"

        case "$action" in
            inc) reg_value=$((reg_value + value)) ;;
            dec) reg_value=$((reg_value - value)) ;;
            *)
                echo "unknown action '$action'"
                exit 1
                ;;
        esac

        regs["$target"]="$reg_value"
    fi
}

function parse {
    while read -r target_reg action value _if cond_reg cond cond_value; do
        targets_regs+=("$target_reg")
        actions+=("$action")
        values+=("$value")
        conds_regs+=("$cond_reg")

        case "$cond" in
            "!=") cond="-ne" ;;
            "==") cond="-eq" ;;
            ">=") cond="-ge" ;;
            "<=") cond="-le" ;;
            ">")  cond="-gt" ;;
            "<")  cond="-lt" ;;
            *)
                echo "unknown condition '$cond'"
                exit 1
                ;;
        esac

        conds+=("$cond")
        conds_values+=("$cond_value")
    done
}

main
