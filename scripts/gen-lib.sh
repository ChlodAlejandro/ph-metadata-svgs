if [ ${0##*/} == ${BASH_SOURCE[0]##*/} ]; then 
    echo "WARNING"
    echo "This script is not meant to be executed directly!"
    echo "Use the gen-percent or gen-resolution scripts instead."
    echo
    exit 1
fi

function ph-metadata-svgs() {
    npx mapshaper-xl \
    `# Importing` \
    -i data/phl_admbnda_adm2_psa_namria_*.shp name=Provinces \
    -i data/phl_admbnda_adm3_psa_namria_*.shp name=Municipalities \
    `# Styling` \
    -style target=Municipalities fill=transparent stroke=black stroke-width=0.5 \
    -style target=Provinces fill=transparent stroke=black stroke-width=3 \
    `# Set IDs` \
    -each target=Municipalities 'municipality=this.properties.ADM3_EN; province=this.properties.ADM2_EN; id = province.replace(/ /g, "_") + "+" + municipality.replace(/ /g, "_")' \
    -each target=Provinces 'province=this.properties.ADM2_EN; id = province.replace(/ /g, "_")' \
    `# Rename PSGC code attributes` \
    -each target=Municipalities 'this.properties["municipality-psgc"] = this.properties.ADM3_PCODE; this.properties["province-psgc"] = this.properties.ADM2_PCODE' \
    -each target=Provinces 'this.properties["province-psgc"] = this.properties.ADM2_PCODE' \
    $@
}

function ph-metadata-svgs-simplified() {
    SIMPLIFY_OPTS=$1

    ph-metadata-svgs \
        -simplify target=Municipalities $SIMPLIFY_OPTS stats \
        -simplify target=Provinces $SIMPLIFY_OPTS stats \
        `# Data output` \
        -o svg-data=municipality,province,municipality-psgc,province-psgc \
            target=* id-field=id svg-scale=0.001 format=svg \
        "out/philippines-simplify-$(
            echo "$SIMPLIFY_OPTS" \
                | sed -r 's/([0-9.]+)%/percentage=\1/' \
                | sed -r 's/[^A-Za-z0-9_]/-/'
        ).svg"
}