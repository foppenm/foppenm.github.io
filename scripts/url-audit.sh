#!/usr/bin/env bash
# URL preservation audit.
#
# Builds the current site and compares all *.html paths against the
# baseline checked out in ../public-blog. Any baseline path missing
# from the new build is a regression and exits non-zero.
#
# Excluded from the comparison: 404.html, generated index pages that
# are not user-facing canonical URLs (none today; revisit if added).
#
# Usage:
#   scripts/url-audit.sh
# Optional env:
#   PUBLIC_BLOG=/abs/path/to/public-blog   (defaults to ../public-blog)

set -euo pipefail

PUBLIC_BLOG="${PUBLIC_BLOG:-../public-blog}"
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

if [ ! -d "$PUBLIC_BLOG" ]; then
  echo "ERROR: public-blog not found at $PUBLIC_BLOG" >&2
  exit 2
fi

echo "Building site to $BUILD_DIR ..."
bundle exec jekyll build --destination "$BUILD_DIR" --quiet

echo "Collecting baseline URLs from $PUBLIC_BLOG ..."
BASELINE=$(mktemp)
( cd "$PUBLIC_BLOG" && find . -type f -name '*.html' \
    ! -name '404.html' \
    | sed 's|^\./||' | sort ) > "$BASELINE"

echo "Collecting new build URLs ..."
NEW=$(mktemp)
( cd "$BUILD_DIR" && find . -type f -name '*.html' \
    ! -name '404.html' \
    | sed 's|^\./||' | sort ) > "$NEW"

MISSING=$(comm -23 "$BASELINE" "$NEW" || true)
ADDED=$(comm -13 "$BASELINE" "$NEW" || true)

if [ -n "$ADDED" ]; then
  echo ""
  echo "New URLs in this build (informational, not a failure):"
  echo "$ADDED" | sed 's/^/  + /'
fi

if [ -n "$MISSING" ]; then
  echo ""
  echo "REGRESSION: baseline URLs missing from new build:" >&2
  echo "$MISSING" | sed 's/^/  - /' >&2
  rm -f "$BASELINE" "$NEW"
  exit 1
fi

rm -f "$BASELINE" "$NEW"
echo ""
echo "OK: all baseline URLs are present in the new build."
