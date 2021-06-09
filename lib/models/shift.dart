class Shift {
  int id;
  String start;
  String? end;
  String user;
  int income;

  Shift({required this.id, required this.start, required this.end, required this.user, required this.income});

  // TODO => Remove. Used for demonstration purposes.
  static List<Shift> getData() {
    return [
      new Shift(id: 1, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 2, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 3, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 4, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 5, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 6, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 7, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 8, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 9, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 10, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 11, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 12, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 13, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 14, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 15, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 16, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 17, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
      new Shift(id: 18, start: '01.06.2021. 12:00:00', end: '01.06.2021 18:00:00', user: 'tkresic', income: 521621),
    ];
  }
}