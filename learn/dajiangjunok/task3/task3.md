# Task 3 - 建起来：从程序到 dApp

## 项目名称
Private Add Demo（私密加法小应用）

## 项目说明
这是一个最小可交互的隐私小应用示例：
- 使用 Leo 编写 `private_add` 逻辑；
- 使用前端页面提供交互输入与结果展示；
- 前端当前用本地模拟执行，保留了后续接入钱包/SDK 的位置，便于继续扩展到真实链上调用。

## 目录结构
```text
task3/
├── leo/
│   └── private_calc.leo
├── web/
│   └── index.html
├── demo-screenshot.svg
└── task3.md
```

## Leo 代码文件
- `leo/private_calc.leo`

核心函数：
```leo
fn private_add(a: u32, b: u32) -> u32 {
    let result: u32 = a + b;
    return result;
}
```

## 前端代码文件
- `web/index.html`

前端功能：
- 输入两个数字（模拟私有输入）；
- 点击按钮触发计算；
- 展示结果和 demo tx id。

## Demo 截图
- `demo-screenshot.svg`

可在 markdown 中预览：

![demo](./demo-screenshot.svg)

## 运行方式（本地）
在 `task3/web` 目录下直接用浏览器打开 `index.html` 即可看到交互效果。
