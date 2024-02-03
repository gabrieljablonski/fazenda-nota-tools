#!/bin/bash

####
## Dependencies
## - jq
####

LIBACBR_NFE_URL="https://github.com/gabrieljablonski/fazenda-nota-tools/raw/main/libacbrnfe64.so.gz"
LIBACBR_MDFE_URL="https://github.com/gabrieljablonski/fazenda-nota-tools/raw/main/libacbrmdfe64.so.gz"
LIBACBR_NFE_INI_URL="https://github.com/gabrieljablonski/fazenda-nota-tools/raw/main/libacbr.ini"
LIBACBR_MDFE_INI_URL="https://github.com/gabrieljablonski/fazenda-nota-tools/raw/main/libacbr-mdfe.ini"
SCHEMAS_URL="https://github.com/gabrieljablonski/fazenda-nota-tools/raw/main/Schemas.tgz"
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
    error_file : \"`pwd`/error.log\",
    out_file : \"`pwd`/out.log\",
    env: {
      DISPLAY: \":1\",
      NEW_RELIC_APP_NAME: \"FazendaNota\",
      NEW_RELIC_LICENSE_KEY: \"<NEW RELIC LICENSE KEY>\"
    },
    node_args: \"--require=newrelic\"
  }]
}
" > ecosystem.config.js

if [ ! -d "lib" ]; then
  wget --no-check-certificate "$LIBACBR_NFE_URL"
  wget --no-check-certificate "$LIBACBR_MDFE_URL"
  wget --no-check-certificate "$LIBACBR_NFE_INI_URL"
  wget --no-check-certificate "$LIBACBR_MDFE_INI_URL"
  gunzip "libacbrnfe64.so.gz"
  gunzip "libacbrmdfe64.so.gz"
  mkdir lib
  mv "libacbrnfe64.so" "libacbrmdfe64.so" lib/
fi

if [ ! -d "Schemas" ]; then
  wget --no-check-certificate "$SCHEMAS_URL"
  tar -xvf "Schemas.tgz"
  rm "Schemas.tgz"
fi

cwd=`pwd | sed 's/\\//\\\\\//g'`
sed "s/^FAZENDA_NOTA_RESOURCES_PATH=.*$/FAZENDA_NOTA_RESOURCES_PATH=$cwd\/$tag_name\/resources\//" -i .env

sed "s/^FAZENDA_NOTA_FRONTEND_MIN_VERSION=/#FAZENDA_NOTA_FRONTEND_MIN_VERSION=/" -i .env

cp .env "$tag_name/.env"
cp libacbr.ini "$tag_name/libacbr.ini"
cp libacbr-mdfe.ini "$tag_name/libacbr-mdfe.ini"

if [ ! -d "node_modules" ]; then
  cp "$tag_name/package.json" .
  npm i
fi

ln -s "`pwd`/node_modules" "$tag_name/node_modules"
