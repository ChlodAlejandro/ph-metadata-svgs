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

curl https://data.humdata.org/api/3/action/package_show?id=cod-ab-phl > data/cod-ab-phl.json
PHL_ADMBNDA_DOWNLOAD_LIST=$(
    node -e "process.stdout.write(
        JSON.parse(require('fs').readFileSync('data/cod-ab-phl.json')).result.resources
            .filter(
                v => /^phl_adminboundaries_candidate_(?:exclude_)?adm\d\.zip$/gi.test(v.name) ||
                    /Philippines administrative level [\d-]+ shapefiles/i.test(v.description)
            )
            .map(v => v.download_url)
            .join('\n')
    )"
)
echo $PHL_ADMBNDA_DOWNLOAD_LIST

echo
echo "Downloading adminstrative division ZIPs..."
echo "NOTE: Non-matching filenames are normal."
set -x
wget $PHL_ADMBNDA_DOWNLOAD_LIST \
    --progress=dot:giga \
    --no-clobber -P data

for i in data/phl_adminboundaries_candidate_*.zip; do
    [ -f "$i" ] && unzip -n -d data $i \
        phl_admbnda_adm2_psa_namria_*.{shp,dbf} \
        phl_admbnda_adm3_psa_namria_*.{shp,dbf}
done
set +x