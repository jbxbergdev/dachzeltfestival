package de.bolz.dachzeltfestival

import android.content.Context
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PlatformMapFactory(private val registrar: PluginRegistry.Registrar): PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, id: Int, obj: Any?): PlatformView {
        return FlutterMap(requireNotNull(context), registrar, id)
    }
}