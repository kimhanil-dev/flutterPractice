void main() {
  // test('player_info 전송 테스트', () {
  //   List<Player> players = [
  //     Player(testSocket(), 0,
  //         ping: 5, isActionVoted: false, isSkipVoted: false),
  //     Player(testSocket(), 0,
  //         ping: -5, isActionVoted: false, isSkipVoted: false),
  //     Player(testSocket(), 3,
  //         ping: -99999999, isActionVoted: true, isSkipVoted: false),
  //     Player(testSocket(), 3,
  //         ping: 99999999, isActionVoted: false, isSkipVoted: true),
  //     Player(testSocket(), 3000,
  //         ping: 1, isActionVoted: true, isSkipVoted: false),
  //     Player(testSocket(), -3000,
  //         ping: 1, isActionVoted: true, isSkipVoted: true),
  //   ];

  //   List<Uint8List> bytes = [];

  //   List<Player_trans> pass = [
  //     Player_trans.test(0, 5, false, false),
  //     Player_trans.test(0, 0, false, false),
  //     Player_trans.test(3, 0, false, false),
  //     Player_trans.test(3, 65535, false, true),
  //     Player_trans.test(255, 1, true, true),
  //     Player_trans.test(0, 1, false, false),
  //   ];

  //   List<Player_trans> test = [];

  //   for (var e in pass) {
  //     test.add(Player_trans.fromBytes(Uint8List.fromList(e.getMessage())));
  //   }
  //   expect(test, equals(pass));
  // });
}
