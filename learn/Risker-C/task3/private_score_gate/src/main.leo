program private_score_gate.aleo {
    record ScoreCard {
        owner: address,
        score: u64,
    }

    @noupgrade
    constructor() {}

    fn mint_score(score: u64) -> ScoreCard {
        return ScoreCard {
            owner: self.signer,
            score: score,
        };
    }

    fn bump(card: ScoreCard, amount: u64) -> ScoreCard {
        assert_eq(card.owner, self.signer);

        return ScoreCard {
            owner: card.owner,
            score: card.score + amount,
        };
    }

    fn check(card: ScoreCard, public threshold: u64) -> bool {
        assert_eq(card.owner, self.signer);
        return card.score >= threshold;
    }
}
