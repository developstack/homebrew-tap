#!/usr/bin/env bash
# update-formula.sh —— 取 dev-cli 的最新 release，重新生成 Formula/dev-cli.rb。
#
# 学习点（为什么由 tap 侧拉，而不是 dev-cli 侧推）：
# 跨仓库写入需要一个有权限的 token（PAT/App），而 GitHub 的默认 `GITHUB_TOKEN`
# **只能写当前仓库**。改成 tap 侧主动拉：dev-cli 是公开仓，API 无需鉴权，
# 于是整个自动更新**不需要任何额外凭据**。
set -euo pipefail

REPO="developstack/dev-cli"
FORMULA="Formula/dev-cli.rb"
DESC="把 aidevstack 平台的项目配置（技能、模型网关）同步到本地 AI 编码工具"

# ── 取最新 release 的 tag ──
TAG=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
[ -n "$TAG" ] || { echo "取最新版本失败" >&2; exit 1; }
VERSION="${TAG#v}"
echo "最新版本：${TAG}"

# ── 逐个平台算 sha256 ──
sha_of() {
  local platform="$1" tmp
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/$REPO/releases/download/$TAG/dev-cli_${platform}.tar.gz" \
    -o "$tmp/pkg.tar.gz"
  if command -v sha256sum >/dev/null; then sha256sum "$tmp/pkg.tar.gz" | awk '{print $1}';
  else shasum -a 256 "$tmp/pkg.tar.gz" | awk '{print $1}'; fi
  rm -rf "$tmp"
}

DARWIN_ARM=$(sha_of darwin_arm64)
DARWIN_AMD=$(sha_of darwin_amd64)
LINUX_ARM=$(sha_of linux_arm64)
LINUX_AMD=$(sha_of linux_amd64)
echo "sha256 已计算"

# ── 渲染 formula ──
mkdir -p "$(dirname "$FORMULA")"
cat > "$FORMULA" <<EOF
class DevCli < Formula
  desc "$DESC"
  homepage "https://github.com/$REPO"
  version "$VERSION"
  license "MIT"

  # 本文件由 scripts/update-formula.sh 自动生成（见 .github/workflows/update-formula.yml）。
  # 手工改动会在下次发版时被覆盖。
  on_macos do
    on_arm do
      url "https://github.com/$REPO/releases/download/v#{version}/dev-cli_darwin_arm64.tar.gz"
      sha256 "$DARWIN_ARM"
    end
    on_intel do
      url "https://github.com/$REPO/releases/download/v#{version}/dev-cli_darwin_amd64.tar.gz"
      sha256 "$DARWIN_AMD"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/$REPO/releases/download/v#{version}/dev-cli_linux_arm64.tar.gz"
      sha256 "$LINUX_ARM"
    end
    on_intel do
      url "https://github.com/$REPO/releases/download/v#{version}/dev-cli_linux_amd64.tar.gz"
      sha256 "$LINUX_AMD"
    end
  end

  def install
    bin.install "dev-cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dev-cli version")
  end
end
EOF
echo "已写入 ${FORMULA}（版本 ${VERSION}）"
