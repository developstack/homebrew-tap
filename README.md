# developstack Homebrew tap

```bash
brew install developstack/tap/dev-cli
```

## 可用 formula

| Formula | 说明 |
|---|---|
| `dev-cli` | dev-cli 2.x：用团队平台的模型、技能与 MCP 配置启动本地编码 agent（pi / Claude Code）。预编译二进制取自 [developstack/dev-cli](https://github.com/developstack/dev-cli/releases) 的 Release（源码在平台主仓） |

## 升级

```bash
brew upgrade dev-cli      # 已装 0.x 的直接升级到 2.x；0.x 的本地状态（.dev-cli/、~/.config/dev-cli）2.x 不读取，可自行删除
```

## 这个 tap 怎么维护的

`Formula/dev-cli.rb` 是**自动生成**的（见 `scripts/update-formula.sh`），触发方式：

| 触发 | 场景 |
|---|---|
| `schedule`（每小时 23 分） | **主路径**：轮询 developstack/dev-cli 的 latest release，sha256 取自其 `checksums.txt` |
| `workflow_dispatch` | 手动立刻更新 |
| `repository_dispatch`（`dev-cli-released`） | 可选：有令牌时立刻更新 |

**为什么由 tap 侧主动拉**：跨仓库写入/触发都需要 PAT / GitHub App 令牌，而默认的 `GITHUB_TOKEN`
只能写当前仓。dev-cli 是公开仓、API 免鉴权 —— 用轮询就把自动更新做到了**零额外凭据**，
代价是最多晚一小时（`brew upgrade` 本来也不着急）。

> GitHub 会在公开仓**连续 60 天无活动**后自动停用 `schedule`。长时间没发版后，若新版本一小时内没跟上，
> 到 Actions 页重新启用 update-formula（`gh workflow enable update-formula -R developstack/homebrew-tap`）并手动触发一次
> （`gh workflow run update-formula -R developstack/homebrew-tap`）。

## 如果 `brew install` 报 "Xcode/Command Line Tools is too outdated"

**这不是 formula 的问题**，而是 Homebrew 对**没有 bottle 的 formula** 的要求：

| formula | 有官方 bottle？ | `brew install` 需要工具链？ |
|---|---|---|
| `jq`、`git` 等 | ✅ | ❌ 直接 "Pouring" 预编译包 |
| `dev-cli`（本 tap） | ❌ | ✅ 走"源码构建"路径 → 要求 Xcode/CLT 是新的 |

两条路：

```bash
# ① 更新 Command Line Tools（一次性）
sudo rm -rf /Library/Developer/CommandLineTools && sudo xcode-select --install

# ② 或者干脆不用 brew —— 安装脚本（匿名下载并校验 sha256）
curl -fsSL https://github.com/developstack/dev-cli/releases/latest/download/install.sh | sh
```

> 想让 `brew install` 对所有人都免工具链，需要给本 tap 配 **bottle**（Homebrew 标准 CI：`test-bot` 构建 → `pr-pull` 发布到 GHCR）。目前没做。

## 卸载

```bash
brew uninstall dev-cli
```
