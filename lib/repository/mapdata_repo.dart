import 'dart:ui';

import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:tuple/tuple.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';



abstract class MapDataRepo {
  Observable<FeatureCollection> mapFeatures;
  // ignore: close_sinks
  BehaviorSubject<Locale> localeSubject;
  Observable<MapConfig> mapConfig;
}

class MapDataRepoImpl extends MapDataRepo {

  static const String _FIRESTORE_COLLECTION_CONFIG = "configuration";
  static const String _FIRESTORE_DOCUMENT_MAP_CONFIG = "map_config";
  static const String _PREFERENCE_KEY_MAP_VERSION = "map_version";
  static const String _MAP_FILE_NAME = "map.geojson";
  static const String _FIRESTORE_COLLECTION_VENUE = "venue";


  final Firestore _firestore;
  final FirebaseStorage _firebaseStorage;
  final Authenticator _authenticator;

  Stream<FeatureCollection> _mapFeatures;
  BehaviorSubject<MapConfig> _mapConfig;

  MapDataRepoImpl(this._firestore, this._firebaseStorage, this._authenticator);

  @override
  // ignore: close_sinks
  final BehaviorSubject<Locale> localeSubject = BehaviorSubject.seeded(null);

  @override
  Observable<FeatureCollection> get mapFeatures {
    if (_mapFeatures == null) {
      _mapFeatures = Observable.combineLatest3<FeatureCollection, List<DocumentSnapshot>, Locale, FeatureCollection>(
        // listen for FeatureCollection from local map
          _localMap().flatMap((mapFile) => _readFeatures(mapFile).asStream()),
          // listen for venue data on Cloud Firestore
          _firestore.collection(_FIRESTORE_COLLECTION_VENUE).snapshots().map((querySnapshot) => querySnapshot.documents), localeSubject,
              (featureCollection, venueDocuments, locale) {
            // if there is venue information from the Cloud Firestore collection, modify Features with it
            return FeatureCollection(
                features: featureCollection.features.map((feature) {
                  DocumentSnapshot venueDocument = venueDocuments.firstWhere((document) =>
                  document.documentID == feature.properties?.venueId, orElse: () => null);
                  if (venueDocument != null) {
                    TranslatableDocument translatableDocument = TranslatableDocument(venueDocument, locale);
                    feature.properties.name = translatableDocument['name'];
                    feature.properties.fill = translatableDocument['color'];
                    feature.properties.stroke = translatableDocument['color'];
                  }
                  return feature;
                }).toList());
          });
    }
    return _authenticator.authenticated.flatMap(
            (authenticated) => authenticated ? _mapFeatures : Observable.just(FeatureCollection(features: List<Feature>())));
  }

  @override
  Observable<MapConfig> get mapConfig {
    if (_mapConfig == null) {
      // _mapConfig has multiple subscribers, so we use a BehaviorSubject
      _mapConfig = BehaviorSubject();
      Observable<MapConfig> mapConfigFromFirestore = Observable(_firestore.collection(_FIRESTORE_COLLECTION_CONFIG).document(_FIRESTORE_DOCUMENT_MAP_CONFIG).snapshots())
          // parse map configuration
          .map((snapshot) {
            GeoPoint initialCenter = snapshot["initial_center"];
            double initialZoom = (snapshot["initial_zoom"] as num).toDouble(); // Firestore SDK treats *.0 numbers as ints
            String mapUrl = snapshot["map_url"];
            int mapVersion = snapshot["map_version"];
            GeoPoint navDestination = snapshot["nav_destination"];
            return MapConfig(
              initalMapCenter: Coordinates(lng: initialCenter.longitude, lat: initialCenter.latitude),
              initialZoomLevel: initialZoom,
              navDestination: Coordinates(lng: navDestination.longitude, lat: navDestination.latitude),
              mapVersion: mapVersion,
              mapUrl: mapUrl,
            );
          });
      Observable<MapConfig> sourceObservable = _authenticator.authenticated.flatMap(
              (authenticated) => authenticated ? mapConfigFromFirestore : Observable.just(null));
      sourceObservable.listen((data) => _mapConfig.add(data));
    }
    return _mapConfig;
  }

  Observable<File> _localMap() {
    // listen to map meta data in Cloud Firestore
    Observable<void> downloadNewMap = mapConfig
        // read version of local map, combine local version, remote version and remote map URL
        .flatMap((mapConfig) => _readPersistedMapVersion().asStream().map((persistedVersion) => Tuple2(mapConfig, persistedVersion)))
        // filter for emissions where remote and local map versions are different
        .where((mapConfigPersistedVersion) => mapConfigPersistedVersion.item1.mapVersion != mapConfigPersistedVersion.item2)
        // get remote map StorageReference
        .flatMap((mapConfigPersistedVersion) => _firebaseStorage.getReferenceFromUrl(mapConfigPersistedVersion.item1.mapUrl).asStream()
          .map((storageReference) => Tuple2(storageReference, mapConfigPersistedVersion.item1.mapVersion)))
        // download map and then persist new map version
        .flatMap((storageReferenceRemoteVersion) {
          return _localMapFile().then((file) => storageReferenceRemoteVersion.item1.writeToFile(file).future)
            .then((_) => _persistMapVersion(storageReferenceRemoteVersion.item2)).asStream();
        });
    // read local map immediately and when a new map version was downloaded
    Observable<void> initialTrigger = Observable.just(null);
    return Observable.merge([downloadNewMap, initialTrigger]).flatMap((_) => _localMapFile().asStream());
  }

  Future<int> _readPersistedMapVersion() => SharedPreferences.getInstance().then((sharedPreferences) => sharedPreferences.getInt(_PREFERENCE_KEY_MAP_VERSION));

  Future<void> _persistMapVersion(int mapVersion) => SharedPreferences.getInstance().then((sharedPreferences) => sharedPreferences.setInt(_PREFERENCE_KEY_MAP_VERSION, mapVersion));

  Future<File> _localMapFile() => getApplicationDocumentsDirectory().then((docsDir) => File('${docsDir.path}/$_MAP_FILE_NAME'));

  Future<FeatureCollection> _readFeatures(File mapFile) async {
    return compute(_parseMapFile, mapFile);
  }

}

Future<FeatureCollection> _parseMapFile(File file) async {
  if (file?.existsSync() == true) {
    return file.readAsString().then((fileContent) => _parseFeaturesFromJson(fileContent));
  } else {
    return FeatureCollection(features: List<Feature>());
  }
}

Future<FeatureCollection> _parseFeaturesFromJson(String jsonStr) async {
  return jsonStr?.isNotEmpty == true ? FeatureCollection.fromJson(json.decode(jsonStr)) : FeatureCollection(features: List<Feature>());
}