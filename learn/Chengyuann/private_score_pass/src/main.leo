// Private Score Pass.
// The user proves that a private score satisfies a public threshold without
// revealing the raw score on chain.
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
