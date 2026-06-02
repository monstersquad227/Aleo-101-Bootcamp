# Task 3 - 建起来：从程序到 dApp

## 应用名称

Private Score Pass

## 应用说明

这是一个用于学习 Aleo private input 的隐私分数验证小应用。用户输入一个私密分数 `score`，外部只看到公开阈值 `threshold` 和验证结果 `true/false`，不需要公开原始分数。

适用场景示例：

- 证明考试成绩达到某个门槛，但不暴露具体分数。
- 证明信用评分、会员等级、白名单分数合格，但不公开原始数据。
- 学习 Aleo 中 private input、public input、public output 的边界。

## 代码位置

```text
learn/Chengyuann/private_score_pass/
```

主要文件：

```text
private_score_pass/
├── program.json
├── src/main.leo
├── tests/test_private_score_pass.leo
└── web/
    ├── index.html
    ├── styles.css
    └── app.js
```

## Leo 合约

```leo
program chengyuann_score_pass.aleo {
    @noupgrade
    constructor() {}

    fn check_score(private score: u8, public threshold: u8) -> bool {
        return score >= threshold;
    }

    fn score_difference(private score: u8, public threshold: u8) -> i16 {
        let score_i: i16 = score as i16;
        let threshold_i: i16 = threshold as i16;
        return score_i - threshold_i;
    }
}
```

## 本地验证

本地工具：

```text
leo 4.1.0
```

构建：

```bash
leo build --path learn/Chengyuann/private_score_pass
```

运行：

```bash
leo run check_score 88u8 60u8 --path learn/Chengyuann/private_score_pass
leo run check_score 52u8 60u8 --path learn/Chengyuann/private_score_pass
leo run score_difference 52u8 60u8 --path learn/Chengyuann/private_score_pass
```

输出：

```text
true
false
-8i16
```

测试：

```bash
leo test --path learn/Chengyuann/private_score_pass
```

结果：

```text
3 / 3 tests passed.
```

## Demo

打开前端：

```text
learn/Chengyuann/private_score_pass/web/index.html
```

前端会根据输入生成本地运行命令和测试网交互命令。截图文件见：

```text
learn/Chengyuann/private_score_pass/demo-screenshot.png
```
