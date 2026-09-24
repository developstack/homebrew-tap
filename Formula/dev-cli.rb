class DevCli < Formula
  desc "把 aidevstack 平台的项目配置（技能、模型网关）同步到本地 AI 编码工具"
  homepage "https://github.com/developstack/dev-cli"
  version "0.2.0"
  license "MIT"

  # 本文件由 scripts/update-formula.sh 自动生成（见 .github/workflows/update-formula.yml）。
  # 手工改动会在下次发版时被覆盖。
  on_macos do
    on_arm do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_darwin_arm64.tar.gz"
      sha256 "6d71058e28d2ad05a259a442e43fb48b331a762c600da801a8c3ee3cd87d298a"
    end
    on_intel do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_darwin_amd64.tar.gz"
      sha256 "d00e1b4a852c4be1627e1c6dd327a39f6abdcc6cbef06621732b7d4a3389419b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_linux_arm64.tar.gz"
      sha256 "f5c0a8731e5a766a68c3ed23c064f2250eb9e1e1d309cb28f5b4b91c35c7a9cd"
    end
    on_intel do
      url "https://github.com/developstack/dev-cli/releases/download/v#{version}/dev-cli_linux_amd64.tar.gz"
      sha256 "8279dc6a3787da0349f5d69c6275e9dfc8ed8252993e8c2b98ceed23f91008b9"
    end
  end

  def install
    bin.install "dev-cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dev-cli version")
  end
end
