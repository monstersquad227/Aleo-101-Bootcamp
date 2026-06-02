const form = document.querySelector("#score-form");
const scoreInput = document.querySelector("#score");
const thresholdInput = document.querySelector("#threshold");
const statusEl = document.querySelector("#status");
const publicOutputEl = document.querySelector("#public-output");
const privateInputEl = document.querySelector("#private-input");
const runCommandEl = document.querySelector("#run-command");
const executeCommandEl = document.querySelector("#execute-command");

function clampU8(value) {
  const parsed = Number.parseInt(value, 10);
  if (Number.isNaN(parsed)) return 0;
  return Math.max(0, Math.min(255, parsed));
}

function render() {
  const score = clampU8(scoreInput.value);
  const threshold = clampU8(thresholdInput.value);
  const passed = score >= threshold;

  scoreInput.value = score;
  thresholdInput.value = threshold;
  statusEl.textContent = passed ? "通过" : "未通过";
  publicOutputEl.textContent = String(passed);
  privateInputEl.textContent = `${score}u8`;

  runCommandEl.textContent =
    `leo run check_score ${score}u8 ${threshold}u8 --path private_score_pass`;
  executeCommandEl.textContent =
    [
      "leo execute check_score",
      `${score}u8`,
      `${threshold}u8`,
      "--network testnet",
      "--endpoint https://api.explorer.provable.com/v1",
      "--broadcast",
    ].join(" ");
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  render();
});

scoreInput.addEventListener("input", render);
thresholdInput.addEventListener("input", render);
render();
