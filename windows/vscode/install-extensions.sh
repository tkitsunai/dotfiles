#!/bin/bash

EXTENSIONS_FILE="extensions.txt"

if [ ! -f "$EXTENSIONS_FILE" ]; then
  echo "Error: $EXTENSIONS_FILE not found!"
  exit 1
fi

cat "$EXTENSIONS_FILE" | xargs -n 1 code --install-extension

echo "All extensions installed successfully."
