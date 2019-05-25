package de.bolz.dachzeltfestival

import io.flutter.plugin.common.PluginRegistry

object FlutterMapPlugin {

    fun registerWith(registrar: PluginRegistry.Registrar) {
        registrar.platformViewRegistry()
                .registerViewFactory("platformMap", PlatformMapFactory(registrar))
    }

}