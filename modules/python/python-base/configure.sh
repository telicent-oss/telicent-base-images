set -e

SCRIPT_DIR="$(dirname "$0")"
ARTIFACTS_DIR=${SCRIPT_DIR}/scripts

[ -z "${DESTINATION_SCRIPTS+x}" ] && echo "Needs destination, check your module.yaml" && exit 1

mkdir -p "$DESTINATION_SCRIPTS"
mkdir -p "$DESTINATION_SCRIPTS/scripts"

mv $ARTIFACTS_DIR $DESTINATION_SCRIPTS/
mv $SCRIPT_DIR/configure-python.sh $DESTINATION_SCRIPTS/configure.sh