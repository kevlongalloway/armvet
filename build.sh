#!/usr/bin/env bash
set -e

DOMAIN="${SITE_DOMAIN:-armvet.com}"
EMAILJS_PUBLIC_KEY="${EMAILJS_PUBLIC_KEY:-}"
EMAILJS_SERVICE_ID="${EMAILJS_SERVICE_ID:-}"
EMAILJS_OWNER_TEMPLATE_ID="${EMAILJS_OWNER_TEMPLATE_ID:-}"
EMAILJS_CONFIRM_TEMPLATE_ID="${EMAILJS_CONFIRM_TEMPLATE_ID:-}"

mkdir -p dist
sed \
  -e "s|__SITE_DOMAIN__|${DOMAIN}|g" \
  -e "s|__EMAILJS_PUBLIC_KEY__|${EMAILJS_PUBLIC_KEY}|g" \
  -e "s|__EMAILJS_SERVICE_ID__|${EMAILJS_SERVICE_ID}|g" \
  -e "s|__EMAILJS_OWNER_TEMPLATE_ID__|${EMAILJS_OWNER_TEMPLATE_ID}|g" \
  -e "s|__EMAILJS_CONFIRM_TEMPLATE_ID__|${EMAILJS_CONFIRM_TEMPLATE_ID}|g" \
  index.html > dist/index.html
cp -r images dist/
rm -f dist/images/og-preview.svg

echo "Built with domain: ${DOMAIN}"
