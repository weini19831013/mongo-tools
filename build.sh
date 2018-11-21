#!/bin/sh
set -o errexit
tags=""
if [ ! -z "$1" ]
  then
  	tags="$@"
fi

# make sure we're in the directory where the script lives
SCRIPT_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
cd $SCRIPT_DIR

. ./set_goenv.sh
set_goenv || exit

# remove stale packages
rm -rf vendor/pkg

mkdir -p bin

for i in bsondump mongostat mongofiles mongoexport mongoimport mongorestore mongodump mongotop mongooplog mongoreplay; do
        echo "Building ${i}..."
        go build -o "bin/$i" -ldflags "$(print_ldflags)" -tags "$(print_tags $tags)" "$i/main/$i.go" || { echo "Error building $i"; ec=1; break; }
        ./bin/$i --version | head -1
done

if [ -t /dev/stdin ]; then
    stty sane
fi

exit $ec
