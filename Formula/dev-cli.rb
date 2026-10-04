class DevCli < Formula
  desc "用团队平台的模型、技能与 MCP 配置启动本地编码 agent（pi / Claude Code）"
  homepage "https://github.com/developstack/dev-cli"
  version "2.0.1"
  license "MIT"

  # 本文件由 scripts/update-formula.sh 自动生成（见 .github/workflows/update-formula.yml），手工改动会在下次发版时被覆盖。
  # 产物是 developstack/dev-cli Release 里的预编译二进制（源码在平台主仓，2.x 起本 formula 不从源码构建）。
  on_macos do
    on_arm do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_darwin_arm64.tar.gz"
      sha256 "557faff790b35a1b34bc8abb482de11a1f7348790447c19800aab31c7e57856f"
    end
    on_intel do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_darwin_amd64.tar.gz"
      sha256 "f0fc2af019006c1cc5163566a13e1962323c7e08460a28413befca56743e5dcf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_linux_arm64.tar.gz"
      sha256 "1a253e643f7f92539b7e17ec3b24a35a9391e4bbb551f1f1dc5ea0da913ca971"
    end
    on_intel do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_linux_amd64.tar.gz"
      sha256 "9c17ea75fc2cec53ab5252adc2415dff821729df017312ef5f7d1506cbb7f438"
    end
  end

  def install
    bin.install "dev-cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dev-cli version")
  end
end
