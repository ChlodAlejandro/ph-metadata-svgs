echo "=================================================="
echo " Generating SVGs with percentage simplification..."
echo "=================================================="

scriptsPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $scriptsPath/..

PERCENTAGE=$1
if [ -z $PERCENTAGE ]; then
    PERCENTAGE=10
    echo "No percentage specified. Using $PERCENTAGE%."
fi

set -euxo pipefail

source $scriptsPath/gen-lib.sh
ph-metadata-svgs-simplified $PERCENTAGE%

set +euxo pipefail