//package com.denox.flow
//
//import android.content.Context
//import com.denox.flow.ui.PermissionsFragment
//import com.denox.flow.ui.PermissionsFragment.Companion.ACTIVITY_TO_OPEN
//import com.denox.flow.ui.PermissionsFragment.Companion.FRAGMENT_TO_OPEN
//import com.denox.flow.ui.bluetooth.BluetoothDevicesActivity
//import com.denox.flow.ui.installation.InstallationMainFragment
//import com.denox.flow.ui.startDefaultActivity
//import io.flutter.plugin.common.BinaryMessenger
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//
//class MenusPageMethodChannel(var context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
//
//	companion object {
//		const val CHANNEL = "menus_page"
//	}
//
//	init {
//		MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
//	}
//
//	override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//
//		when (call.method) {
//
//			"openInstallations" -> context.startDefaultActivity<PermissionsFragment>(FRAGMENT_TO_OPEN to InstallationMainFragment::class.java.name)
//			"openRecover" -> context.startDefaultActivity<PermissionsFragment>(ACTIVITY_TO_OPEN to BluetoothDevicesActivity::class.java.name)
//		}
//
//	}
//
//}