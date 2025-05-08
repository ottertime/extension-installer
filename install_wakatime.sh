#!/usr/bin/env bash
set -euo pipefail

echo -e "\e[1mWelcome to OtterTime!\e[0m"
echo -e "If you have any issues with this script, please file an issue at \e[4mhttps://github.com/ottertime/extension-installer/issues\e[0m"
echo

# Extension/Plugin identifiers
VSCODE_EXT="WakaTime.vscode-wakatime"
JETBRAINS_PID="com.wakatime.intellij.plugin"

# Get WakaTime config from env vars
API_KEY="${OTTERTIME_API_KEY:-}"
API_URL="${OTTERTIME_API_URL:-}"

# Exit if required env vars are not set
if [[ -z "$API_KEY" || -z "$API_URL" ]]; then
  echo -e "\e[31mError: OTTERTIME_API_KEY and OTTERTIME_API_URL must be set\e[0m"
  exit 1
fi

# Create ~/.wakatime.cfg
CONFIG_PATH="$HOME/.wakatime.cfg"
cat > "$CONFIG_PATH" <<EOF
[settings]
api_key = $API_KEY
api_url = $API_URL
EOF

echo -e "\e[32m✓ Wrote WakaTime config to $CONFIG_PATH\e[0m"

# Helper to install in VSCode-based editors
install_vscode_ext() {
  local cmd="$1"; shift
  if command -v "$cmd" >/dev/null 2>&1; then
    echo -e "\n\e[32m→ Installing WakaTime for $cmd...\e[0m"
    "$cmd" --install-extension "$VSCODE_EXT" --force
  else
    echo -e "\e[90m$cmd CLI not found; skipping.\e[0m"
  fi
}

# 1. VSCode
install_vscode_ext code

# 2. Trae AI
install_vscode_ext trae

# 3. Cursor
install_vscode_ext cursor

# 4. Windsurf
install_vscode_ext windsurf

# 5. JetBrains IDEs
JETBRAINS_EXES=(
  idea
  pycharm
  clion
  goland
  webstorm
  rider
  datagrip
  phpstorm
  rubymine
  appcode
  rustrover
)

found_jetbrains=false
for exe in "${JETBRAINS_EXES[@]}"; do
  if command -v "$exe" >/dev/null 2>&1; then
    found_jetbrains=true
    echo -e "\n\e[32m→ Installing WakaTime plugin in $exe...\e[0m"
    "$exe" installPlugins "$JETBRAINS_PID"
  fi
done

if ! $found_jetbrains; then
  echo -e "\e[90mNo JetBrains IDEs found; skipping.\e[0m"
fi

echo -e "\n\e[32m✓ Installation complete!\e[0m"
echo "Please restart your editors/IDEs for changes to take effect."
