class DevCli < Formula
  desc "用团队平台的模型、技能与 MCP 配置启动本地编码 agent（pi / Claude Code）"
  homepage "https://github.com/developstack/dev-cli"
  version "2.0.2"
  license "MIT"

  # 本文件由 scripts/update-formula.sh 自动生成（见 .github/workflows/update-formula.yml），手工改动会在下次发版时被覆盖。
  # 产物是 developstack/dev-cli Release 里的预编译二进制（源码在平台主仓，2.x 起本 formula 不从源码构建）。
  on_macos do
    on_arm do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_darwin_arm64.tar.gz"
      sha256 "a9123bc093d86bb6ddac9444f71057141728e8c38d4ea8a1c54e9c043b359cde"
    end
    on_intel do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_darwin_amd64.tar.gz"
      sha256 "58d0d77790b9941da9471507c6f0a390ebd06672b89309410ad9c8039016ffde"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_linux_arm64.tar.gz"
      sha256 "66a12fa5fd3391e8139c16f4c429880e0cd600002cda09254c32562d83527a35"
    end
    on_intel do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_linux_amd64.tar.gz"
      sha256 "d9795fbe288e0a4f67ff9d5e45b8ae0ce0bde8b2759fa61c79775aa8ea5b9cfd"
    end
  end

  def install
    bin.install "dev-cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dev-cli version")
  end
end
