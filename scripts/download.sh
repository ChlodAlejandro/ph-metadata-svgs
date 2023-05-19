echo "=================================================="
echo " Downloading shapefiles..."
echo "=================================================="

scriptsPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $scriptsPath/..

if [ ! -d "data" ]; then
    echo
    echo "No data folder yet. Creating..."
    mkdir data
fi

echo
if [ -z "$PHL_ADMBNDA_RESOURCE_ROOT" ]; then
    echo "Downloading data from the UN OCHA..."
    PHL_ADMBNDA_RESOURCE_ROOT="https://data.humdata.org/dataset/caf116df-f984-4deb-85ca-41b349d3f313/resource/c704850e-77a4-4d79-8024-a45093da2d91/download/"
else
    echo "Downloading data from $PHL_ADMBNDA_RESOURCE_ROOT..."
fi

if [ -z "$PHL_ADMBNDA_NOADM3_URL" ]; then
    if [ -z "$PHL_ADMBNDA_NOADM3_FILE" ]; then
        PHL_ADMBNDA_NOADM3_FILE="phl_adminboundaries_candidate_exclude_adm3.zip"
    fi
    PHL_ADMBNDA_NOADM3_URL="$RESOURCE_ROOT/$PHL_ADMBNDA_NOADM3_FILE"
fi
if [ -z "$PHL_ADMBNDA_ADM3_URL" ]; then
    if [ -z "$PHL_ADMBNDA_ADM3_FILE" ]; then
        PHL_ADMBNDA_ADM3_FILE="phl_adminboundaries_candidate_adm3.zip"
    fi
    PHL_ADMBNDA_ADM3_URL="$RESOURCE_ROOT/$PHL_ADMBNDA_ADM3_FILE"
fi

echo
echo "Downloading ZIP for adminstrative divisions 0 (country), 1 (region), and 2 (province)..."
wget $PHL_ADMBNDA_NOADM3_URL \
    --no-clobber -O data/phl_adminboundaries_candidate_exclude_adm3.zip
unzip -n -d data data/phl_adminboundaries_candidate_exclude_adm3.zip \
    phl_admbnda_adm2_psa_namria_*.shp

echo
echo "Downloading ZIP for adminstrative division 3 (municipalities)..."
wget $PHL_ADMBNDA_ADM3_URL \
    --no-clobber -O data/phl_adminboundaries_candidate_adm3.zip
unzip -n -d data data/phl_adminboundaries_candidate_adm3.zip \
    phl_admbnda_adm3_psa_namria_*.shp