import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var secrets: NSDictionary?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            secrets = NSDictionary(contentsOfFile: path)
        }
        if let googleMapsApiKey = secrets?["googleMapsApiKey"] as? String {
            GMSServices.provideAPIKey(googleMapsApiKey)
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
