#!/bin/bash
set -exuo pipefail

mkdir -p builddir

if [[ "${target_platform}" != "${build_platform}" ]]; then
    sed -i "/^\[binaries\]/a python = '${PREFIX}/bin/python'" ${BUILD_PREFIX}/meson_cross_file.txt
fi

# pyarrow/libarrow >= 24 headers require C++20 (std::span, std::popcount,
# std::bit_width), but turbodbc defaults to cpp_std=c++17. Bump the standard
# for those builds; older arrow keeps building at the upstream default.
extra_setup_args=""
arrow_major="${libarrow:-0}"
if [[ "${arrow_major%%.*}" -ge 24 ]]; then
    extra_setup_args="-Csetup-args=-Dcpp_std=c++20"
fi

$PYTHON -m build -w -n -x \
    -Cbuilddir=builddir \
    -Csetup-args=${MESON_ARGS// / -Csetup-args=} \
    ${extra_setup_args} \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)
$PYTHON -m pip install -vvv dist/turbodbc-*.whl
