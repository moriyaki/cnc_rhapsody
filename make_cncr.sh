#!/usr/bin/env bash
# 📝 Usage: ./make_epub.sh <basename> [--png]
#        basename.md を EPUB化。--png で basename.png を使用。
set -e

# 引数処理
BASENAME="cnc_rhapsody"
USE_PNG=false
if [[ -z "$BASENAME" ]]; then
  echo "Usage: $0 <basename> [--png]"
  exit 1
fi
if [[ "$2" == "--png" ]]; then
  USE_PNG=true
fi

# 📄 テンポラリファイル作成
TMP_METADATA=$(mktemp)
TMP_STYLE=$(mktemp)
trap 'rm -f "$TMP_METADATA" "$TMP_STYLE"' EXIT

# 📑 metadata 出力
COVER_IMAGE="$BASENAME.jpg"
[[ "$USE_PNG" == true ]] && COVER_IMAGE="$BASENAME.png"

cat <<EOF > "$TMP_METADATA"
---
page-progression-direction: rtl
cover-image: $COVER_IMAGE
---
EOF

# 🎨 style.css 出力
cat <<'EOF' > "$TMP_STYLE"
html,body {
  -webkit-writing-mode: vertical-rl;
  -epub-writing-mode: vertical-rl;
  writing-mode: vertical-rl;
}

ol.toc {
  list-style-type: none !important;
  padding-left: 0;
}
ol.toc > li::marker {
  content: '' !important;
}

h1 {
  font-size: 2.5em;
  line-height: 1.2;
}

h2, h3 {
  page-break-before: always;
  break-before: page;
  -epub-break-before: page;
}

img {
  page-break-before: auto;
  page-break-after: auto;
  break-before: auto;
  break-after: auto;
  max-width: 80%;
}
EOF

# 📘 EPUB生成
pandoc \
  "${BASENAME}.md" \
  "$TMP_METADATA" \
  --toc \
  --css="$TMP_STYLE" \
  --from=markdown+hard_line_breaks \
  -o "${BASENAME}.epub"

echo "$BASENAME.epub 出力完了"
