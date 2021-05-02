import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entities.freezed.dart';

@freezed
class Pi with _$Pi {
  Pi._();
  factory Pi({
    // annotation
    required String title,
    required String description,
    required Color primaryColor,

    // host details
    required String baseUrl,
    required String apiPath,
    required int apiPort,

    // authentication
    required String apiToken,
    required bool apiTokenRequired,
    required bool allowSelfSignedCertificates,
    required String basicAuthenticationUsername,
    required String basicAuthenticationPassword,

    // proxy
    required String proxyUrl,
    required int proxyPort,
  }) = _Pi;

  late final String host = '$baseUrl:$apiPort';

  late final String baseApiUrl = '$host/$apiPath';

  late final String adminHome = '$host/admin';
}

@freezed
class PiholeApiFailure with _$PiholeApiFailure {
  factory PiholeApiFailure.notFound() = _NotFound;

  const factory PiholeApiFailure.notAuthenticated() = _NotAuthenticated;

  const factory PiholeApiFailure.invalidResponse(int statusCode) =
      _InvalidResponse;

  const factory PiholeApiFailure.emptyString() = _EmptyString;

  const factory PiholeApiFailure.emptyList() = _EmptyList;

  const factory PiholeApiFailure.cancelled() = _Cancelled;

  const factory PiholeApiFailure.timeout() = _Timeout;

  const factory PiholeApiFailure.unknown(dynamic e) = _UnknownApiFailure;
}

@freezed
class PiholeStatus with _$PiholeStatus {
  factory PiholeStatus.enabled() = PiholeStatusEnabled;

  const factory PiholeStatus.disabled() = PiholeStatusDisabled;

  const factory PiholeStatus.loading() = PiholeStatusLoading;

  const factory PiholeStatus.sleeping(Duration duration, TimeOfDay start) =
      PiholeStatusSleeping;

  const factory PiholeStatus.error(String error) = PiholeStatusError;
}

@freezed
class Summary with _$Summary {
  const factory Summary({
    required int domainsBeingBlocked,
    required int dnsQueriesToday,
    required int adsBlockedToday,
    required double adsPercentageToday,
    required int uniqueDomains,
    required int queriesForwarded,
    required int queriesCached,
    required int clientsEverSeen,
    required int uniqueClients,
    required int dnsQueriesAllTypes,
    required int replyNoData,
    required int replyNxDomain,
    required int replyCName,
    required int replyIP,
    required int privacyLevel,
    required PiholeStatus status,
  }) = _Summary;
}

double _celciusToKelvin(double temp) => temp + 273.15;

double _celciusToFahrenheit(double temp) => (temp * (9 / 5)) + 32;

@freezed
class PiDetails with _$PiDetails {
  PiDetails._();
  factory PiDetails({
    required double temperature,
    required List<double> cpuLoads,
    required double memoryUsage,
  }) = _PiDetails;

  late final String temperatureInCelcius =
      '${temperature.toStringAsFixed(1)} °C';

  late final String temperatureInFahrenheit =
      '${_celciusToFahrenheit(temperature).toStringAsFixed(1)} °F';

  late final String temperatureInKelvin =
      '${_celciusToKelvin(temperature).toStringAsFixed(1)} °K';
}

@freezed
class PiQueryTypes with _$PiQueryTypes {
  factory PiQueryTypes({required Map<String, double> types}) = _PiQueryTypes;
}

@freezed
class PiForwardDestinations with _$PiForwardDestinations {
  factory PiForwardDestinations({required Map<String, double> destinations}) =
      _PiForwardDestinations;
}

@freezed
class PiQueriesOverTime with _$PiQueriesOverTime {
  factory PiQueriesOverTime({
    required Map<DateTime, int> domainsOverTime,
    required Map<DateTime, int> adsOverTime,
  }) = _PiQueriesOverTime;
}
