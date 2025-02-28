package network.chainmetric.talos.controllers

import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import plugins.Plugins

class EventSocketHandler(private val sdk: fabric.SDK) : EventChannel.StreamHandler {
    private val channels = mutableMapOf<Int, events.EventChannel>()

    override fun onListen(event: Any?, events: EventChannel.EventSink?) {
        CoroutineScope(Dispatchers.IO).launch {
            val args = (event as List<*>)
            when (val method = args[0]) {
                "bind" -> try {
                    val chaincode = args[1] as String
                    val argsJson = args[2] as String
                    val channel = Plugins.newEventSocket(sdk, chaincode).bind(argsJson)
                    channels[event.hashCode()] = channel
                    channel.setHandler {
                        artifact -> CoroutineScope(Dispatchers.Main).launch {
                            events?.success(artifact)
                        }
                    }
                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        events?.error("EventSocket::bind", e.message, null)
                    }
                }
                "subscribe" -> try {
                    val chaincode = args[1] as String
                    val eventName = args[1] as String
                    val channel = Plugins.newEventSocket(sdk, chaincode).subscribe(eventName)
                    channels[event.hashCode()] = channel
                    channel.setHandler {
                        artifact -> CoroutineScope(Dispatchers.Main).launch {
                            events?.success(artifact)
                        }
                    }
                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        events?.error("EventSocket::subscribe", e.message, null)
                    }
                }
                else -> throw IllegalStateException("Event '$method' unsupported")
            }
        }
    }

    override fun onCancel(event: Any?) {
        CoroutineScope(Dispatchers.IO).launch {
            channels[event.hashCode()]?.cancel()
        }
    }
}