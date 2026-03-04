# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- python=python3
alias -- run-help=man
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/lib/node_modules/\@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
fi
export PATH='/opt/homebrew/Cellar/node/23.11.0/bin:/Users/nishitbariya/.local/bin:/Users/nishitbariya/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/homebrew/Cellar/node/23.11.0/bin:/Users/nishitbariya/.local/bin:/Users/nishitbariya/.vscode/extensions/ms-python.debugpy-2025.8.0-darwin-arm64/bundled/scripts/noConfigScripts:/Users/nishitbariya/Library/Application Support/Code/User/globalStorage/github.copilot-chat/debugCommand'
