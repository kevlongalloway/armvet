#!/usr/bin/env bash
set -e

DOMAIN="${SITE_DOMAIN:-armvet.com}"

mkdir -p dist
sed "s|__SITE_DOMAIN__|${DOMAIN}|g" index.html > dist/index.html
cp -r images dist/

echo "Built with domain: ${DOMAIN}"
