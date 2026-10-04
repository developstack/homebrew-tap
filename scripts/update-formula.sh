#!/usr/bin/env bash
# update-formula.sh —— 取 developstack/dev-cli 的最新 release，重新生成 Formula/dev-cli.rb。
#
# developstack/dev-cli 从 2.x 起只放二进制发布：源码在平台主仓（私有）的 cli/，主仓发布流水线把同一批产物
# 同步到 dev-cli 的 Release v<semver>（含 checksums.txt）。sha256 直接取 checksums.txt，不重新下载各平台的包。
#
# 为什么由 tap 侧拉，而不是发布侧推：跨仓库写入需要额外的 PAT / App 令牌，而 GitHub 的默认 GITHUB_TOKEN
# 只能写当前仓库。dev-cli 是公开仓，API 与下载都无需鉴权，于是自动更新不需要任何额外凭据（代价：最多晚一小时）。
set -euo pipefail

REPO="developstack/dev-cli"
FORMULA="Formula/dev-cli.rb"
DESC="用团队平台的模型、技能与 MCP 配置启动本地编码 agent（pi / Claude Code）"

# ── 取最新 release 的 tag（GitHub 的 latest 自动排除草稿与预发布）──
# 先整体读进变量再解析：curl | grep -m1 在 pipefail 下会因 grep 提前退出让 curl 写管道失败（exit 23）。
latest_json=$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  "https://api.github.com/repos/$REPO/releases/latest")
TAG=$(printf '%s\n' "$latest_json" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/' || true)
case "$TAG" in
  v[0-9]*) ;;
  *) echo "取最新版本失败（tag_name=${TAG:-空}）" >&2; exit 1 ;;
esac
VERSION="${TAG#v}"
echo "最新版本：${TAG}"

# ── 从 checksums.txt 取各平台 sha256 ──
checksums=$(curl -fsSL "https://github.com/$REPO/releases/download/$TAG/checksums.txt")
sha_of() {
  local file="dev-cli_$1.tar.gz" sum
  sum=$(printf '%s\n' "$checksums" | awk -v f="$file" '$2 == f { print $1 }')
  [[ "$sum" =~ ^[0-9a-f]{64}$ ]] || { echo "checksums.txt 里没有 $file 的 sha256" >&2; exit 1; }
  printf '%s' "$sum"
}

DARWIN_ARM=$(sha_of darwin_arm64)
DARWIN_AMD=$(sha_of darwin_amd64)
LINUX_ARM=$(sha_of linux_arm64)
LINUX_AMD=$(sha_of linux_amd64)
echo "sha256 已从 checksums.txt 读取"

# ── 渲染 formula ──
mkdir -p "$(dirname "$FORMULA")"
cat > "$FORMULA" <<RUBY
class DevCli < Formula
  desc "$DESC"
  homepage "https://github.com/$REPO"
  version "$VERSION"
  license "MIT"

  # 本文件由 scripts/update-formula.sh 自动生成（见 .github/workflows/update-formula.yml），手工改动会在下次发版时被覆盖。
  # 产物是 developstack/dev-cli Release 里的预编译二进制（源码在平台主仓，2.x 起本 formula 不从源码构建）。
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
RUBY
echo "已写入 ${FORMULA}（版本 ${VERSION}）"
