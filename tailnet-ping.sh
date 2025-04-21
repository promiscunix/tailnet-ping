#!/usr/bin/env bash

set -euo pipefail

echo "🔍 Getting peer list from tailscale..."
echo

# Get all peer hostnames + IPs
peers=$(tailscale status --json | jq -r '
  .Peer[] | 
  {
    name: .HostName,
    ip: (.TailscaleIPs[0] // "N/A")
  } | @base64
')

if [ -z "$peers" ]; then
  echo "⚠️ No peers found in your tailnet."
  exit 1
fi

for peer in $peers; do
  _jq() { echo "$peer" | base64 --decode | jq -r "$1"; }
  name=$(_jq '.name')
  ip=$(_jq '.ip')

  if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
    echo "✅ $name ($ip) is online"
  else
    echo "❌ $name ($ip) is offline"
  fi
done

