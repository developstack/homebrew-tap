# developstack Homebrew tap

```bash
brew install developstack/tap/dev-cli
```

## 可用 formula

| Formula | 说明 |
|---|---|
| `dev-cli` | 把 [aidevstack](https://github.com/developstack/aidevstack) 平台的项目配置（技能、模型网关）同步到本地 AI 编码工具 |

## 升级

```bash
brew upgrade dev-cli
```

## 这个 tap 怎么维护的

`Formula/dev-cli.rb` 是**自动生成**的（见 `scripts/update-formula.sh`），触发方式：

| 触发 | 场景 |
|---|---|
| `schedule`（每小时 23 分） | **主路径**：轮询最新 release |
| `workflow_dispatch` | 手动立刻更新 |
| `repository_dispatch`（`dev-cli-released`） | 可选：有令牌时立刻更新 |

**为什么由 tap 侧主动拉**：跨仓库写入/触发都需要 PAT / GitHub App 令牌，而默认的 `GITHUB_TOKEN`
只能写当前仓。dev-cli 是公开仓、API 免鉴权 —— 用轮询就把自动更新做到了**零额外凭据**，
代价是最多晚一小时（`brew upgrade` 本来也不着急）。

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

# ② 或者干脆不用 brew —— dev-cli 官方支持一行脚本 / go install
curl -fsSL https://raw.githubusercontent.com/developstack/dev-cli/main/install.sh | sh
go install github.com/developstack/dev-cli@latest
```

> 想让 `brew install` 对所有人都免工具链，需要给本 tap 配 **bottle**（Homebrew 标准 CI：`test-bot` 构建 → `pr-pull` 发布到 GHCR）。目前没做。

## 卸载

```bash
brew uninstall dev-cli
```
