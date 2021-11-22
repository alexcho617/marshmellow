class Game {
  Game(
      {this.players,
      this.keywords,
      this.code,
      this.host,
      this.playerCount,
      this.playerLimit,
      this.gameId,
      this.timeLimit});
  dynamic players;
  dynamic keywords;
  dynamic code;
  dynamic host;
  dynamic playerCount;
  dynamic playerLimit;
  dynamic gameId;
  dynamic timeLimit = 60;
}
