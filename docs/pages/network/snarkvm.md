---
id: snarkvm 
title: SnarkVM
sidebar_label: SnarkVM
---

snarkVM 库允许用户通过利用零知识简洁非交互式知识论证（zk-SNARKs）和加密技术，以高效且隐私保护的方式编写和执行交易。

这创造了一个链下、无需信任的计算环境，程序可以在其中私密、安全地执行，并且运行时间不受限制。

## 谁使用 snarkVM？
- `开发者` - 利用 snarkVM 创建支持私密 dApp 的 aleo 程序。
- `用户` - 通过计算 zk-SNARKs 和加密链下数据获得隐私保护。
- `验证者` - 使用 Varuna 验证用户提交的交易。

## 架构组件
- `snarkVM 综合器` - 用于将代码转换为与底层 zk-SNARK 密码学证明系统（Varuna）兼容的电路。
- `snarkVM 算法` - 证明系统及其支持原语的实现和执行。
- `snarkVM 账本` - 支持与 Aleo 区块链进行存储和交互的数据结构和方法。
