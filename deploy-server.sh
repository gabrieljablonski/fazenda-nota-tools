#!/bin/bash

####
## Dependencies
## - jq
####

RELEASES_URL="https://api.github.com/repos/gabrieljablonski/fazenda-nota-server/releases"
GITHUB_PAT=$(cat .github-pat)

tag_name=$1

if [ -z "$tag_name" ]; then
  echo "Usage: $0 <tag-name>

$0 v1.0.0-alpha-qa"
  exit 1
fi

if [ -z "$GITHUB_PAT" ]; then
  echo "missing .github-pat"
  exit 2
fi

asset_url=$(curl -s -H "Authorization: token $GITHUB_PAT" "$RELEASES_URL" | jq -r ".[] | select(.tag_name == \"$tag_name\") | .assets[] | .url")

if [ -z "$asset_url" ]; then
  echo "tag $tag_name not found"
  exit 3
fi

outfile="release.tgz"
curl -s -L -H "Authorization: token $GITHUB_PAT" -H "Accept:application/octet-stream" "$asset_url" > "$outfile"

tar -xvf "$outfile"
rm "$outfile"
mv "fazenda-nota-server_"* "$tag_name"

echo "
module.exports = {
  apps : [{
    name   : \"fazenda-nota-server-$tag_name\",
    script : \"`pwd`/$tag_name/index.js\",
    env: {
      DISPLAY: \":1\"
    }
  }]
}
" > ecosystem.config.js

cd "$tag_name"
npm i
