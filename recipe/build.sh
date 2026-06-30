#!/bin/bash
set -exuo pipefail

mkdir -p builddir

if [[ "${target_platform}" != "${build_platform}" ]]; then
    sed -i "/^\[binaries\]/a python = '${PREFIX}/bin/python'" ${BUILD_PREFIX}/meson_cross_file.txt
fi

$PYTHON -m build -w -n -x \
    -Cbuilddir=builddir \
    -Csetup-args=${MESON_ARGS// / -Csetup-args=} \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)
$PYTHON -m pip install -vvv dist/turbodbc-*.whl
