class BusSchedule {
  final Map<String, int> fromIITH;
  final Map<String, int> toIITH;

  BusSchedule({
    required this.fromIITH,
    required this.toIITH,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    Map<String, int> fromIITH = {};
    json['bus']['Hostel Circle-Hospital-Maingate'].forEach((item) {
      fromIITH[item] = 0; // Bus values should be 0
    });

    Map<String, int> toIITH = {};
    json['bus']['Maingate-Hospital-Hostel Circle'].forEach((item) {
      toIITH[item] = 0; // Bus values should be 0
    });

    json['EV']['Hostel to Maingate'].forEach((item) {
      fromIITH[item] = 1; // EV values should be 1
    });

    json['EV']['Maingate to Hostel'].forEach((item) {
      toIITH[item] = 1; // EV values should be 1
    });

    return BusSchedule(
      fromIITH: fromIITH,
      toIITH: toIITH,
    );
  }

  Map<String, dynamic> toJson() {
    List<String> busFromIITH = [];
    List<String> busToIITH = [];
    List<String> evFromIITH = [];
    List<String> evToIITH = [];

    fromIITH.forEach((key, value) {
      if (value == 0) {
        busFromIITH.add(key);
      } else {
        evFromIITH.add(key);
      }
    });

    toIITH.forEach((key, value) {
      if (value == 0) {
        busToIITH.add(key);
      } else {
        evToIITH.add(key);
      }
    });

    return {
      'bus': {
        'Hostel Circle-Hospital-Maingate': busFromIITH,
        'Maingate-Hospital-Hostel Circle': busToIITH,
      },
      'EV': {
        'Hostel to Maingate': evFromIITH,
        'Maingate to Hostel': evToIITH,
      },
    };
  }
}

class CityBusSchedule {
  final Map<String, int> fromIITH;
  final Map<String, int> toIITH;

  CityBusSchedule({
    required this.fromIITH,
    required this.toIITH,
  });

  factory CityBusSchedule.fromJson(Map<String, dynamic> json) {
    Map<String, int> fromIITH = {};
    Map<String, int> toIITH = {};

    json['bus']['iith-ptc'].forEach((item) {
      fromIITH[item] = 0;
    });

    json['bus']['ptc-iith'].forEach((item) {
      toIITH[item] = 0;
    });

    json['bus']['iith-miya'].forEach((item) {
      fromIITH[item] = 1;
    });

    json['bus']['miya-iith'].forEach((item) {
      toIITH[item] = 1;
    });

    return CityBusSchedule(
      fromIITH: fromIITH,
      toIITH: toIITH,
    );
  }

  Map<String, dynamic> toJson() {
    List<String> patancheruFromIITH = [];
    List<String> patancheruToIITH = [];
    List<String> miyapurFromIITH = [];
    List<String> miyapurToIITH = [];

    fromIITH.forEach((key, value) {
      if (value == 0) {
        patancheruFromIITH.add(key);
      } else {
        miyapurFromIITH.add(key);
      }
    });

    toIITH.forEach((key, value) {
      if (value == 0) {
        patancheruToIITH.add(key);
      } else {
        miyapurToIITH.add(key);
      }
    });

    return {
      'bus': {
        'iith-ptc': patancheruFromIITH,
        'ptc-iith': patancheruToIITH,
        'iith-miya': miyapurFromIITH,
        'miya-iith': miyapurToIITH,
      }
    };
  }
}
