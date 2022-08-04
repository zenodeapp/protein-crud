//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

module.exports = {
  toBillion: (num, decimals) => {
    const tenToTheDecimals = Math.pow(10, decimals);
    return Math.round((num / 1e9) * tenToTheDecimals) / tenToTheDecimals;
  },
};
