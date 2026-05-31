---
id: snarkos 
title: SnarkOS
sidebar_label: SnarkOS
---

SnarkOS 是一个用于零知识应用的去中心化操作系统。该代码构成了 Aleo 网络的骨干，它验证交易并以可公开验证的方式存储应用程序的加密状态。

网络客户端必须处理验证使用 snarkvm 在链下计算的交易，允许所有 snarkOS 节点达成共识，并在 Aleo 的分布式账本中存储私有和非私有状态。

## Aleo 节点选项
Aleo 节点可以以三种模式运行。

- [客户端](../network/client.md)
- [证明者](../network/provers.md)
- [验证者](../network/validators.md)

### JWT 认证
snarkOS 接受用于 JWT 认证的运行时参数：

- `--jwt-secret`：可选的 base64 编码 JWT 密钥，用于令牌生成和验证
- `--jwt-timestamp`：可选的 UNIX 时间戳，用于确定令牌的有效性

#### 受保护的端点
以下端点需要有效的 JWT 认证：

- `/{network}/node/address` - 获取节点地址信息
- `/{network}/program/{id}/mapping/{name}` - 访问程序映射数据
- `/{network}/db_backup?path={path}` - 数据库备份操作

## 谁使用 snarkOS？
所有参与 Aleo 的人都使用 snarkOS 来提交交易和获取数据。
