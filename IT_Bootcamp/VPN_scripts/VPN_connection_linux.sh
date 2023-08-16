#!/bin/bash

set -e

sudo apt install -y network-manager-l2tp network-manager-l2tp-gnome jq

file_path="$(dirname "${BASH_SOURCE[0]}")/VPN_access.json"

if [[ $# -ne 0 ]]; then
  while getopts "p:" opt; do
    case $opt in
      p)
        file_path=$OPTARG
        echo "Path: $file_path"
        ;;
      *)
        echo "Inappropriate flag: -$OPTARG. The correct flag is -p" >&2
        exit 1
        ;;
    esac
  done
fi

if [[ ! -f "$file_path" ]]; then
  echo "Error: File not found"
  exit 1
fi

declare -A jsondata
while IFS="=" read -r key value
do
    jsondata["$key"]="$value"
done < <(jq -r 'to_entries | map("\(.key)=\(.value|tostring)") | .[]' "${file_path}")

sudo nmcli con delete "${jsondata["NameConnection"]}" >/dev/null 2>&1 || true
sudo nmcli connection add \
    type vpn \
    vpn-type l2tp \
    connection.id "${jsondata["NameConnection"]}" \
    con-name "${jsondata["NameConnection"]}" \
    ifname "" \
    connection.autoconnect no \
    ipv6.method ignore \
    ipv4.method auto \
    ipv4.ignore-auto-routes true \
    ipv4.never-default true \
    ipv4.routes "${jsondata["DestinationPrefix"]} ${jsondata["RemoteGateway"]}" \
    vpn.data \
    "gateway=${jsondata["ServerAddress"]},\
    ipsec-enabled=yes,\
    ipsec-psk=${jsondata["IPsecSecret"]},\
    password-flags=0,\
    refuse-chap=yes,\
    refuse-mschap=yes,\
    refuse-pap=yes,\
    refuse-eap=yes,\
    user=${jsondata["Username"]}"

sudo service NetworkManager restart
nmcli con modify "${jsondata["NameConnection"]}" vpn.secrets "password=${jsondata["Password"]}"
nmcli con modify "${jsondata["NameConnection"]}" vpn.secrets "ipsec-psk=${jsondata["IPsecSecret"]}"
echo "${jsondata["Password"]}" | nmcli connection up "${jsondata["NameConnection"]}" --ask

declare -A hostsJsonData
while IFS="=" read -r key value; do
    hostsJsonData["$key"]="$value"
done < <(jq -r 'to_entries | map("\(.key)=\(.value|tostring)") | .[]' <<<"${jsondata[hosts]}")

hostsFolder="/etc"
hostsPath="$hostsFolder/hosts"
cp "$hostsPath" "$hostsFolder/hosts.bak"
hostsContent=$(cat $hostsFolder/hosts.bak)
hostsContent=$(echo "$hostsContent" | grep -v "${jsondata["DnsSuffix"]}")
hostsContent+=$'\n'

for host in "${!hostsJsonData[@]}"; do
    hostname=$host
    ipAddress=${hostsJsonData[$host]}
    hostsContent+="$ipAddress $hostname"$'\n'
done

echo "$hostsContent" > "$hostsPath"