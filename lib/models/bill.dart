class Bill {
  int id;
  String number;
  String paymentMethod;
  String byUser;
  String jir;
  String zki;
  int gross;
  int net;
  String taxes;
  int businessPlaceLabel;
  int cashRegisterLabel;
  String billedAt;

  Bill({
    required this.id,
    required this.number,
    required this.paymentMethod,
    required this.byUser,
    required this.jir,
    required this.zki,
    required this.gross,
    required this.net,
    required this.taxes,
    required this.businessPlaceLabel,
    required this.cashRegisterLabel,
    required this.billedAt,
  });

  // TODO => Remove. Used for demonstration purposes.
  static List<Bill> getData() {
    return [
      new Bill(id: 1, number: '1-1-1', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 2, number: '1-1-2', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 3, number: '1-1-3', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 4, number: '1-1-4', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 5, number: '1-1-5', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 6, number: '1-1-6', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 7, number: '1-1-7', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 8, number: '1-1-8', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 9, number: '1-1-9', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 10, number: '1-1-10', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 11, number: '1-1-11', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 12, number: '1-1-12', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 13, number: '1-1-13', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 14, number: '1-1-14', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 15, number: '1-1-15', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 16, number: '1-1-16', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 17, number: '1-1-17', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 18, number: '1-1-18', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 19, number: '1-1-19', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 20, number: '1-1-20', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
      new Bill(id: 21, number: '1-1-21', paymentMethod: 'Gotovina', byUser: 'Toni Krešić', jir: 'cawjcewacemawcewa', zki: 'feawjfeawjfjewa', gross: 1250, net: 1000, taxes: '250', businessPlaceLabel: 1, cashRegisterLabel: 1, billedAt: '01.06.2021 12:00:00'),
    ];
  }
}