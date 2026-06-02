import chengyuann_score_pass.aleo;

program test_private_score_pass.aleo {
    @test
    fn test_check_score_passes() {
        let result: bool = chengyuann_score_pass.aleo::check_score(88u8, 60u8);
        assert_eq(result, true);
    }

    @test
    fn test_check_score_fails() {
        let result: bool = chengyuann_score_pass.aleo::check_score(52u8, 60u8);
        assert_eq(result, false);
    }

    @test
    fn test_score_diff_negative() {
        let result: i16 = chengyuann_score_pass.aleo::score_difference(52u8, 60u8);
        assert_eq(result, -8i16);
    }

    @noupgrade
    constructor() {}
}
