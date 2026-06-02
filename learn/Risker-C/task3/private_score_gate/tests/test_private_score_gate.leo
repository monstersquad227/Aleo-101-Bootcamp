import private_score_gate.aleo;

program test_private_score_gate.aleo {
    @test
    fn test_private_score_gate_flow() {
        let first: private_score_gate.aleo::ScoreCard = private_score_gate.aleo::mint_score(58u64);
        let second: private_score_gate.aleo::ScoreCard = private_score_gate.aleo::bump(first, 12u64);
        let passed: bool = private_score_gate.aleo::check(second, 60u64);
        assert_eq(passed, true);
    }

    @noupgrade
    constructor() {}
}
