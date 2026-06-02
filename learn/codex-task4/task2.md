# Task 2 - Leo 入门：学会这门语言

## 问题

**Q1. Leo 中的 "Private by Default"（默认隐私）语义是什么？**

A: Leo 中函数参数和输出默认是 private，除非显式写成 `public`。private 值会进入零知识证明电路，链上验证者只能验证计算正确，不能直接看到私密输入、私密中间值或私密输出内容。

---

**Q2. Tuple 包含 array structs 的示例，以及如何访问 struct 中的元素。**

A:

```leo
struct Point {
    x: u64,
    y: u64,
}

fn read_tuple() -> u64 {
    let points: [Point; 2] = [
        Point { x: 1u64, y: 2u64 },
        Point { x: 3u64, y: 4u64 },
    ];
    let data: ([Point; 2], u64) = (points, 9u64);
    return data.0[1].y + data.1;
}
```

`data.0` 访问 tuple 第一个元素，`[1]` 访问 array 第二项，`.y` 访问 struct 字段。

---

**Q3. Aleo record 中 owner 字段的作用是什么？**

A: `owner` 表示该 record 的所有者地址。只有对应私钥控制者才能消费或转移该 record。它用于把私密状态和账户控制权绑定，保证 record 不被其他地址任意使用。

---

**Q4. 程序中的 final 是什么？**

A: `final` 用于表示 finalize 逻辑产生的异步链上结果。普通函数可在链下执行并生成证明，若需要更新 public mapping、调用带 finalize 的外部函数或产生链上状态变化，就通过 future / final 把结果交给 finalize 阶段处理。

---

**Q5. 如何创建 helper functions（辅助函数）？**

A: 在程序内定义普通 `function` 之外的内部辅助逻辑，可使用 `inline` 函数复用纯计算：

```leo
inline fn add_bonus(score: u64) -> u64 {
    return score + 10u64;
}

fn check(score: u64) -> bool {
    return add_bonus(score) >= 60u64;
}
```

---

**Q6. helper functions 能否创建 records？**

A: 不能。`inline` helper function 只适合封装纯计算逻辑，不能创建或输出 record。record 应由普通 transition / function 创建并返回。

---

**Q7. constructor 的目的是什么？**

A: `constructor` 是程序部署时执行的一次性初始化入口。它可初始化 public storage、设置初始 mapping 值或声明部署约束。部署后 constructor 不会被普通用户反复调用。

---

**Q8. 如何组合多个 interfaces（接口）？**

A: 在类型声明中列出需要满足的 interface 约束，或在 record / struct 中按多个 interface 的字段要求组合字段。实际开发中常通过明确字段、函数签名和导入程序来实现组合，例如一个 record 同时包含所有权字段、状态字段和业务字段。

---

**Q9. record interface 中 `..` 的含义是什么？**

A: `..` 表示该 record interface 允许额外字段存在。也就是只要求 record 至少包含 interface 声明的字段，其他业务字段可以继续保留，便于复用通用 record 约束。

---

**Q10. 何时使用 dyn record（动态 record）？**

A: 当函数需要接受满足某个 record interface、但具体 record 类型可能来自不同程序或不同业务结构时，可用 dyn record。它适合通用资产、通用权限或插件式逻辑，让代码依赖接口而不是固定 record 类型。

---

**Q11. storage vector 支持的核心操作有哪些？**

A: storage vector 主要支持按索引读写、追加、弹出、查询长度等操作。常见语义包括 `get` / `set` / `push` / `pop` / `len`，用于在 public storage 中维护有序集合。
