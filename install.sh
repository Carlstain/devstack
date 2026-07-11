#!/usr/bin/env bash
# Installs devstack: symlinks the CLI onto $PATH and checks for its runtime deps.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

chmod +x "$REPO_DIR/devstack"
mkdir -p "$BIN_DIR"
ln -sf "$REPO_DIR/devstack" "$BIN_DIR/devstack"
echo "devstack -> $BIN_DIR/devstack (symlinked from $REPO_DIR)"

case ":$PATH:" in
  *":$BIN_DIR:"*)
    ;;
  *)
    echo
    echo "warning: $BIN_DIR is not on your \$PATH."
    echo "Add this to your shell rc (~/.bashrc, ~/.zshrc, ...):"
    echo "  export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

echo
echo "Shell completion:"

MARKER="# devstack completion"

if [ -f "$HOME/.bashrc" ]; then
  if ! grep -qF "$MARKER" "$HOME/.bashrc"; then
    {
      echo ""
      echo "$MARKER"
      echo "[ -f \"$REPO_DIR/completions/devstack.bash\" ] && source \"$REPO_DIR/completions/devstack.bash\""
    } >> "$HOME/.bashrc"
    echo "  added to ~/.bashrc (open a new shell, or: source ~/.bashrc)"
  else
    echo "  already present in ~/.bashrc"
  fi
fi

if [ -f "$HOME/.zshrc" ]; then
  if ! grep -qF "$MARKER" "$HOME/.zshrc"; then
    {
      echo ""
      echo "$MARKER"
      echo "fpath=(\"$REPO_DIR/completions\" \$fpath)"
      echo "autoload -U compinit && compinit"
    } >> "$HOME/.zshrc"
    echo "  added to ~/.zshrc (open a new shell, or: source ~/.zshrc)"
  else
    echo "  already present in ~/.zshrc"
  fi
fi

echo
echo "Checking dependencies:"

if command -v docker >/dev/null 2>&1; then
  echo "  [x] docker found"
else
  echo "  [ ] docker not found - devstack needs it for docker-compose services and the Dozzle log viewer"
fi

if command -v tmux >/dev/null 2>&1; then
  echo "  [x] tmux found"
else
  echo "  [ ] tmux not found - 'devstack run' will fall back to sequential mode (no split panes)"
  echo "      install with: sudo apt install tmux"
fi

echo
echo "Try: devstack --help"
echo "Then: devstack register <project>"
