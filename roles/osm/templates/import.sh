#!/bin/bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo >&2 "Usage: $(basename "$0") <pbf-file ...>"
    exit 1
fi

cd /etc/mapnik-osm-data/carto
for f in "$@"; do
    flatnodes=''
    [[ "$f" =~ .*/planet-.* ]] && flatnodes="--flat-nodes /var/tmp/flatnodes"
    time osm2pgsql --create --slim \
        --multi-geometry --style hstore-only.style \
        --tag-transform-script openstreetmap-carto.lua \
        --database gis --unlogged --number-processes={{ virtualcpus - 2 }} --hstore -p planet_osm_hstore \
        $flatnodes "$f"
done

test -e ~/post-import.sh && ~/post-import.sh
