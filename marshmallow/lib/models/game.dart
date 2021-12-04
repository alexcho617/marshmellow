class Game {
  Game(
      {this.records,
      this.players,
      this.keywords,
      this.currentRound,
      this.code,
      this.host,
      this.playerCount,
      this.playerLimit,
      this.isOver,
      this.timeLimit});
  dynamic records;
  dynamic players;
  dynamic keywords;
  dynamic currentRound;
  dynamic code;
  dynamic host;
  dynamic playerCount;
  dynamic playerLimit;
  dynamic isOver;
  dynamic timeLimit = 60;
}
