import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/datasources/api_data_source.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/features/pihole_api/data/models/many_query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_extras.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: ApiRepository)
class ApiRepositoryImpl implements ApiRepository {
  ApiRepositoryImpl([ApiDataSource apiDataSource])
      : _apiDataSource = apiDataSource ?? getIt<ApiDataSource>();

  final ApiDataSource _apiDataSource;

  /// Wrapper for accessing simple [ApiDataSource] methods.
  Future<Either<Failure, T>> fetchOrFailure<T>(
    PiholeSettings settings,
    Function dataSourceMethod,
    String description,
  ) async {
    try {
      final T result = await dataSourceMethod(settings);
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('$description failed', e));
    } catch (e) {
      return Left(Failure('$description failed with unexpected error', e));
    }
  }

  @override
  Future<Either<Failure, SummaryModel>> fetchSummary(
          PiholeSettings settings) async =>
      fetchOrFailure<SummaryModel>(
        settings,
        _apiDataSource.fetchSummary,
        'fetchSummary',
      );

  @override
  Future<Either<Failure, PiExtras>> fetchExtras(
          PiholeSettings settings) async =>
      fetchOrFailure<PiExtras>(
        settings,
        _apiDataSource.fetchExtras,
        'fetchExtras',
      );

  @override
  Future<Either<Failure, OverTimeData>> fetchQueriesOverTime(
          PiholeSettings settings) async =>
      fetchOrFailure<OverTimeData>(
        settings,
        _apiDataSource.fetchQueriesOverTime,
        'fetchQueriesOverTime',
      );

  @override
  Future<Either<Failure, OverTimeDataClients>> fetchClientsOverTime(
          PiholeSettings settings) async =>
      fetchOrFailure<OverTimeDataClients>(
        settings,
        _apiDataSource.fetchClientsOverTime,
        'fetchClientsOverTime',
      );

  @override
  Future<Either<Failure, TopSourcesResult>> fetchTopSources(
          PiholeSettings settings) async =>
      fetchOrFailure<TopSourcesResult>(
        settings,
        _apiDataSource.fetchTopSources,
        'fetchTopSources',
      );

  @override
  Future<Either<Failure, TopItems>> fetchTopItems(
          PiholeSettings settings) async =>
      fetchOrFailure<TopItems>(
        settings,
        _apiDataSource.fetchTopItems,
        'fetchTopItems',
      );

  @override
  Future<Either<Failure, ForwardDestinationsResult>> fetchForwardDestinations(
          PiholeSettings settings) async =>
      fetchOrFailure<ForwardDestinationsResult>(
        settings,
        _apiDataSource.fetchForwardDestinations,
        'fetchForwardDestinations',
      );

  @override
  Future<Either<Failure, DnsQueryTypeResult>> fetchQueryTypes(
          PiholeSettings settings) async =>
      fetchOrFailure<DnsQueryTypeResult>(
        settings,
        _apiDataSource.fetchQueryTypes,
        'fetchQueryTypes',
      );

  @override
  Future<Either<Failure, List<QueryData>>> fetchQueriesForClient(
      PiholeSettings settings, PiClient client) async {
    try {
      final ManyQueryData result =
          await _apiDataSource.fetchQueryDataForClient(settings, client);
      return Right(result.data.reversed.toList());
    } on PiException catch (e) {
      return Left(Failure('fetchQueriesForClient failed', e));
    }
  }

  @override
  Future<Either<Failure, List<QueryData>>> fetchQueriesForDomain(
      PiholeSettings settings, String domain) async {
    try {
      final ManyQueryData result =
          await _apiDataSource.fetchQueryDataForDomain(settings, domain);
      return Right(result.data.reversed.toList());
    } on PiException catch (e) {
      return Left(Failure('fetchQueriesForDomain failed', e));
    }
  }

  @override
  Future<Either<Failure, List<QueryData>>> fetchManyQueryData(
      PiholeSettings settings,
      [int maxResults]) async {
    try {
      final ManyQueryData result =
          await _apiDataSource.fetchManyQueryData(settings, maxResults);
      return Right(result.data.reversed.toList());
    } on PiException catch (e) {
      return Left(Failure('fetchManyQueryData failed', e));
    }
  }

  @override
  Future<Either<Failure, Whitelist>> fetchWhitelist(
      PiholeSettings settings) async {
    try {
      final List<Future<Whitelist>> futures = [
        _apiDataSource.fetchWhitelist(settings),
        _apiDataSource.fetchRegexWhitelist(settings),
      ];

      final List<Whitelist> responses = await Future.wait(futures);

      final Whitelist whitelist = responses.elementAt(0);
      final Whitelist regex = responses.elementAt(1);
      return Right(Whitelist(data: [
        ...whitelist.data,
        ...regex.data,
      ]));
    } on PiException catch (e) {
      return Left(Failure('fetchWhitelist failed', e));
    }
  }

  @override
  Future<Either<Failure, Blacklist>> fetchBlacklist(
      PiholeSettings settings) async {
    try {
      final List<Future<Blacklist>> futures = [
        _apiDataSource.fetchBlacklist(settings),
        _apiDataSource.fetchRegexBlacklist(settings),
      ];

      final List<Blacklist> responses = await Future.wait(futures);

      final Blacklist blacklist = responses.elementAt(0);
      final Blacklist regex = responses.elementAt(1);
      return Right(Blacklist(data: [
        ...blacklist.data,
        ...regex.data,
      ]));
    } on PiException catch (e) {
      return Left(Failure('fetchBlacklist failed', e));
    }
  }

  @override
  Future<Either<Failure, ListResponse>> addToWhitelist(
    PiholeSettings settings,
    String domain,
    bool isWildcard,
  ) async {
    try {
      final ListResponse response =
          await _apiDataSource.addToWhitelist(settings, domain, isWildcard);
      return Right(response);
    } on PiException catch (e) {
      return Left(Failure('addToWhitelist failed', e));
    }
  }

  @override
  Future<Either<Failure, ListResponse>> removeFromWhitelist(
    PiholeSettings settings,
    String domain,
    bool isWildcard,
  ) async {
    try {
      final ListResponse response = await _apiDataSource.removeFromWhitelist(
          settings, domain, isWildcard);
      return Right(response);
    } on PiException catch (e) {
      return Left(Failure('removeFromWhitelist failed', e));
    }
  }

  @override
  Future<Either<Failure, ListResponse>> addToBlacklist(
    PiholeSettings settings,
    String domain,
    bool isWildcard,
  ) async {
    try {
      final ListResponse response =
          await _apiDataSource.addToBlacklist(settings, domain, isWildcard);
      return Right(response);
    } on PiException catch (e) {
      return Left(Failure('addToBlacklist failed', e));
    }
  }

  @override
  Future<Either<Failure, ListResponse>> removeFromBlacklist(
    PiholeSettings settings,
    String domain,
    bool isWildcard,
  ) async {
    try {
      final ListResponse response = await _apiDataSource.removeFromBlacklist(
          settings, domain, isWildcard);
      return Right(response);
    } on PiException catch (e) {
      return Left(Failure('removeFromBlacklist failed', e));
    }
  }
}
