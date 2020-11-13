import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

abstract class PermissionRepo {
  void requestLocationPermission();
  Stream<bool> locationPermissionState;
}

@Singleton(as: PermissionRepo)
class PermissionRepoImpl extends PermissionRepo {

  final PermissionHandler _permissionHandler = PermissionHandler();

  // ignore: close_sinks
  BehaviorSubject<bool> _locationPermission = BehaviorSubject.seeded(null); // TODO null initial value is a workaround for https://github.com/jbxbergdev/dachzeltfestival/issues/37

  @override
  Stream<bool> get locationPermissionState => _locationPermission.distinct();

  @override
  void requestLocationPermission() {
    _permissionHandler.checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then((permissionStatus) {
      switch (permissionStatus) {
        case PermissionStatus.granted:
          return Future.value(true);
        default:
          return _permissionHandler.requestPermissions([PermissionGroup.locationWhenInUse])
              .then((statusMap) => Future.value(statusMap[PermissionGroup.locationWhenInUse] == PermissionStatus.granted ));
      }
    }).then((permissionGranted) {
      _locationPermission.value = permissionGranted;
    });
  }

}