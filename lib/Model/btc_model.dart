class Currentprice {
  Time time;
  String disclaimer;
  String chartName;
  Bpi bpi;

  Currentprice({
    required this.time,
    required this.disclaimer,
    required this.chartName,
    required this.bpi,
  });

  factory Currentprice.fromJson(Map<String, dynamic> json) {
    return Currentprice(
      time: Time.fromJson(json['time']),
      disclaimer: json['disclaimer'],
      chartName: json['chartName'],
      bpi: Bpi.fromJson(json['bpi']),
    );
  }
}

class Bpi {
  Eur usd;
  Eur gbp;
  Eur eur;

  Bpi({
    required this.usd,
    required this.gbp,
    required this.eur,
  });

  factory Bpi.fromJson(Map<String, dynamic> json) {
    return Bpi(
      usd: Eur.fromJson(json['USD']),
      gbp: Eur.fromJson(json['GBP']),
      eur: Eur.fromJson(json['EUR']),
    );
  }
}

class Eur {
  String code;
  String symbol;
  String rate;
  String description;
  double rateFloat;

  Eur({
    required this.code,
    required this.symbol,
    required this.rate,
    required this.description,
    required this.rateFloat,
  });

  factory Eur.fromJson(Map<String, dynamic> json) {
    return Eur(
      code: json['code'],
      symbol: json['symbol'],
      rate: json['rate'],
      description: json['description'],
      rateFloat: json['rate_float'],
    );
  }
}

class Time {
  String updated;
  DateTime updatedIso;
  String updateduk;

  Time({
    required this.updated,
    required this.updatedIso,
    required this.updateduk,
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      updated: json['updated'],
      updatedIso: DateTime.parse(json['updatedISO']),
      updateduk: json['updateduk'],
    );
  }
}
