package com.zebra_trackaware

import android.content.*
import android.os.Bundle
import android.os.Parcelable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*


//  This sample implementation is heavily based on the flutter demo at
//  https://github.com/flutter/flutter/blob/master/examples/platform_channel/android/app/src/main/java/com/example/platformchannel/MainActivity.java


class MainActivity: FlutterActivity() {
    private val COMMAND_CHANNEL = "com.zebra_trackaware/command"
    private val SCAN_CHANNEL = "com.zebra_trackaware/scan"
    private val PROFILE_INTENT_ACTION = "com.zebra_trackaware.SCAN"
    private val PROFILE_INTENT_BROADCAST = "2"

    private val dwInterface = DWInterface()



    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        EventChannel(flutterEngine.dartExecutor, SCAN_CHANNEL).setStreamHandler(
                object : StreamHandler {
                    private var dataWedgeBroadcastReceiver: BroadcastReceiver? = null
                    override fun onListen(arguments: Any?, events: EventSink?) {
                        dataWedgeBroadcastReceiver = createDataWedgeBroadcastReceiver(events)
                        val intentFilter = IntentFilter()
                        intentFilter.addAction(PROFILE_INTENT_ACTION)
                        intentFilter.addAction(DWInterface.DATAWEDGE_RETURN_ACTION)
                        intentFilter.addCategory(DWInterface.DATAWEDGE_RETURN_CATEGORY)
                        registerReceiver(
                                dataWedgeBroadcastReceiver, intentFilter)
                    }

                    override fun onCancel(arguments: Any?) {
                        unregisterReceiver(dataWedgeBroadcastReceiver)
                        dataWedgeBroadcastReceiver = null
                    }
                }
        )

        MethodChannel(flutterEngine.dartExecutor, COMMAND_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendDataWedgeCommandStringParameter")
            {
                val arguments = JSONObject(call.arguments.toString())
                val command: String = arguments.get("command") as String
                val parameter: String = arguments.get("parameter") as String
                dwInterface.sendCommandString(applicationContext, command, parameter)
                //  result.success(0);  //  DataWedge does not return responses
            }
            else if (call.method == "createDataWedgeProfile")
            {
                createDataWedgeProfile(call.arguments.toString())
            }
            else {
                result.notImplemented()
            }
        }
    }


    private fun createDataWedgeBroadcastReceiver(events: EventSink?): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action.equals(PROFILE_INTENT_ACTION))
                {
                    //  A barcode has been scanned

                    var scanData =intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_DATA_STRING)

                    var symbology = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_LABEL_TYPE)
                    var date = Calendar.getInstance().getTime()
                    var df = SimpleDateFormat("dd/MM/yyyy HH:mm:ss")
                    var dateTimeString = df.format(date)
                    var currentScan = Scan(scanData, symbology, dateTimeString);
                    events?.success(currentScan.toJson())
                }
                //  Could handle return values from DW here such as RETURN_GET_ACTIVE_PROFILE
                //  or RETURN_ENUMERATE_SCANNERS
            }
        }
    }

    private fun createDataWedgeProfile(profileName: String) {
        //  Create and configure the DataWedge profile associated with this application
        //  For readability's sake, I have not defined each of the keys in the DWInterface file
        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", profileName)
        profileConfig.putString("PROFILE_ENABLED", "true") //  These are all strings
        profileConfig.putString("CONFIG_MODE", "UPDATE")
        val barcodeConfig = Bundle()
        barcodeConfig.putString("PLUGIN_NAME", "BARCODE")
        barcodeConfig.putString("RESET_CONFIG", "false") //  This is the default but never hurts to specify
        val barcodeProps = Bundle()
        barcodeConfig.putBundle("PARAM_LIST", barcodeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", barcodeConfig)



        val rfidConfigParamList = Bundle()
        rfidConfigParamList.putString("rfid_input_enabled", "true")
        rfidConfigParamList.putString("rfid_beeper_enable", "true")
        rfidConfigParamList.putString("rfid_led_enable", "true")
        rfidConfigParamList.putString("rfid_antenna_transmit_power", "30")
        rfidConfigParamList.putString("rfid_memory_bank", "2")
        rfidConfigParamList.putString("rfid_session", "1")
        rfidConfigParamList.putString("rfid_trigger_mode", "1")
        rfidConfigParamList.putString("rfid_filter_duplicate_tags", "true")
        rfidConfigParamList.putString("rfid_hardware_trigger_enabled", "true")
        rfidConfigParamList.putString("rfid_tag_read_duration", "250")


        val rfidConfigBundle = Bundle()
        rfidConfigBundle.putString("PLUGIN_NAME", "RFID")
        rfidConfigBundle.putString("RESET_CONFIG", "false")
        rfidConfigBundle.putBundle("PARAM_LIST", rfidConfigParamList)
        profileConfig.putBundle("PLUGIN_CONFIG", rfidConfigParamList)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)



        //  You can only configure one plugin at a time in some versions of DW, now do the intent output
        profileConfig.remove("PLUGIN_CONFIG")
        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")
        val intentProps = Bundle()
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", PROFILE_INTENT_ACTION)
        intentProps.putString("intent_delivery", PROFILE_INTENT_BROADCAST)  //  "2"
        intentConfig.putBundle("PARAM_LIST", intentProps)
        profileConfig.putBundle("PLUGIN_CONFIG", intentConfig)
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)

