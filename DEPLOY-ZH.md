# DATUMARK 部署步骤

1. 在 GitHub 新建一个空的公开仓库，例如 `datumark`。不要额外创建 README、License 或 `.gitignore`。
2. 上传本项目解压后的全部内容，仓库根目录应包含 `contracts`、`frontend` 和本说明。
3. 在 Vercel 导入仓库，Root Directory 选择 `frontend`，Framework Preset 选择 Vite。
4. 先完成一次预览部署。
5. 在 Remix 新建 `Datumark.sol`，复制 `contracts/src/Datumark.sol` 全部内容。
6. Solidity Compiler 选择 0.8.24，点击 Compile Datumark.sol。
7. 在 Deploy & Run Transactions 中选择 Browser Extension / MetaMask，并切换到 BOT Chain（Chain ID 677）。
8. 选择 `Datumark - Datumark.sol`，点击 Deploy；构造函数没有参数。
9. 复制完整合约地址，在 Vercel 添加环境变量：
   - Type：Config
   - Key：`VITE_DATUMARK_ADDRESS`
   - Value：完整合约地址
   - Environment：Production
10. 如需网页直接上传到 IPFS，再添加：
   - Type：Secret
   - Key：`PINATA_JWT`
   - Value：你自己的 Pinata JWT
   - Environment：Production
11. 保存后 Redeploy Production，不使用旧 Build Cache。

## 交互顺序

1. CONNECT WALLET。
2. 第一次使用先创建 Cabinet。
3. 打开 NEW RECORD：
   - UPLOAD FILE：文件先经过 Vercel 服务端上传到 IPFS，然后保存链上记录。
   - EXISTING URI：已有 `ipfs://...` 地址时直接保存记录，不需要 Pinata JWT。
4. 返回 INDEX 查看文件记录，支持打开、复制 URI 和移除链上记录。

## 安全提示

- `PINATA_JWT` 必须设置为 Secret，绝对不要使用 `VITE_PINATA_JWT`，否则会暴露给浏览器。
- 合约只保存公开元数据，不保存文件字节。
- IPFS 文件是公开的，而且删除链上记录后仍可能继续被访问。敏感文件必须先在本地加密。
- 项目未经专业安全审计，请先使用测试文件和少量测试操作。