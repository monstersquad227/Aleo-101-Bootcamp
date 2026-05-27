program private_multiplier.aleo {
    // 私有乘法：两个私有输入相乘
    // 输入默认是 private，这里实现一个最小可演示的私密乘法。
    fn private_multiply(a: u32, b: u32) -> u32 {
        let result: u32 = a * b;
        return result;
    }

    // 额外函数：验证结果是否正确（返回布尔值）
    fn verify_result(a: u32, b: u32, expected: u32) -> bool {
        let actual: u32 = a * b;
        return actual == expected;
    }
}