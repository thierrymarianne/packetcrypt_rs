#!/bin/bash

function build() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  cd "${GITHUB_WORKSPACE}" || exit
  cargo build --release --features jemalloc

  local VERSION
  VERSION=$(echo "${RELEASE_NAME}" | sed -E 's/.+v//')

  cd "${GITHUB_WORKSPACE}" || exit
  bash -x ./contrib/deb/build.sh

  mv -v "${GITHUB_WORKSPACE}"'/packetcrypt-linux_'"${VERSION}"'_amd64.deb' \
    "${GITHUB_WORKSPACE}"'/'"${RELEASE_NAME}"'-linux-amd64.deb'

  cd "${GITHUB_WORKSPACE}" || exit
  bash -x ./contrib/rpm/build.sh

  mv -v "${GITHUB_WORKSPACE}"'/packetcrypt-linux-'"${VERSION}"'-1.x86_64.rpm' \
    "${GITHUB_WORKSPACE}"'/'"${RELEASE_NAME}"'-linux-x86_64.rpm'
}
build