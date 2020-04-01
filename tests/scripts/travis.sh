#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

function docker_run_test() {
  local image_name="$1"

  local container_work_folder_path="/Host/Work"
  local container_repo_folder_path="/Host/repo"

  docker run \
    --tty \
    --env DEBUG=${DEBUG} \
    --volume "${HOME}/Work:${container_work_folder_path}" \
    --volume "${TRAVIS_BUILD_DIR}:${container_repo_folder_path}" \
    "${image_name}" \
    /bin/bash "${container_repo_folder_path}/tests/scripts/container-test.sh" \
      "${image_name}" \
      "${base_url}"
}

# =============================================================================

base_url="$1"
echo "Base URL: ${base_url}"

mkdir -p "${HOME}/Work"

host_platform=$(uname -s | tr '[:upper:]' '[:lower:]')
host_machine=$(uname -m | tr '[:upper:]' '[:lower:]')

if [ "${host_platform}" == "Linux" ]
then
  if [ "${host_machine}" == "x86_64" ]
  then
    echo "Testing Intel Linux"

    docker_run_test "ubuntu:20.04" 
    
    exit 0
  elif [ "${host_machine}" == "aarch64" ]
  then
    echo "Testing Arm Linux"
    docker run hello-world  
    exit 0
  else
    echo "${host_machine} not supported"
    exit 1
  fi
elif [ "${host_platform}" == "Darwin" ]
then
    echo "Testing macOS"
    exit 0
else
  # TODO: add support for Windows
  echo "${host_platform} not supported"
  exit 1
fi

echo "Should not get here"
exit 1