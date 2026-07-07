#!/usr/bin/env zsh

set -euo pipefail

# Detect architecture
case "$(uname -m)" in
    x86_64)
        GO_ARCH="amd64"
        ;;
    aarch64|arm64)
        GO_ARCH="arm64"
        ;;
    *)
        echo "❌ Unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac

echo "Fetching latest stable Go release..."

LATEST_VERSION=$(
    curl -fsSL "https://go.dev/dl/?mode=json" |
    python3 -c '
import json, sys
releases = json.load(sys.stdin)
for release in releases:
    if release.get("stable"):
        print(release["version"][2:])  # Remove "go" prefix
        break
'
)

GO_TAR="go${LATEST_VERSION}.linux-${GO_ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_TAR}"

echo "Latest stable version: ${LATEST_VERSION}"
echo "Downloading ${GO_TAR}..."

curl -fL "$GO_URL" -o "/tmp/${GO_TAR}"

if [[ -d /usr/local/go ]]; then
    echo "Removing existing Go installation..."
    sudo rm -rf /usr/local/go
fi

echo "Installing Go..."
sudo tar -C /usr/local -xzf "/tmp/${GO_TAR}"
rm -f "/tmp/${GO_TAR}"

# Ensure PATH is present in ~/.zshrc
if ! grep -q '/usr/local/go/bin' ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc <<'EOF'

# Go
export PATH="/usr/local/go/bin:$PATH"
EOF
    echo "Added Go to ~/.zshrc"
fi

# Make Go available in this script
export PATH="/usr/local/go/bin:$PATH"

echo
echo "✅ Installation successful"
go version
echo "GOROOT: $(go env GOROOT)"
echo "GOPATH: $(go env GOPATH)"
echo

echo "Run the following to update your current shell:"
echo
echo "    source ~/.zshrc"
echo
echo "Or simply open a new terminal."
