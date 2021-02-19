import 'dart:collection';
import 'dart:ui';

import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/model/geojson/place_category.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:tuple/tuple.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

abstract class MapDataRepo {
  Stream<FeatureCollection> mapFeatures();
  Stream<List<Feature>> exhibitors();
  Stream<MapConfig> mapConfig();
}

@Singleton(as: MapDataRepo)
class MapDataRepoImpl extends MapDataRepo {

  static const String _FIRESTORE_COLLECTION_CONFIG = "configuration";
  static const String _FIRESTORE_DOCUMENT_MAP_CONFIG = "map_config";
  static const String _PREFERENCE_KEY_MAP_VERSION = "map_version";
  static const String _MAP_FILE_NAME = "map.geojson";

  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;
  final Authenticator _authenticator;
  final LocaleState _localeState;

  BehaviorSubject<MapConfig> _mapConfig;

  MapDataRepoImpl(this._firestore, this._firebaseStorage, this._authenticator, this._localeState);

  @override
  Stream<FeatureCollection> mapFeatures() {

    // get to locale
    Stream<FeatureCollection> mapFeatures = _localeState.locale
        .flatMap((locale) =>
        // get map file
        _localMap().flatMap((mapFile) =>
            // parse features from file with locale
            _readFeatures(mapFile, locale.languageCode).asStream()));

    return _authenticator.authenticated.flatMap(
            (authenticated) => authenticated ? mapFeatures : Stream.value(FeatureCollection(features: List<Feature>())));
  }

  @override
  Stream<List<Feature>> exhibitors() => mapFeatures().map((featureCollection) =>
      featureCollection.features.where((feature) => feature.properties.mappedCategory == PlaceCategory.EXHIBITOR
          || feature.properties.mappedCategory == PlaceCategory.PREMIUM_EXHIBITOR).toList());

  @override
  Stream<MapConfig> mapConfig() {
    if (_mapConfig == null) {
      // _mapConfig has multiple subscribers, so we use a BehaviorSubject to reduce Firestore reads
      _mapConfig = BehaviorSubject();
      Stream<MapConfig> mapConfigFromFirestore = _firestore.collection(_FIRESTORE_COLLECTION_CONFIG).doc(_FIRESTORE_DOCUMENT_MAP_CONFIG).snapshots()
          // parse map configuration
          .map((snapshot) {
            GeoPoint initialCenter = snapshot["initial_center"];
            double initialZoom = (snapshot["initial_zoom"] as num).toDouble(); // Firestore SDK treats *.0 numbers as ints
            String mapUrl = snapshot["map_url"];
            int mapVersion = snapshot["map_version"];
            GeoPoint navDestination = snapshot["nav_destination"];
            bool isSingleLocationEvent = snapshot['is_single_location_event'];
            return MapConfig(
              initalMapCenter: Coordinates(lng: initialCenter.longitude, lat: initialCenter.latitude),
              initialZoomLevel: initialZoom,
              navDestination: Coordinates(lng: navDestination.longitude, lat: navDestination.latitude),
              mapVersion: mapVersion,
              mapUrl: mapUrl,
              isSingleLocationEvent: isSingleLocationEvent,
            );
          });
      Stream<MapConfig> sourceObservable = _authenticator.authenticated.flatMap(
              (authenticated) => authenticated ? mapConfigFromFirestore : Stream.value(null));
      sourceObservable.listen((data) => _mapConfig.add(data));
    }
    return _mapConfig.where((mapConfig) => mapConfig != null);
  }

  Stream<File> _localMap() {
    // listen to map meta data in Cloud Firestore
    Stream<void> downloadNewMap = mapConfig()
        .where((config) => config != null)
        // read version of local map, combine local version, remote version and remote map URL
        .flatMap((mapConfig) => _readPersistedMapVersion().asStream().map((persistedVersion) => Tuple2(mapConfig, persistedVersion)))
        // filter for emissions where remote and local map versions are different
        .where((mapConfigPersistedVersion) => mapConfigPersistedVersion.item1.mapVersion != mapConfigPersistedVersion.item2)
        // get remote map StorageReference
        .map((mapConfigPersistedVersion) => Tuple2(_firebaseStorage.refFromURL(mapConfigPersistedVersion.item1.mapUrl),  mapConfigPersistedVersion.item1.mapVersion))
        // download map and then persist new map version
        .flatMap((storageReferenceRemoteVersion) {
          return _localMapFile().then((file) => storageReferenceRemoteVersion.item1.writeToFile(file))
            .then((_) => _persistMapVersion(storageReferenceRemoteVersion.item2)).asStream();
        });
    // read local map immediately and when a new map version was downloaded
    Stream<void> initialTrigger = Stream.value(null);
    return Rx.merge([downloadNewMap, initialTrigger]).flatMap((_) => _localMapFile().asStream());
  }

  Future<int> _readPersistedMapVersion() => SharedPreferences.getInstance().then((sharedPreferences) => sharedPreferences.getInt(_PREFERENCE_KEY_MAP_VERSION));

  Future<void> _persistMapVersion(int mapVersion) => SharedPreferences.getInstance().then((sharedPreferences) => sharedPreferences.setInt(_PREFERENCE_KEY_MAP_VERSION, mapVersion));

  Future<File> _localMapFile() => getApplicationDocumentsDirectory().then((docsDir) => File('${docsDir.path}/$_MAP_FILE_NAME'));

  Future<FeatureCollection> _readFeatures(File mapFile, String languageCode) async {
    Map<String, dynamic> args = { 'file': mapFile, 'languageCode': languageCode };
    return compute(_parseMapFile, args);
  }
}

Future<FeatureCollection> _parseMapFile(Map<String, dynamic> args) async {
  File file = args['file'];
  String languageCode = args['languageCode'];
  if (file?.existsSync() == true) {
    return file.readAsString().then((fileContent) => _parseFeaturesFromJson(fileContent, languageCode));
  } else {
    return FeatureCollection(features: List<Feature>());
  }
}

Future<FeatureCollection> _parseFeaturesFromJson(String jsonStr, String languageCode) async {
  return jsonStr?.isNotEmpty == true ? FeatureCollection.fromJson(json.decode(jsonStr), languageCode) : FeatureCollection(features: List<Feature>());
}