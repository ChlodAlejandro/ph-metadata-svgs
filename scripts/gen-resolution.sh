echo "=================================================="
echo " Generating SVGs with resolution simplification..."
echo "=================================================="

scriptsPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $scriptsPath/..

RESOLUTION=$1
if [ -z $RESOLUTION ]; then
    RESOLUTION="12329x16537"
    echo "No RESOLUTION specified. Using $RESOLUTION."
fi

set -euxo pipefail

source $scriptsPath/gen-lib.sh
ph-metadata-svgs-simplified resolution=$RESOLUTION

set +euxo pipefail