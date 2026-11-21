#!/usr/bin/env bash
# Build the public-only _site folder (same rules as .github/workflows/deploy.yml).
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf _site
mkdir -p _site/assets
cp index.html friends.html personal-notes.html _site/
cp -R css js _site/
css_version=$(sha256sum css/style.css | cut -c1-12)
js_version=$(sha256sum js/main.js | cut -c1-12)
sed -i -e "s|./css/style.css\"|./css/style.css?v=$css_version\"|" \
       -e "s|./js/main.js\"|./js/main.js?v=$js_version\"|" _site/index.html _site/friends.html
find assets -maxdepth 1 -type f \( -iname '*.svg' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' -o -iname '*.mp4' -o -iname '*.webm' -o -iname '*.vtt' \) -exec cp {} _site/assets/ \;
for dir in assets/*/; do
  [ -d "$dir" ] || continue
  case "$dir" in "assets/iCloud Photos/") continue ;; esac
  cp -R "$dir" _site/assets/
done
if find _site \( -iname 'profile_cindy.txt' -o -iname 'private_records' -o -iname 'iCloud Photos' -o -iname 'conf_token.txt' \) | grep -q .; then
  echo "Protected content leaked into _site" >&2; exit 1
fi
echo "Staged $(find _site -type f | wc -l) files, $(du -sh _site | cut -f1)"
