#!/bin/bash

set -euo pipefail

cd /etc/mapnik-osm-data/carto-de

psql -d"gis" -ef indexes-hstore.sql
views_osmde/apply-views.sh {{ gis_dbname }} {{ style.default_language }}
