class MapFeature<T> {
  final T geometry;
  final FeatureMetaData featureMetaData;

  MapFeature(this.geometry, this.featureMetaData);
}

class FeatureMetaData {
  final String name, description;
  FeatureMetaData(this.name, this.description);
}