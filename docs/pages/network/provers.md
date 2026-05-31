---
id: provers 
title: 证明者
sidebar_label: 证明者
---

# 引言

Aleo 区块链引入了一个计算难题，旨在激励加速 zkSNARK 和 Aleo 特定程序的优化。历史上，Aleo 测试网络上的难题针对生成整个证明或专注于证明生成的计算密集型方面，如多标量乘法（MSM）和数论变换（NTT）。然而，这些领域的进展减少了它们在证明生成时间中的主导地位，促使下一阶段的重点关注。

该难题着眼于增强综合（synthesis），也称为见证生成（witness generation）。这个领域对 Aleo 尤其重要，因为它代表了为 Aleo 程序生成证明所花费时间的重要部分。通过将重点放在综合上，该难题旨在解决 Aleo 生态系统中的关键瓶颈，确保开发者用户和用户都有更流畅高效的过程。这种战略性重点不仅满足 Aleo 平台的独特需求，还促进了更广泛生态系统中的创新和优化。

:::info
有关难题的更详细信息，请参考 [规范说明](https://github.com/ProvableHQ/snarkVM/blob/staging/ledger/puzzle/epoch/docs/spec.md)。
:::

### 证明者的角色和激励

任何人都可以运行证明者。证明者不参与 Aleo 网络共识。他们运行特定算法来解决 `Puzzle` 并获得满足 `proof_target` 的 `Solution`。然后将此 `Solution` 广播到网络。在共识网络验证并将 `Solution` 包含在区块后，证明者将获得 `puzzle_reward` 作为激励。

证明者的经济激励类似于比特币的 PoW，但与比特币不同，Aleo 网络不采用赢家通吃的策略。只要 `Solution` 满足 `proof_target`，它就会被网络接受。`puzzle_reward` 直接与证明者在每个时代的计算能力相对于整个网络的比例成正比。这种方法确保了证明者更公平和更稳定的奖励。值得注意的是，`puzzle_reward` 在 10 年内逐渐减少，直到第 9 年达到最低阈值，之后保持不变。

## 难题的目标
该难题的设计考虑了以下目标。

**难度**：确保没有敌对方能够比随机猜测更快地计算解决方案。这要求系统是无记忆的，或不可分摊的，这意味着获胜的概率不依赖于计算解决方案所花费的时间。

**系统安全性**：设计和实现必须防止攻击者控制的输入导致拒绝服务（DoS）攻击、崩溃、代码执行或对系统的任何其他意外更改。

**唯一确定的电路**：保持零知识证明中操作码电路的健全性和唯一性，防止存在多个有效分配可能导致更便宜的难题尝试。

**资源消耗的一致性**：分配难题运行时间和资源消耗以最小化方差和极端行为的风险，目标是比幂律分布更接近高斯分布的分布。

**最大化实用性**：大多数计算应集中在"有用"的算法上。

## 难题设计
### 概述
以下是难题的高级描述：

1.  证明者构建难题解决方案并将其广播到网络。

2.  验证者通过共识机制将解决方案和交易聚合到下一个区块的集合中。
    -   解决方案的集合不能超过区块中 `MAX_SOLUTIONS` 的允许数量。
    -   验证者无需预先验证解决方案。

3.  在区块生成期间，验证者将按顺序处理解决方案，接受最多 `MAX_SOLUTIONS` 个有效解决方案并放弃其余部分。账本状态相应更新。
    -  验证者维护一个账本，存储：
        - `latest_epoch_hash`: 最新时代哈希。
        - `latest_proof_target`: 解决方案必须达到的最低目标。
        - `cumulative_proof_target`: 有效解决方案的证明目标在时代中的聚合总和，从前一个区块开始。
        - `coinbase_target`: 证明目标的预期总和，作为难度调整的阈值。
    -  如果解决方案的：
        - `epoch_hash` 与账本的 `latest_epoch_hash` 匹配
        - 为每个解决方案计算的 `proof_target` 满足 `latest_proof_target`。
        - 为此区块已接受的解决方案少于 `MAX_SOLUTIONS` 个。
    -  有效解决方案的比例将与其 `proof_target` 集合中的总和成比例获得奖励。
    -  每个 `proof_target` 都会添加到 `cumulative_proof_target`。
    -  每个 [ASERT 重定向算法](https://reference.cash/protocol/blockchain/proof-of-work/difficulty-adjustment-algorithm) 在每个区块中更新 `next_coinbase_target` 和 `next_proof_target`。如果当前 `coinbase_timestamp` 和 `last_coinbase_timestamp` 之间的时间长于 `anchor_time`，则 `next_coinbase_target` 和 `next_proof_target` 会减少；如果较短或相等，则保持不变。
    -  如果更新的 `cumulative_proof_target` 超过 `coinbase_target` 的一半，则重置 `cumulative_proof_target`，最新的 `coinbase_target` 和 `coinbase_timestamp` 成为新的重定向参数来计算下一个 `coinbase_target`。
    -  如果区块高度推进到下一个时代，则更新 `latest_epoch_hash`。

### 解决方案

`Solution` 包含：

- `solution_id: SolutionID<N>` 难题解决方案的唯一标识符，必须在提交到网络的所有解决方案中唯一。协议通过拒绝任何解决方案 ID 已记录在账本中的解决方案来强制唯一性。解决方案 ID 由 3 元组 `(address, epoch_hash, counter)` 构成，它们一起构成每次尝试的 `nonce`。然后使用这个 nonce 来播种 RNG，确保每次难题尝试确定性地生成唯一的随机内部值。
- `address: Address<N>` 被奖励的地址，如果难题解决方案对当前证明目标有效。
- `epoch_hash: N::Blockhash` 当前时代的区块哈希。当前时代的有效解决方案必须使用当前时代哈希。如果使用任何其他时代哈希，难题解决方案应该始终无效。
- `counter: u64` 一个计数器，在给定地址和时代哈希的多次难题尝试中变化。
- `target: u64` 此解决方案声称满足的证明目标值。只有当解决方案的 `target` 大于或等于网络要求的当前 `proof_target` 时，解决方案才有效。`target` 越高，解决方案可以获得的奖励份额就越大。

### K 元 Merkle 树

- 难题使用 `DEPTH` 8 和 `ARITY` 8 的 K 元 Merkle 树。
- 叶子和路径哈希函数是 SHA-256。
- 难题生成一个 Merkle 根，将其转换为解决方案的 `proof_target`。将目标与 `latest_proof_target` 进行比较，以确定解决方案是否有效。

### 综合难题

综合难题强调合成有效的 R1CS 分配作为难题的关键计算元素。

构建综合难题解决方案的步骤如下：

1.  从 `address`、`epoch_hash` 和 `counter` 构造特定尝试的 `nonce`（`SolutionID`）。
2.  使用 `epoch_hash` 采样一个 `EpochProgram`。
3.  使用由 `nonce`（`SolutionID`）播种的 RNG 采样特定尝试的输入集合。
4.  为 `EpochProgram` 和难题输入合成 R1CS。
5.  将 R1CS 分配转换为 Merkle 叶子的序列。
6.  计算 Merkle 根并将其转换为 `proof_target`。
7.  如果 `proof_target` 满足 `latest_proof_target`，提交 `address`、`epoch_hash` 和 `counter` 作为解决方案。否则，重复上述步骤。

### 程序采样

每个时代，使用 `epoch_hash` 采样一个 `EpochProgram`。`epoch_hash` 用于播种 RNG，根据某个固定分布选择一系列抽象指令。然后使用 `Register Table` 将抽象指令具体化为有效的程序，以正确跟踪活跃寄存器的集合。

指令根据权重从定义的指令集中采样。权重根据输出熵设置。

指令集中的每个条目返回最多 `NUM_SEQUENCE_INSTRUCTIONS` 的向量，每个包含一个元组：

-   [此处定义的指令](../../guides/aleo/04_opcodes.md)。
-   操作数，可以是：
    -   `Ephemeral`
    -   `Input`
    -   `Literal`
    -   `Register`
    -   `RegisterOffset`
-   目的地：
    -   `Ephemeral`
    -   `Register`

#### 目的地
`Ephemeral` 目的地是在本地可用的寄存器，不会添加到寄存器表中。它们可以在序列中稍后使用，但之后不可用。

`Register` 目的地是存储在寄存器表中的寄存器。

#### 操作数
`Register` 操作数指示要使用的寄存器必须是寄存器表中最新的元素。

`Ephemeral` 操作数是对序列本地可用的寄存器。它们必须是序列中先前指令的临时目的地。

`Input` 操作数引用程序的原始输入。

`Literal` 操作数指定用作操作数的常量。

`Register offsets` 指示要使用的寄存器来自 `RegisterTable`，按索引偏移。即，第 0 个索引是寄存器表中最新的元素，第 1 个索引是第二新的元素，依此类推。

### 寄存器表

寄存器表在构造时代程序时初始化和存储活跃寄存器。
该表为每个 `LiteralType` 包含一个 2 深度的寄存器堆栈。
该表根据以下序言初始化。

**序言**

```aleo
input r0 as boolean.public;
input r1 as boolean.public;
input r2 as i8.public;
input r3 as i8.public;
input r4 as i16.public;
input r5 as i16.public;
input r6 as i32.public;
input r7 as i32.public;
input r8 as i64.public;
input r9 as i64.public;
input r10 as i128.public;
input r11 as i128.public;
input r12 as field.public;
input r13 as field.public;

is.eq r1 r0 into r14;
is.eq r3 r2 into r15;
is.eq r5 r4 into r16;
is.eq r7 r6 into r17;
is.eq r9 r8 into r18;
is.eq r11 r10 into r19;

hash.psd2 r12 into r20 as u8;
hash.psd2 r13 into r21 as u8;
hash.psd2 r12 into r22 as u16;
hash.psd2 r13 into r23 as u16;
hash.psd2 r12 into r24 as u32;
hash.psd2 r13 into r25 as u32;
hash.psd2 r12 into r26 as u64;
hash.psd2 r13 into r27 as u64;
hash.psd2 r12 into r28 as u128;
hash.psd2 r13 into r29 as u128;

mul.w r3 r2 into r30;
mul.w r5 r4 into r31;
mul.w r7 r6 into r32;
mul.w r9 r8 into r33;
mul.w r11 r10 into r34;

ternary r15 r30 r2 into r35;
ternary r16 r31 r4 into r36;
ternary r17 r32 r6 into r37;
ternary r18 r33 r8 into r38;
ternary r19 r34 r10 into r39;
```

#### 指令变体

以下是难题中的所有指令变体以及是否采样：

-   `Abs`: 否
-   `AbsWrapped`: 是
-   `Add`: 是
-   `AddWrapped`: 是
-   `And`: 是
-   `AssertEq`: 否
-   `AssertNeq`: 否
-   `BranchEq`: 否
-   `BranchNeq`: 否
-   `Cast`: 否
-   `CastLossy`: 是
-   `CommitBhp256`: 否
-   `CommitBhp512`: 否
-   `CommitBhp768`: 否
-   `CommitBhp1024`: 否
-   `CommitPed64`: 否
-   `CommitPed128`: 否
-   `Div`: 是
-   `DivWrapped`: 是
-   `Double`: 否
-   `Gt`: 是
-   `Gte`: 是
-   `HashBhp256`: 是
-   `HashBhp512`: 否
-   `HashBhp768`: 否
-   `HashBhp1024`: 否
-   `HashKeccak256`: 否
-   `HashKeccak384`: 否
-   `HashKeccak512`: 否
-   `HashPed64`: 是
-   `HashPed128`: 否
-   `HashPsd2`: 否
-   `HashPsd4`: 否
-   `HashPsd8`: 否
-   `HashSha3256`: 否
-   `HashSha3384`: 否
-   `HashSha3512`: 否
-   `Inv`: 是
-   `IsEq`: 是
-   `IsNeq`: 是
-   `Lt`: 是
-   `Lte`: 是
-   `Mod`: 是
-   `Mul`: 是
-   `MulWrapped`: 是
-   `Nand`: 是
-   `Neg`: 是
-   `Nor`: 是
-   `Not`: 是
-   `Or`: 是
-   `Pow`: 是
-   `PowWrapped`: 是
-   `Rem`: 否
-   `RemWrapped`: 是
-   `Shl`: 否
-   `ShlWrapped`: 是
-   `Shr`: 否
-   `ShrWrapped`: 是
-   `Sqrt`: 否
-   `Square`: 是
-   `Sub`: 否
-   `SubWrapped`: 是
-   `Ternary`: 是
-   `Xor`: 是

### 时代

一个时代是 360 个区块的周期。在每个时代开始时，使用前一个区块的哈希生成一个新的难题程序。这个程序在该时代对所有证明者都是相同的，并且每个时代都会变化，以防止预计算并确保公平性。

关键点：
- `epoch_hash` 在时代开始时从先前的 `block_hash` 确定性地生成。
- `epoch_hash` 播种一个随机数生成器来为新的 `EpochProgram` 采样指令。
- 该时代中的所有 `Solution` 必须使用当前的 `epoch_hash` 和 `EpochProgram`。
- `EpochProgram` 被缓存并在整个时代中使用。
- 目标更新完全独立于时代，并且基于 `Solution` 的 `cumulative_proof_target` 在每个区块发生。

## 难题奖励

每当提交有效的难题解决方案时，Aleo 都会发行新的 ALEO 代币作为 coinbase 奖励。coinbase 奖励在证明者和验证者之间按固定比例分配，总奖励基于网络参数和证明目标计算。

总 coinbase 奖励分配如下：
- **2/3 给证明者**：支付给提交有效解决方案的难题解决者
- **1/3 给验证者**：包含在区块奖励中，分配给活跃的质押者

此分配在 `puzzle_reward()` 函数中实现：

```rust
pub const fn puzzle_reward(coinbase_reward: u64) -> u64 {
    coinbase_reward.saturating_mul(2).saturating_div(3)
}
```

### Coinbase 奖励

Coinbase 奖励使用以下公式计算：

```
R_coinbase = R_anchor * min(P, C_R) / C
```

其中：
- **R_anchor**：锚点区块奖励（在根据实际提交的证明目标进行调整之前，给定区块的最大可能 coinbase 奖励）
- **P**：当前时代所有解决方案的组合证明目标
- **C_R**：剩余 coinbase 目标（coinbase 目标减去累积证明目标）
- **C**：当前 coinbase 目标

:::note
剩余证明目标是最小值：
- 当前解决方案的组合证明目标
- 剩余 coinbase 目标（coinbase 目标减去同一时代的累积证明目标）

这确保了奖励不会超过该时代的可用 coinbase 目标。
:::

### 锚点区块奖励

锚点区块奖励作为给定区块的最大可能 coinbase 奖励。它使用时间戳来对抗区块时间波动，更好地与人类时间尺度对齐：

```
R_anchor = max(floor((2 * S * T_A * T_R) / (T_Y10 * (T_Y10 + 1))), R_Y9)
```

其中：
- **S**：初始供应量（15 亿 ALEO）
- **T_A**：锚点时间（25 秒）
- **T_R**：直到第 10 年的剩余秒数
- **T_Y10**：10 年内经过的秒数
- **R_Y9**：第 9 年的最低奖励

锚点奖励随时间减少，直到第 9 年，之后保持在第 9 年的基准线。

### Coinbase 目标

Coinbase 目标使用 [ASERT](https://reference.cash/protocol/blockchain/proof-of-work/difficulty-adjustment-algorithm) 重定向算法计算：

```
T_{i+1} = T_i * 2^(INV * (D - A) / TAU)
```

其中：
- **T_i**：当前目标
- **D**：漂移（实际经过的时间）
- **A**：锚点时间（预期的经过时间）
- **TAU**：半衰期（秒）
- **INV**：反向标志（-1 表示增加难度，1 表示减少难度）

该算法根据当前时代与预期半时代时间相比的推进速度来调整目标。

### 目标更新

Coinbase 目标和证明目标都在每个区块更新，以确保难题保持公平并适应网络条件。

- **Coinbase 目标**：  
  Coinbase 目标使用 ASERT 算法在每个区块重新计算，该算法考虑先前的 coinbase 目标、时间戳、锚点时间和区块数量。公式为：
```
next_coinbase_target = ASERT(last_coinbase_target, last_timestamp, current_timestamp, anchor_time, blocks_per_epoch)
```

- **证明目标**：  
  更新 coinbase 目标后，证明目标基于新的 coinbase 目标设置，即 coinbase 目标的 1/4：
```
proof_target = (coinbase_target >> 2) + 1
```

当累积证明目标至少达到 coinbase 目标的一半时（`cumulative_proof_target >= coinbase_target / 2`），会发生以下步骤：
1. 重置累积证明目标为零。
2. 使用新的 `last_coinbase_target` 和新的 `last_timestamp` 更新 coinbase 目标。
3. 基于新的 coinbase 目标重新计算证明目标。

### 个人证明者奖励

每个证明者根据其贡献获得难题奖励的一部分：

```
个人奖励 = 难题奖励 * (个人证明目标 / 组合证明目标)
```

这种方法通过基于个人贡献比例更公平地分配奖励，避免了赢家通吃的结果。

## ARC-46 难题解决方案提交的质押

随着 Aleo Network 的发展，确保长期安全性、稳定性和公平参与对生态系统的成功至关重要。ARC-46 已被 [Aleo 社区投票和接受](https://vote.aleo.org/p/46)。该 ARC 的目标是使证明者激励与整体网络的健康状况保持一致，并随着网络的逐步成熟逐步提高经济要求。

该 ARC 提出一种机制，要求 Aleo Network 上的证明者质押特定数量的 Aleo Credits 才有资格在每个时代提交特定数量的解决方案。该机制是程序化的，在该 ARC 激活后的两年内，所需质押金额逐步增加。

在 ARC-46 之前，证明者无需任何进入或退出要求即可参与简洁工作证明并获得难题奖励。该 ARC 考虑为证明者引入进入要求，虽然退出要求是理想的，但目前超出了该 ARC 的范围。

要在 Aleo 网络上作为证明者参与，该 ARC 建议要求证明者质押最少数量的 Aleo Credits (X) 以每个时代提交 1 个解决方案。因此，如果证明者希望每个时代提交 2 个解决方案，他们必须在 Aleo 网络上质押 2*X Aleo credits。这种方法确保池不会比个别提交解决方案的证明者获得任何优势，确保所有参与方公平。正如预期的那样，一旦证明者提交了每个时代的配额解决方案，该证明者此后提交的所有解决方案都将被拒绝。

证明者不需要质押到任何特定的验证者。相反，在共识中，协议将强制要求提交解决方案的证明者在 Aleo Network 上有足够的质押金绑定到验证者。
