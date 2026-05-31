---
id: staking 
title: 质押
sidebar_label: 质押
---

## 什么是质押？

**质押**是一种经济安全机制，用于保护依赖**权益证明（PoS）**作为共识机制的去中心化网络。与**工作量证明（PoW）**不同，在 PoW 中矿工竞争解决密码学难题来添加新区块，而 PoS 会为每个区块随机选择验证者来确认交易和验证区块数据。这种方法用基于质押的随机选择过程取代了竞争性挖矿，验证者根据其参与度而非计算能力获得奖励。

要成为验证者并参与共识，**需要最低质押 10,000,000 个 AC**。这确保了网络由对系统有重大投资的验证者来保障经济安全。然而，并非每个人都有资源单独达到此阈值。质押允许用户委托他们的 AC 来支持验证者，帮助他们成为共识过程的活跃参与者，同时分享奖励。

## 如何成为质押者？

质押者是锁定或委托 Aleo Credits (AC) 以支持验证者参与网络共识的个人或组织。作为回报，他们获得与其质押 AC 数量成比例的奖励，反映了他们对网络安全的贡献。这使得不运行验证者节点的用户仍然可以参与共识过程并获得质押奖励。质押者有时也被称为委托者，因为他们将权益委托给验证者。

任何持有 AC 的人都可以成为质押者。**[原生质押](#原生质押)从 10,000 AC 起可用**，对于持有少于 10,000 AC 的用户，也有[流动质押](#流动质押)选项可供选择。要开始，用户可以使用 Aleo 生态系统开发的各种工具——如质押平台或支持的钱包。

:::warning[免责声明]
社区工具由 Aleo 生态系统内的第三方开发。Aleo 不认可、审查或审计这些工具，用户需自行承担使用风险。
:::

## 原生质押

原生质押使代币持有者能够在链上直接质押其 Aleo Credits (AC)，无需依赖第三方程序或托管服务。原生质押功能在 `credits.aleo` 程序中提供，该程序也是托管每个 Aleo Credit 的程序。`credits.aleo` 程序中强制执行以下质押规则：

* 验证者**自绑定最低限额**（≥ 100 credits）
* 质押者**委托最低限额**（≥ 10,000 credits）
* 总质押低于 1000 万的验证者将被**自动移除**
* **时间锁定的解绑期**（360 个区块）后才能重新领取质押

Aleo 指令的源代码可以在这里找到[这里](https://github.com/ProvableHQ/snarkVM/blob/staging/synthesizer/program/src/resources/credits.aleo)。

### 功能术语表

| 函数 | 调用者 | 用途 |
|------|--------|------|
| `bond_validator` | 验证者（自绑定） | 创建验证者或补充自绑定质押，并设置佣金和提款地址 |
| `bond_public` | 质押者 | 将质押绑定（委托）到接受新质押的现有验证者 |
| `unbond_public` | 验证者或质押者 | 启动部分或全部绑定金额的解绑计时器 |
| `claim_unbond_public` | 任何人 | 计时器到期后，将解绑金额转移到质押者的提款地址 |

### 质押相关映射

Aleo 中的质押系统使用几个关键映射来跟踪验证者和委托者状态：

#### `committee`
包含活跃验证者集合及其委员会状态：
- 验证者是否接受新质押者（`is_open`）
- 验证者保留的佣金百分比（0-100）

```aleo
/// `committee` 映射包含活跃验证者集合及其相应的质押。
mapping committee:
    // 键表示验证者的地址。
    key as address.public;
    // 值表示验证者的委员会状态。
    value as committee_state.public;

// `committee_state` 结构体跟踪验证者的总质押量，以及他们是否接受新质押者。
struct committee_state:
    // 布尔标志，指示验证者是否接受新质押者。
    is_open as boolean;
    // 验证者保留的奖励百分比（从 0 到 100，包含）。
    commission as u8;
```

#### `delegated`
跟踪绑定到每个验证者地址的微 credit 总量（包括自绑定和委托者绑定）。此映射用于确定验证者是否满足加入委员会的最低 1000 万 credits 阈值。

```aleo
// `delegated` 映射跟踪预绑定和绑定到验证者地址的微 credit 总量。
// 注意：该映射包含预绑定和绑定的微 credit。但是，它不包含解绑中的微 credit。
mapping delegated:
    // 键表示验证者的地址。
    key as address.public;
    // 值表示绑定到验证者的微 credit 数量，由验证者及其委托者提供。
    value as u64.public;
```

:::note
**预绑定**微 credit 是指委托者尝试绑定到尚未包含在活跃委员会集合中的验证者地址。在这种情况下，委托者的 credit 被锁定，委托者不会积极参与质押奖励或投票。
:::

#### `metadata`
存储全局质押统计信息：
- `metadata[aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc]` - 活跃委员会成员数量
- `metadata[aleo1qgqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqanmpl0]` - 委托者数量（上限 100,000）

```aleo
/// `metadata` 映射存储：
///   - 委员会中的成员数量。
///   - 委托者的数量。
mapping metadata:
    // 键表示存储计数的索引。
    //    - 此地址 (aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc) 存储委员会中的**成员**数量。
    //    - 此地址 (aleo1qgqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqanmpl0) 存储**委托者**数量。
    key as address.public;
    // 值表示计数。
    value as u32.public;
```

#### `bonded`
将每个质押者的地址映射到其绑定状态，包括：
- 他们绑定到的验证者地址
- 当前绑定的微 credit 数量

```aleo
// `bonded` 映射表示当前绑定的微 credit 数量。
mapping bonded:
    // 键表示质押者的地址，包括验证者及其委托者。
    key as address.public;
    // 值表示绑定状态。
    value as bond_state.public;

// `bond_state` 结构体跟踪当前绑定到指定验证者的微 credit 数量。
struct bond_state:
    // 验证者的地址。
    validator as address;
    // 当前绑定到指定验证者的微 credit 数量。
    microcredits as u64;
```

#### `unbonding`
跟踪已启动解绑过程的质押者：
- 当前正在解绑的微 credit 数量
- 解绑完成时的区块高度（从启动开始 360 个区块）

```aleo
// `unbonding` 映射包含一组质押者及其解绑中的微 credit 和解锁高度。
mapping unbonding:
    // 键表示质押者的地址，包括验证者及其委托者。
    key as address.public;
    // 值表示解绑状态。
    value as unbond_state.public;

// `unbond_state` 结构体跟踪当前正在解绑的微 credit，以及解锁高度。
struct unbond_state:
    // 当前正在解绑的微 credit 数量。
    microcredits as u64;
    // 解绑完成的区块高度，此时可以领取。
    height as u32;
```

#### `withdraw`
将每个质押者的地址映射到其提款地址，奖励和解绑金额将发送到该地址。

```aleo
// `withdraw` 映射包含质押地址及其相应的提款地址。
mapping withdraw:
    // 键表示所有者的质押地址。
    key as address.public;
    // 值表示所有者的提款地址。
    value as address.public;
```

### 成为验证者或补充质押

要成为验证者或补充自绑定质押，请使用验证者地址执行 `bond_validator` 函数：

```bash
leo execute credits.aleo/bond_validator <withdrawal_address> <amount> <commission_percentage> --network mainnet --endpoint https://api.provable.com/v1 --broadcast 
```

```aleo
function bond_validator:
    // 输入提款地址。
    input r0 as address.public;
    // 输入要绑定的微 credit 数量。
    input r1 as u64.public;
    // 输入佣金百分比。
    input r2 as u8.public;
```

* **withdrawal_address** – 将接收奖励和解绑质押的单独地址。必须与验证者地址不同。
* **amount_in_microcredits** – 最少 1 AC。要进入委员会，您需要 ≥ 1000 万 ACs（自绑定 + 委托）。
* **commission_percentage** – 定义验证者保留的奖励份额的整数 0-100。

链上发生的情况：

1. 金额从验证者的公共 `account` 余额中扣除。
2. `bonded[validator]` 使用新的自绑定金额进行写入/更新。
3. `delegated[validator]` 被更新（自绑定计入总委托）。
4. 如果总委托 ≥ 1000 万 ACs 且验证者尚未在 `committee` 中，则将其添加，并且 `metadata[committee_size]` 递增。（受网络最大委员会规模限制，可通过协议升级增加）

### 委托给验证者

如果您没有运行验证者，您仍然可以通过将 Aleo Credits 委托给验证者来参与网络，并根据他们的表现获得奖励。

#### 选择验证者

在委托之前，请检查候选验证者的链上统计数据。您可以通过 [API 端点](https://docs.explorer.provable.com/docs/api-reference/vz155069d5xy3-introduction) 或区块浏览器查询 `committee`、`delegated` 和 `bonded` 映射来了解：

* **总质押量** – 已委托给验证者的 AC 数量。
* **自绑定** – 验证者自己的质押（至少需要 100 ACs）。
* **佣金** – 验证者保留的奖励百分比（0–100）。
* **是否开放** – 只有 `is_open = true` 的验证者才能接受新质押。

健康的验证者通常具有：

* 至少 1000 万 ACs 总质押量（否则不在委员会中，无法获得区块奖励）。
* 一致的正常运行时间/性能（查看浏览器）。

#### 委托步骤

1. 决定您想要委托的金额（≥ 10,000 AC）。
:::warning[重要]
必须始终保持 ≥ 10,000 ALEO 的最低绑定余额。
:::
2. 确保该金额在您的公共账户余额中可用。
3. 选择一个提款地址（可以重用当前签名者地址或另一个地址）。
4. 使用 [Leo CLI](https://docs.leo-lang.org/cli/execute) 执行 `credits.aleo` 中的 `bond_public` 函数：

```bash
leo execute credits.aleo/bond_public <validator_address> <withdrawal_address> <amount> --network mainnet --endpoint https://api.provable.com/v1 --broadcast 
```

```aleo
function bond_public:
    // 输入验证者的地址。
    input r0 as address.public;
    // 输入提款地址。
    input r1 as address.public;
    // 输入要绑定的微 credit 数量。
    input r2 as u64.public;
```

交易最终确定后，您将开始按您的质押比例累积验证者区块奖励的一部分。您可以随时以任何金额追加您的绑定。

链上效果：

1. 从质押者的 `account` 中扣除金额。
2. 更新 `bonded[delegator]`（映射质押者 → 验证者）。
3. 将金额添加到 `delegated[validator]`。
4. 递增全局质押者计数器（`metadata[delegator_count]`，上限 100,000）。

:::warning[重要]
验证者必须是开放的（`committee_state.is_open = true`）且不在解绑（退出）过程中。
:::
:::info
每个地址一次只能绑定到一个验证者。质押者只有在之前的绑定完全解绑并领取 ACs 后才能绑定到新验证者。或者简单地使用新地址。
:::

### 提取质押

质押者可以随时提取绑定的 ACs，前提是剩余的绑定余额保持 ≥ 10,000。任何使绑定余额低于 10,000 ACs 的提取都会立即触发完全解绑。
 
要提取质押，质押者必须首先调用 `unbond_public` 函数。此函数通过指定质押者的地址和要解绑的微 credit 数量来启动解绑过程。解绑过程允许质押者部分或完全解绑其质押。这可以使用 [Leo CLI](https://docs.leo-lang.org/cli/execute) 完成：

```bash
leo execute credits.aleo/unbond_public <staker_address> <amount> --network mainnet --endpoint https://api.provable.com/v1 --broadcast 
```

```aleo
function unbond_public:
    // 输入质押者的地址。
    input r0 as address.public;
    // 输入要解绑的微 credit 数量。
    input r1 as u64.public;
```

由质押者的提款地址或验证者的提款地址调用。

* 质押者可以部分或完全解绑。如果剩余绑定低于 10,000 ACs，则整个绑定被解绑并且质押者条目被删除。
* 验证者可以解绑自己或强制解绑质押者。
* 如果解绑导致验证者的总质押低于 1000 万 ACs 或自绑定低于 100 ACs，则验证者将从委员会中移除。
* 金额开始 360 个区块的冷却期，存储在 `unbonding[staker]` 中。

#### 领取解绑质押

要领取您的解绑质押，请确保 360 个区块的冷却期已过，然后您可以使用 [Leo CLI](https://docs.leo-lang.org/cli/execute) 如下：

```bash
leo execute credits.aleo/claim_unbond_public <staker_address> --network mainnet --endpoint https://api.provable.com/v1 --broadcast
```

```aleo
function claim_unbond_public:
    // 输入质押者的地址。
    input r0 as address.public;
```

* 一旦 `block.height ≥ unbonding[staker].height`，任何人都可以触发此操作。
* 解绑金额将转移到质押者的提款地址（`account[withdrawal]`）。
* 相应的 `unbonding` 条目被清除。如果质押者没有剩余绑定，其提款地址也会被移除。


## 流动质押

流动质押是一种创新方法，允许用户在保持流动性的同时质押其 Aleo Credits (ACs)。您不是锁定您的 ACs，而是获得一个代表您质押头寸的流动质押代币（stToken）。这使您能够在参与质押的同时仍然能够在其他 DeFi 活动中使用您的代币。流动质押平台允许用户以少于 10,000 ACs 进行质押，使质押对每个人都更加便捷。
