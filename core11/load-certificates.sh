#!/bin/bash
set -e

#### take input and return an valid alias
# parameter $1 consul key name
generate_alias() {
  #echo "Building alias for $1"
  ALIAS=$1
  # strip off /config/certs
  ALIAS=${ALIAS:13}
  POS=$(expr index "$ALIAS" .)
  POS=$((POS-1))
  #echo "$POS" >&2
  ALIAS=${ALIAS:0:$POS}

  POS=2  # Starting from position 2 in the string.
  LEN=8  # Extract eight characters.

  str0="$$"
  str1=$( echo "$str0" | md5sum | md5sum )
  #  Doubly scramble     ^^^^^^   ^^^^^^
  #+ by piping and repiping to md5sum.

  randstring="${str1:$POS:$LEN}"
  ALIAS="$ALIAS$randstring"
  #echo "$ALIAS" >&2
  echo "$ALIAS"
}

#### load file into DOTNET truststore location
# parameter $1 consul key name
# parameter $2 consul key value
# parameter $3 key extension
load_certificate() {
  KEYNAME="$1"
  #echo "loading certificate $KEYNAME..."
  ALIAS=$(generate_alias "$KEYNAME")
  CERTFILE="/usr/local/share/ca-certificates/$ALIAS.$3"
  echo "$2" > "$CERTFILE"
}

echo "Installing certificates from consul to DOTNET truststore..."

if [[ -z "${IP_ADDRESS}" ]]; then
  echo "IP_ADDRESS environment variable is not defined - unable to load certificates. Event Code: Global_Key_Not_Found"
  exit 1
else
  IP_ADDRESS="${IP_ADDRESS}"
fi

declare -A kv
CERTS=$(curl --no-progress-meter http://"$IP_ADDRESS":8500/v1/kv/config/certs?recurse=true | jq -r 'to_entries|map("kv[\(.value.Key)]=\(.value.Value)")|.[]')
eval "$CERTS"

KEYSCOUNT=${#kv[@]}
if [[ KEYSCOUNT -eq 0 ]]; then
  echo "No certificates found in consul (config/certs).  Continuing..."
fi

for key in "${!kv[@]}"; do
  #echo "[$key]=${kv[$key]}"
  #echo "$key"

  DECODED=$(echo "${kv[$key]}" | base64 --decode)
  if [[ $key == *".pem" ]]; then
    echo "Loading pem file $key"
    load_certificate "$key" "$DECODED" "pem"
  elif [[ $key == *".crt" ]]; then
    echo "Loading crt file $key"
    load_certificate "$key" "$DECODED" "crt"
  elif [[ $key == *".key" ]]; then
    echo "Loading key file $key"
    load_certificate "$key" "$DECODED" "key"
  elif [[ $key == *".pfx" ]]; then
    echo "Loading key file $key"
    load_certificate "$key" "$DECODED" "pfx"
  elif [[ $key == *".cer" ]]; then
    echo "Loading key file $key"
    load_certificate "$key" "$DECODED" "cer"
  else
    echo "$key is not a valid type - continuing..."
  fi
done

## now that the certs are put onto the disk, load them
update-ca-certificates
