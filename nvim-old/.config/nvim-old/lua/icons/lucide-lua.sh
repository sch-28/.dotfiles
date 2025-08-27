#!/usr/bin/env bash

ICON_DIR="./icons"
OUT_FILE="lucide-icons.lua"

echo "return {" > "$OUT_FILE"

for json_file in "$ICON_DIR"/*.json; do
  base_name=$(basename "$json_file" .json)
  svg_file="$base_name.svg"

  # Parse JSON fields using jq
  name="$base_name"
  category=$(jq -r '.categories // []' "$json_file")
  tags=$(jq -c '.tags // []' "$json_file")

  # Format Lua table
  echo "  {" >> "$OUT_FILE"
  echo "    name = \"$name\"," >> "$OUT_FILE"

  # Convert JSON array to Lua table
  lua_tags=$(echo $tags | sed 's/\[/\{/g; s/\]/\}/g; s/,/,\n    /g' | sed 's/^/    /')
  lua_categories=$(echo $category | sed 's/\[/\{/g; s/\]/\}/g; s/,/,\n    /g' | sed 's/^/    /')
  echo "    tags = $lua_tags," >> "$OUT_FILE"
  echo "    categories = $lua_categories," >> "$OUT_FILE"
  echo "  }," >> "$OUT_FILE"
done

echo "}" >> "$OUT_FILE"

echo "✅ Lua table generated at: $OUT_FILE"
