import 'package:dachzeltfestival/model/geojson/feature.dart';
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
  Stream<FeatureCollection> observeFeatures();
}

class MapDataRepoImpl extends MapDataRepo {

  static const String _FIRESTORE_COLLECTION_CONFIG = "configuration";
  static const String _FIRESTORE_DOCUMENT_MAP_CONFIG = "map_config";
  static const String _PREFERENCE_KEY_MAP_VERSION = "map_version";
  static const String _MAP_FILE_NAME = "map.geojson";
  static const String _FIRESTORE_COLLECTION_VENUE = "venue";


  Firestore _firestore;
  FirebaseStorage _firebaseStorage;

  MapDataRepoImpl(this._firestore, this._firebaseStorage);

  @override
  Stream<FeatureCollection> observeFeatures() {
    return Observable.combineLatest2<FeatureCollection, List<DocumentSnapshot>, FeatureCollection>(
        // listen for FeatureCollection from local map
        _localMap().flatMap((mapFile) => _readFeatures(mapFile).asStream()),
        // listen for venue data on Cloud Firestore
        _firestore.collection(_FIRESTORE_COLLECTION_VENUE).snapshots().map((querySnapshot) => querySnapshot.documents),
          // if there is venue information from the Cloud Firestore collection, modify Features with it
          (featureCollection, venueDocuments) {
            return FeatureCollection(features: featureCollection.features.map((feature) {
              DocumentSnapshot venueDocument = venueDocuments.firstWhere((document) => document.documentID == feature.properties?.venueId, orElse: () => null);
              if (venueDocument != null) {
                feature.properties.name = venueDocument['name'];
                feature.properties.fill = venueDocument['color'];
                feature.properties.stroke = venueDocument['color'];
              }
              return feature;
            }).toList());
        });
  }

  Observable<File> _localMap() {
    // listen to map meta data in Cloud Firestore
    Observable<void> downloadNewMap = Observable(_firestore.collection(_FIRESTORE_COLLECTION_CONFIG).document(_FIRESTORE_DOCUMENT_MAP_CONFIG).snapshots())
        // read metadata
        .map((snapshot) {
            int mapVersion = snapshot.data['map_version'] as int;
            String mapUrl = snapshot.data['map_url'];
            return Tuple2(mapVersion, mapUrl);
          })
        // read version of local map, combine local version, remote version and remote map URL
        .flatMap((versionAndUrl) => _readPersistedMapVersion().asStream().map((persistedVersion) => Tuple3(versionAndUrl.item1, persistedVersion, versionAndUrl.item2)))
        // filter for emissions where remote and local map versions are different
        .where((remoteVersionPersistedVersionUrl) => remoteVersionPersistedVersionUrl.item1 != remoteVersionPersistedVersionUrl.item2)
        // get remote map StorageReference
        .flatMap((remoteVersionPersistedVersionUrl) => _firebaseStorage.getReferenceFromUrl(remoteVersionPersistedVersionUrl.item3).asStream()
          .map((storageReference) => Tuple2(storageReference, remoteVersionPersistedVersionUrl.item1)))
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