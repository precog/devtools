#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

: "${ORG:=precog}"
: "${RATELIMIT:=5}"
: "${NOCOLOR=}"
: "${DRY=0}"
: "${TARGET=}"

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
  --dryrun)
    DRY=1
    shift
    ;;
  *)
    TARGET="${1}"
    shift
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

searchPluginsSbt() {
  repo="$1"
  file="${repo#*/}.contents"
  [[ -f ${file} ]] || hub api --paginate "/repos/${repo}/contents/project/" >"${file}"
  jq '.[] | select(.name? == "plugins.sbt")' "${file}" ||
    error "${repo}" "FAILED TO GET CONTENTS" "${file}" || echo ""
}

getPluginsSbt() {
  repo="$1"
  file="${repo#*/}plugins.sbt"
  [[ -f $file ]] || hub api "/repos/${repo}/contents/project/plugins.sbt" >"${file}"
  jq -r '.content | split("\n") | map(@base64d) | join("")' "${file}" ||
    error "${repo}" "FAILED TO GET plugins.sbt" "${file}" || echo ""
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
  FILE="$(searchPluginsSbt "${repo}")"
  if [[ -n $FILE ]]; then
    PLUGINS_SBT="$(getPluginsSbt "${repo}")"
    HAS_SBT_SLAMDATA=$(try grep -q sbt-precog <<<"${PLUGINS_SBT}")
    if [[ $HAS_SBT_SLAMDATA == 0 ]]; then
      echo "might need updating"
      # The "f && g || h" pattern is being used to silence errors, not as if-then-else
      # shellcheck disable=SC2015
      PR="$(checkPR "${repo}")" &&
        if [[ -z $PR ]]; then
          PERM="$(checkPermissions "${name}")"
          if [[ $PERM == "true" ]]; then
            (
              hub clone --depth 1 "${repo}"
              cd "${name}"
              git checkout -b build/version-bump-sbt-precog
              sed -Ei '' "s/addSbtPlugin\(\"com.precog\" *% *\"sbt-precog\" *% *\"[^\"]+\"\)/addSbtPlugin(\"com.precog\" % \"sbt-precog\" % \"${TARGET}\")/g" project/plugins.sbt
              git add project/plugins.sbt
              git commit -m "Update sbt-precog to $TARGET"
              if [[ $? == 0 ]]; then
                if [[ $DRY == 0 ]]; then
                  hub pull-request --no-edit -p -l 'version: revision'
                else
                  echo "DRY: hub pull-request --no-edit -p -l 'version: revision'"
                fi
              else
                echo "${repo} didn't need updating after all"
              fi
            ) || error "${repo}" "FAILED TO PULL REQUEST!" || :
          else
            error "${repo}" "NO PERMISSION TO PUSH!" || :
          fi
        else
          echo "PR: $(green)$(jq -r '._links.html.href' <<<"${PR}")$(reset)"
        fi || :
    else
      echo "doesn't use sbt-precog"
    fi
  else
    echo "has no plugins.sbt file"
  fi
  sleep "${RATELIMIT}"
done

trap - EXIT
