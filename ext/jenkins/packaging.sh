#!/usr/bin/env bash

echo "**********************************************"
echo "PARAMS FROM UPSTREAM:"
echo ""
echo "PUPPETDB_BRANCH: ${PUPPETDB_BRANCH}"
echo "LEIN_PROJECT_VERSION: ${LEIN_PROJECT_VERSION}"
echo "GEM_SOURCE: ${GEM_SOURCE}"
echo "SHIP_NIGHTLY: ${SHIP_NIGHTLY}"
echo "REPO_URL: ${REPO_URL}"
echo "**********************************************"

set -x
set -e

export COW="base-jessie-amd64.cow base-precise-amd64.cow base-trusty-amd64.cow base-wheezy-amd64.cow base-wily-amd64.cow base-xenial-amd64.cow"
export MOCK="pl-el-6-x86_64 pl-el-7-x86_64"
tmp_m2=$(pwd)/$(mktemp -d m2-local.XXXX)

lein update-in : assoc :local-repo "\"${tmp_m2}\"" -- install
lein update-in : assoc :local-repo "\"${tmp_m2}\"" -- deps
# The ci-voom profile has nexus credentials
lein update-in : assoc :local-repo "\"${tmp_m2}\"" -- with-profile user,ci-voom deploy
lein update-in : assoc :local-repo "\"${tmp_m2}\"" -- with-profile ezbake ezbake stage

pushd "target/staging"
rake package:bootstrap
rake pl:jenkins:uber_build[5]

cat > "${WORKSPACE}/puppetdb.packaging.props" <<PROPS
PUPPETDB_PACKAGE_BUILD_VERSION=$(rake pl:print_build_param[ref] | tail -n 1)
PROPS
popd

set -x

# Set ship targets and build team for packaging repo
REPO_HOST=builds.delivery.puppetlabs.net
export REPO_DIR REPO_HOST

# Now rebuild the metadata
# We add the `--follow-symlinks` flag to the apt metadata in preparation for
# the switch from reprepro to aptly. Aptly employs symlinks to maintain the
# current expected directory structure. As we cannot ship symlinks to s3, this
# flag will send over the resolved files.
ssh $REPO_HOST <<PUBLISH_PACKAGES

set -e
set -x
=======
>>>>>>> 47e69958... (QENG-2198) More packaging script cleanup.
