program private_score_gate.aleo {
    record ScoreCard {
        owner: address,
        score: u64,
        public threshold: u64,
    }

    fn mint_score_card(score: u64, public threshold: u64) -> ScoreCard {
        return ScoreCard {
            owner: self.signer,
            score,
            threshold,
        };
    }

    fn is_eligible(card: ScoreCard) -> bool {
        return card.score >= card.threshold;
    }

    fn transfer_card(card: ScoreCard, receiver: address) -> ScoreCard {
        return ScoreCard {
            owner: receiver,
            score: card.score,
            threshold: card.threshold,
        };
    }

    @noupgrade
    constructor() {}
}
