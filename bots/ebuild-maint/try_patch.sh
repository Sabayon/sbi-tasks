#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

STRATEGY=2 $DIR/patch.sh "$@" || STRATEGY=1 $DIR/patch.sh "$@"
