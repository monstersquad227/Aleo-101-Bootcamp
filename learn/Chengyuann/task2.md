# Task 2 - Leo 入门：学会这门语言

请将本文件复制到 `learn/YourName/` 文件夹中，填写你的答案后提交 PR。


## 问题

**Q1. Leo 中的 "Private by Default"（默认隐私）语义是什么？**

A: 在 Leo 中，函数输入、输出和 record 字段默认按 private 处理，除非显式写 `public`。private 值在本地参与计算和证明生成，不会以明文出现在链上；public 值会作为公开输入、输出或公开状态被网络看到。

---

**Q2. Tuple 包含 array structs 的示例，以及如何访问 struct 中的元素。**

A:

```leo
struct Point {
    x: u32,
    y: u32,
}

let data: (u8, [Point; 2]) = (
    1u8,
    [
        Point { x: 10u32, y: 20u32 },
        Point { x: 30u32, y: 40u32 },
    ],
);

let first_x: u32 = data.1[0u32].x;
let second_y: u32 = data.1[1u32].y;
```

Tuple 用 `.0`、`.1` 访问第几个元素；array 用 `[index]`；struct 用 `.field`。

---

**Q3. Aleo record 中 owner 字段的作用是什么？**

A: `owner` 是 record 必须包含的地址字段，用来表示这个私有状态归谁控制。只有 owner 对应私钥的持有者才能解密、授权消费或转移这个 record；这也是 Aleo 防止他人花费你的私有资产、并保持记录隐私边界的基础。

---

**Q4. 程序中的 final 是什么？**

A: `final` 是链上最终化阶段。Leo 主体逻辑先在用户本地执行并生成 ZK proof；proof 被验证后，`final` 块才由网络节点执行，用来更新公开 mapping、storage variable 或 storage vector。它适合处理必须公开一致的状态更新，不能依赖未公开的私有数据。

---

**Q5. 如何创建 helper functions（辅助函数）？**

A: 可以在 `program {}` 外部声明普通 `fn`，然后在程序内部函数里调用：

```leo
fn add_u32(a: u32, b: u32) -> u32 {
    return a + b;
}

program calculator.aleo {
    @noupgrade
    constructor() {}

    fn compute(public a: u32, private b: u32) -> u32 {
        return add_u32(a, b);
    }
}
```

这类 helper 会被编译器内联，适合复用纯计算逻辑。

---

**Q6. helper functions 能否创建 records？**

A: 不建议也不能把 record 创建逻辑放在 helper 里。Record 是 Aleo 私有状态，创建和消费需要处在 program 的入口执行上下文中，和状态转换证明绑定；helper 更适合做纯计算，不能访问链上状态，也不能作为独立交易入口。

---

**Q7. constructor 的目的是什么？**

A: `constructor` 用来定义程序部署和升级时的治理规则，例如 `@noupgrade` 表示部署后不可升级，`@admin` 可以指定管理员升级，`@checksum` 可以把升级约束绑定到链上状态。它不是传统面向对象里的初始化对象，而是程序升级策略的入口。

---

**Q8. 如何组合多个 interfaces（接口）？**

A: 可以在接口或 program 声明中用 `+` 组合多个接口：

```leo
interface Transfer {
    record Token {
        owner: address,
        amount: u64,
        ..
    }
    fn transfer(token: Token, to: address, amount: u64) -> Token;
}

interface Pausable {
    fn pause() -> Final;
}

program my_token.aleo : Transfer + Pausable {
    // 这里需要实现两个 interface 要求的 record / fn / mapping 等内容。
}
```

编译器会检查 program 是否满足所有接口约束。

---

**Q9. record interface 中 `..` 的含义是什么？**

A: `..` 表示这个 interface 只要求列出的字段必须存在，实现方可以在 record 中添加额外字段。例如接口要求 `owner` 和 `amount`，实现方还可以加 `memo`、`asset_id` 等业务字段。它让接口保持最小约束，同时保留扩展性。

---

**Q10. 何时使用 dyn record（动态 record）？**

A: 当编译期不知道传入 record 的具体结构，但只需要它满足某个接口或用于动态调用时，使用 `dyn record`。典型场景是通用 DEX、资产路由器、跨程序托管等：程序不想绑定某一个具体 token record，而是接收任何符合接口的 record。

---

**Q11. storage vector 支持的核心操作有哪些？**

A: Storage vector 是链上的动态数组，核心操作包括：

- `push(value)`：追加元素
- `pop()`：弹出末尾元素
- `get(index)`：读取指定位置，返回 optional
- `set(index, value)`：写入指定位置
- `len()`：读取长度
- `swap_remove(index)`：用末尾元素替换并移除指定位置
- `clear()`：清空逻辑长度

这些操作只能在 `final` / `final fn` 这类链上最终化逻辑里使用。