/*        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)
        val setConfigBundle = Bundle()
        setConfigBundle.putString("PROFILE_NAME", profileName)
        setConfigBundle.putString("PROFILE_ENABLED", "true")
        setConfigBundle.putString("CONFIG_MODE", "CREATE_IF_NOT_EXIST")
        setConfigBundle.putString("RESET_CONFIG", "false")

        // Associate profile with this app

        // Associate profile with this app
        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", getPackageName())
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        setConfigBundle.putParcelableArray("APP_LIST", arrayOf(appConfig))
        setConfigBundle.remove("PLUGIN_CONFIG")*/

        // Set RFID configuration

/*        // Set RFID configuration
        val rfidConfigParamList = Bundle()
        rfidConfigParamList.putString("rfid_input_enabled", "true")
        rfidConfigParamList.putString("rfid_beeper_enable", "true")
        rfidConfigParamList.putString("rfid_led_enable", "true")
        rfidConfigParamList.putString("rfid_antenna_transmit_power", "30")
        rfidConfigParamList.putString("rfid_hardware_key", "2")
        rfidConfigParamList.putString("rfid_memory_bank", "2")
        rfidConfigParamList.putString("rfid_session", "1")
        rfidConfigParamList.putString("rfid_trigger_mode", "0")
        rfidConfigParamList.putString("rfid_filter_duplicate_tags", "true")
        rfidConfigParamList.putString("rfid_hardware_trigger_enabled", "true")
        rfidConfigParamList.putString("rfid_tag_read_duration", "250")

        // Pre-filter

        // Pre-filter
        rfidConfigParamList.putString("rfid_pre_filter_enable", "true")
        rfidConfigParamList.putString("rfid_pre_filter_tag_pattern", "3EC")
        rfidConfigParamList.putString("rfid_pre_filter_target", "2")
        rfidConfigParamList.putString("rfid_pre_filter_memory_bank", "2")
        rfidConfigParamList.putString("rfid_pre_filter_offset", "2")
        rfidConfigParamList.putString("rfid_pre_filter_action", "2")

        // Post-filter

        // Post-filter
        rfidConfigParamList.putString("rfid_post_filter_enable", "true")
        rfidConfigParamList.putString("rfid_post_filter_no_of_tags_to_read", "2")
        rfidConfigParamList.putString("rfid_post_filter_rssi", "-54")

        val rfidConfigBundle = Bundle()
        rfidConfigBundle.putString("PLUGIN_NAME", "RFID")
        rfidConfigBundle.putString("RESET_CONFIG", "true")
        rfidConfigBundle.putBundle("PARAM_LIST", rfidConfigParamList)

        // Configure intent output for captured data to be sent to this app

        // Configure intent output for captured data to be sent to this app
        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")
        val intentProps = Bundle()
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", "com.zebra.rfid.rwdemo.RWDEMO")
        intentProps.putString("intent_category", "android.intent.category.DEFAULT")
        intentProps.putString("intent_delivery", "0")
        intentConfig.putBundle("PARAM_LIST", intentProps)

        // Add configurations into a collection

        // Add configurations into a collection
        val configBundles = ArrayList<Parcelable>()
        configBundles.add(rfidConfigBundle)
        configBundles.add(intentConfig)
        setConfigBundle.putParcelableArrayList("PLUGIN_CONFIG", configBundles)

        // Broadcast the intent

        // Broadcast the intent
        val intent = Intent()
        intent.action = "com.symbol.datawedge.api.ACTION"
        intent.putExtra("com.symbol.datawedge.api.SET_CONFIG", setConfigBundle)
        sendBroadcast(intent)*/
    }
}
