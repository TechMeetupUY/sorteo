#!/bin/sh

detect_sed() {
    if sed --version >/dev/null 2>&1
    then
        SED='sed -i'
    else
        SED='sed -i ""'
    fi

}

program="$(basename "$0")"

reset_list() {
    cp list curr 
    usage
}

count() {
    wc -l $@ | awk '{ print $1 }'
}

usage() {
    echo >&2 "List ready ($(count curr) regs)"
    echo >&2 "    run \`$program draw [n]' to draw results"
    echo >&2 "    run \`$program reset' to reset list"
}

confirm() {
    local msg
    local n rnd
    local var

    msg="$1"
    n="$(expr $RANDOM \* 100 + $RANDOM)"
    n="$(expr $n % "$(count /usr/share/dict/words )" + 1)"
    rnd="$(head -n "$n" /usr/share/dict/words | tail -1)"

    printf >&2 "%s. To confirm type \`%s': " "$msg" "$rnd"
    read var
    if test "x$rnd" == "x$var"
    then
        return 0
    fi

    return 1

}

draw() {
    local draw i
    local n rnd

    draw="$1"

    if test "$(count curr)" -lt "$draw"
    then
        echo >&2 "No source enough!"
        exit 1
    fi

    detect_sed

    for i in $(seq 1 $draw)
    do
        n="$(expr $RANDOM % "$(count curr)" + 1)"
        rnd="$(head -n "$n" curr | tail -n 1)"
        $SED "${n}d" curr
        echo "$rnd" | awk '{ print "WINRAR: " $2 " " $1 }'
    done

    echo
    usage

}

if test "$#" -ge 1
then
    command="$1"
fi

# Check that the link exists
if ! test -r curr
then
    # Check attendee list
    if ! test -r list
    then
        echo >&2 "No source list."
        exit 2
    fi

    if test "$command" != "reset"
    then
        echo >&2 "No current list: run \`$program reset' to start"
        exit 2
    fi

fi

case "$command" in
    reset )
        if confirm "Current list exists"
        then
            reset_list
        else
            echo >&2 "List not reset"
        fi

        exit 0
        ;;
    draw )
        if test "$#" -ge 2
        then
            draw="$2";
        else
            draw=1
        fi

        if ! echo "$draw" | grep -q ^[0-9][0-9]*$
        then
            echo >&2 "draw: Incorrect number format \`$draw'!"
            exit 1
        elif test "$draw" -lt 1
        then
            echo >&2 "draw: We can't draw zero!"
            exit 1
        fi

        draw $draw
        ;;
    * )
        echo >&2 "Unknown command \`$command'"
        usage
        exit 0
        ;;
esac

