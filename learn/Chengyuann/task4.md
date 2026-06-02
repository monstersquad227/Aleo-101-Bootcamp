# Task 4 - 用起来：真实场景落地

将你的 Aleo 应用部署到测试网并完成一次链上交互，提交相关代码、测试网合约地址和链上交互截图。

## 应用名称

Private Score Pass

## 测试网程序 ID

```text
chengyuann_score_pass.aleo
```

## 代码位置

```text
learn/Chengyuann/private_score_pass/
```

## 本地验证状态

已完成本地 Leo 编译、运行和测试。

本地环境：

```text
leo 4.1.0
```

本地命令：

```bash
leo build --path learn/Chengyuann/private_score_pass
leo run check_score 88u8 60u8 --path learn/Chengyuann/private_score_pass
leo run check_score 52u8 60u8 --path learn/Chengyuann/private_score_pass
leo test --path learn/Chengyuann/private_score_pass
```

本地结果：

```text
check_score 88u8 60u8 => true
check_score 52u8 60u8 => false
3 / 3 tests passed.
```

## 测试网部署步骤

真实部署需要使用本人 Aleo 钱包私钥签名，并确保账户中有测试网 credits。私钥、助记词和 view key 不能提交到仓库，也不应发到聊天中。

推荐流程：

1. 安装 Shield Wallet。
2. 创建或导入 Aleo 钱包。
3. 切换到 Aleo Testnet。
4. 在 faucet 获取测试币。
5. 在本地终端临时设置私钥环境变量。
6. 执行部署和一次链上交互。

部署命令：

```bash
export PRIVATE_KEY="<YOUR_PRIVATE_KEY>"
leo deploy \
  --path learn/Chengyuann/private_score_pass \
  --network testnet \
  --endpoint https://api.explorer.provable.com/v1 \
  --broadcast
```

链上交互命令：

```bash
leo execute check_score 88u8 60u8 \
  --path learn/Chengyuann/private_score_pass \
  --network testnet \
  --endpoint https://api.explorer.provable.com/v1 \
  --broadcast
```

## 当前测试网部署状态

已完成真实 Aleo Testnet 部署和一次链上交互。

部署信息：

```text
Program ID: chengyuann_score_pass.aleo
Owner: aleo1d2sfwzjgtamz72tjjrpjcqq7ca6hr0n2tr8ksdkqvenna0z7m5zssz8ch5
Deployment transaction ID: at1pkzwmx89lmwma47vuqy6ygscnen77t08dnkaae5xpe9y5h8aav8qsap43x
Fee transaction ID: at126tldh7nuyqe4emqy6dt5hjtrrd3v4e4pk9mcmqllhsc72e8kq9q2ktqtv
```

链上交互信息：

```text
Function: check_score
Input: 88u8(private), 60u8(public)
Output: true
Execution transaction ID: at1lzpurkj84w07h3vnu6fu7q6swwdrmdteczgkjgcmn8yjyl8rxsxsx9xdym
Fee transaction ID: at1n348he7nedzcpw9k2sneczpf2xaaqg2pzzztv73t2awlarcgdgqs2fqyuh
```

测试网查询：

```text
https://api.explorer.provable.com/v1/testnet/program/chengyuann_score_pass.aleo
https://api.explorer.provable.com/v1/testnet/transaction/at1pkzwmx89lmwma47vuqy6ygscnen77t08dnkaae5xpe9y5h8aav8qsap43x
https://api.explorer.provable.com/v1/testnet/transaction/at1lzpurkj84w07h3vnu6fu7q6swwdrmdteczgkjgcmn8yjyl8rxsxsx9xdym
```

## 测试网合约地址

```text
chengyuann_score_pass.aleo
```

## 链上交互截图

```text
Deployment confirmed and execution confirmed. 链上交互截图见 private_score_pass/chain-interaction-screenshot.png。
```
