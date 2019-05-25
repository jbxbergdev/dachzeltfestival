package de.bolz.dachzeltfestival

import android.content.Context
import android.os.Bundle
import android.view.View
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView

class FlutterMap(context: Context, val registrar: PluginRegistry.Registrar, val id: Int) : PlatformView, MethodChannel.MethodCallHandler {

    private val mapView: MapView = MapView(context, GoogleMapOptions())

    override fun getView(): View {
        mapView.onCreate(Bundle())
        mapView.getMapAsync {
            registrar.messenger()
        }
        return mapView
    }

    override fun dispose() {
    }

    override fun onMethodCall(call: MethodCall?, result: MethodChannel.Result?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }
}