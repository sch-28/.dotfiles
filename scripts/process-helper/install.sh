#!/bin/sh
set -eu
cd "$HOME/.dotfiles/scripts/process-helper"
mvn -q clean package
install -d "$HOME/.local/share/process-helper"
install -m 644 target/process-helper-1.0-SNAPSHOT.jar "$HOME/.local/share/process-helper/process-helper.jar"

