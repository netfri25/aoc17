#!/usr/bin/env bash

D2B=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})

INPUT_TARGET=${1:-./input}

function main {
    local input=$(< $INPUT_TARGET)
    solve "$input"
}

function solve {
    local input="$1"

    local result=${
        for i in {0..127}; do
            hash "$input-$i"
        done
    }

    # part 1: count the amount of binary digits
    grep -o "1" <<< "$result" | wc -l

    # part 2: count the amount of regions
    count_regions "$result"
}

function count_regions {
    local i j width grid count nbors current
    readarray -t grid < <(fold -w1 <<< "$1")

    declare -a queue

    (( width = 128, count = 0 ))
    for ((i=0; i<width*width; i++)); do
        if ((grid[i] == 1)); then
            (( count++, j = 0 ))
            queue=("$i")

            until [[ -z "${queue[$j]}" ]]; do
                (( current = queue[j] ))
                (( grid[current] = 0 ))
                nbors=()

                if (((current&127) != 0)); then
                    nbors+=($((current-1)))
                fi

                if (((current&127) != 127)); then
                    nbors+=($((current+1)))
                fi

                if ((current >= width)); then
                    nbors+=($((current-width)))
                fi

                if ((current + width < width*width)); then
                    nbors+=($((current+width)))
                fi

                for nbor in "${nbors[@]}"; do
                    if ((grid[nbor] == 1)); then
                        queue+=($nbor)
                    fi
                done

                (( j++ ))
            done
        fi
    done

    echo "$count"
}

function hash {
    local lengths_text="$1"
    local lengths_text_len="${#1}"
    declare -a lengths

    local i value
    for ((i=0; i<lengths_text_len; i++)); do
        printf -v value "%d" "'${lengths_text:i:1}"
        lengths+=("$value")
    done

    lengths+=(17 31 73 47 23)

    local list=({0..255})
    local current_position=0
    local skip_size=0

    local length front back j index other temp
    for ((i=0; i<64; i++)); do
        for length in "${lengths[@]}"; do
            # reverse in range
            ((
                front = current_position,
                back = front + length - 1
            ))

            for ((j=0; j < length/2; j++)); do
                ((
                    index = front & 255,
                    other = back  & 255,

                    temp = list[index],
                    list[index] = list[other],
                    list[other] = temp,

                    front++,
                    back--
                ))
            done

            ((
                current_position += length + skip_size++,
                current_position &= 255
            ))
        done
    done

    local chunk byte offset
    for ((chunk=0; chunk<16; chunk++)); do
        (( byte=0 ))

        for ((offset=0; offset<16; offset++)); do
            ((byte ^= list[chunk * 16 + offset]))
        done

        echo -n "${D2B["$byte"]}"
    done
}

main
