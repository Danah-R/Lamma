import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data.dart';

void main() {
  test('first to finish gets the most points, later finishers less, undo takes it back', () async {
    seedSample();
    final a = members[0],
        b = members[1],
        c = members[2],
        d = members[3],
        e = members[4];
    final start = [
      for (final m in [a, b, c, d, e]) m.points,
    ];
    expect(await claimFirst('t', a.name), 20);
    expect(await claimFirst('t', b.name), 15);
    expect(await claimFirst('t', c.name), 10);
    expect(await claimFirst('t', d.name), 5);
    expect(await claimFirst('t', e.name), 5);
    expect(await claimFirst('t', a.name), 0, reason: 'only counted once');
    expect(a.points, start[0] + 20);
    await revokeFirst('t', a.name);
    expect(a.points, start[0]);
    expect(
      await claimFirst('other', a.name),
      20,
      reason: 'every activity has its own race',
    );
  });
}
