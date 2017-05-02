function _portdir_tmp() {
    for f in /etc/portage/make.conf /etc/make.conf; do
        if [ -r $f ]; then
            if [ ! -z $(grep PORTDIR_TMP $f) ]; then
                grep PORTDIR_TMP $f | cut -d '=' -f2
            fi
        fi
    done
}

function _get_first_atom() {
    qlop -c | grep \* | head -n1 | tr -d "[:space:]*"
}

function _emerge_running() {
    if [ -z $(pidof emerge) ]; then
        return 0
    fi
    return 1
}

local PORTDIR_TMP=$(_portdir_tmp)
PORTDIR_TMP=${PORTDIR_TMP:-/var/tmp/portage}

# Tails the log file for each package being emerged currently
function emerge-tailf() {
    local PKG="hello"
    local LOGFILE=""

    while [ ! -z $PKG -a -z $(pidof emerge) ]; do
        PKG=$(_get_first_atom)
        LOGFILE="$PORTDIR_TMP/$PKG/temp/build.log"
        if [ -z "$PKG" ]; then
            printf "emerge not running\n" 2>&1
            return 1
        fi
        sudo tailf $LOGFILE
    done
}

# Purges the temporary emerge directory if emerge is not running
function emerge-purge() {
    if [ -z $(pidof emerge) ]; then
        sudo rm -rf $PORTDIR_TMP/*
    else
        printf emerge currently running
    fi
}
