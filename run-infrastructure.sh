#!/usr/bin/env bash
#
# NAME
#     run-infrastructure.sh - Run Ansible with infrastructure configurations
#
# SYNOPSIS
#     ./run-infrastructure.sh CLUSTER ENV
#     ./run-infrastructure.sh

set -eu -o pipefail

source ANSIBLE_DOCKER_ENV

USAGE=$(sed -E -e '/^$/q' -e 's/^#($|!.*| (.*))$/\2/' "$0")

case $# in
    2) docker run -it -v "${PWD}:/project" \
                -v ~/.aws:/root/.aws \
                -e "CLUSTER_NAME=${1:?"Required argument missing. $USAGE"}" \
                -e "ENV=${2:?"Required argument missing. $USAGE"}" \
                "simplemachines/ansible-template:${DOCKER_TAG:?"Required variable missing. $USAGE"}" \
                scripts/run-infrastructure.sh
       ;;
    *) # Display usage along with suggested arguments
	cat <<EOF
Error: $0 requires 2 arguments. $USAGE

OPTIONS

    You may want to run one of the following commands:

EOF

    # We'll ignore vault files; we won't be able to run them anyway.
	find . -maxdepth 4 -type f -name '*.yml' ! -name 'common.yml' ! -name '*.vault.yml' | sort \
	    | egrep '^./([^/]+/infrastructure/.*.yml)$' \
	    | sed -Ee "/infrastructure/s#^./([^/]*)/infrastructure/(.*).yml#    $0 \1 \2#" \
	    || echo "        ERROR: No clusters or services found"
	exit 1
	;;
esac
