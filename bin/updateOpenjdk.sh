#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

: "${AUTHOR:=Daniel Sobral <dcsobral@precog.com>}"
: "${ORG:=precog}"
: "${RATELIMIT:=5}"
: "${NOCOLOR=}"

type hub >/dev/null 2>&1 || {
  echo >&2 "Requires hub(1)"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --nocolor)
    NOCOLOR=1
    shift
    ;;
  *)
    echo >&2 "Invalid parameter '$1'"
    exit 1
    ;;
  esac
done

abend() {
  echo >&2 "Abnormal exit!"
}

trap abend EXIT

ansi() {
  [[ -n $NOCOLOR ]] || echo -n $'\u001b['"${1}m"
}

red() {
  ansi 31
}

green() {
  ansi 32
}

reset() {
  ansi 0
}

error() {
  echo "Repo ${1}: $(red)$2$(reset) ${3:+more info: $3}"
  return 1
}

try() {
  set +e
  "${@}"
  RES=$?
  set -e
  echo "${RES}"
}

searchTravisYml() {
  repo="$1"
  file="${repo#*/}.contents"
  [[ -f ${file} ]] || hub api --paginate "/repos/${repo}/contents/" >"${file}"
  jq '.[] | select(.name? == ".travis.yml")' "${file}" ||
    error "${repo}" "FAILED TO GET CONTENTS" "${file}" || echo ""
}

getTravisYml() {
  repo="$1"
  file="${repo#*/}.travis.yml"
  [[ -f $file ]] || hub api "/repos/${repo}/contents/.travis.yml" >"${file}"
  jq -r '.content | split("\n") | map(@base64d) | join("")' "${file}" ||
    error "${repo}" "FAILED TO GET .travis.yml" "${file}" || echo ""
}

checkPR() {
  repo="$1"
  file="${repo#*/}.pulls"
  [[ -f $file ]] || hub api --paginate "/repos/${repo}/pulls" >"${file}"
  jq '.[] | select(.head.ref == "feature/ch6812")' "${file}" ||
    error "${repo}" "FAILED TO GET PULL REQUESTS" "${file}"
}

checkPermissions() {
  name="$1"
  jq --arg name "${name}" '.[] | select(.name == $name) | .permissions.push' "${ORG}.repos.json"
}

[[ -f "${ORG}.repos.json" ]] ||
  hub api --paginate "/orgs/${ORG}/repos" | jq -c '.[]' | jq -n '[inputs]' >"${ORG}.repos.json"

mapfile -t < <(jq -r '.[] | select(.archived | not) | .name' "${ORG}.repos.json")

echo "${#MAPFILE[@]} non-archived repositories:"

for name in "${MAPFILE[@]}"; do
  repo="${ORG}/${name}"
  echo -n "${name}: "
  FILE="$(searchTravisYml "${repo}")"
  if [[ -n $FILE ]]; then
    TRAVIS_YML="$(getTravisYml "${repo}")"
    HAS_JDK=$(try grep -q jdk <<<"${TRAVIS_YML}")
    if [[ $HAS_JDK == 0 ]]; then
      HAS_OPENJDK=$(try grep -q openjdk <<<"${TRAVIS_YML}")
      if [[ $HAS_OPENJDK != 0 ]]; then
        echo "needs update"
        # The "f && g || h" pattern is being used to silence errors, not as if-then-else
        # shellcheck disable=SC2015
        PR="$(checkPR "${repo}")" &&
          if [[ -z $PR ]]; then
            PERM="$(checkPermissions "${name}")"
            if [[ $PERM == "true" ]]; then
              (
                hub clone "${repo}"
                cd "${name}"
                git checkout -b feature/ch6812
                sed -Ei '' 's/oraclejdk/openjdk/g' .travis.yml
                git add .travis.yml
                git commit --author "${AUTHOR}" -m "Update JDK to OpenJDK (CH6812)"
                hub pull-request --no-edit -p -r nicflores -a nicflores -l 'version: revision'
              ) || error "${repo}" "FAILED TO PULL REQUEST!" || :
            else
              error "${repo}" "NO PERMISSION TO PUSH!" || :
            fi
          else
            echo "PR: $(green)$(jq -r '._links.html.href' <<<"${PR}")$(reset)"
          fi || :
      else
        echo "doesn't need update"
      fi
    else
      echo "no jdk"
    fi
  else
    echo "no travis build"
  fi
  sleep "${RATELIMIT}"
done

trap - EXIT
