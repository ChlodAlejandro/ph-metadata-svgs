echo "=================================================="
echo " Generating simplified SVGs..."
echo "=================================================="

scriptsPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $scriptsPath/..

set -euxo pipefail

source $scriptsPath/gen-lib.sh
ph-metadata-svgs-simplified $@

set +euxo pipefail