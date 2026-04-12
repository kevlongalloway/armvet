#!/usr/bin/env bash
set -e

DOMAIN="${SITE_DOMAIN:-armvet.com}"
API_URL="${VITE_API_URL:-}"

mkdir -p dist
sed "s|__SITE_DOMAIN__|${DOMAIN}|g; s|__API_URL__|${API_URL}|g" index.html > dist/index.html
cp -r images dist/
rm -f dist/images/og-preview.svg

echo "Built with domain: ${DOMAIN}"
echo "Built with API URL: ${API_URL:-[not set — forms will be inactive]}"
