//package com.denox.flow
//
//import android.content.Context
//import com.denox.flow.service.GetAllInfoService
//import com.denox.flow.util.Constants
//import com.denox.flow.util.accessToken
//import com.denox.flow.util.performLogout
//import com.github.lzyzsd.circleprogress.Utils
//import io.flutter.plugin.common.BinaryMessenger
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.view.FlutterView
//
//class UtilsChannel(var context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
//
//	companion object {
//		const val CHANNEL = "utils"
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
//			"login" -> {
//				val args = call.arguments() as List<Any>
//				val token = args[0] as String
//				val isTest = args[1] as Boolean
//				if (isTest) {
//					Constants.setApplicationAmbient(context, "&&&")
//				} else {
//					Constants.setApplicationAmbient(context, "")
//				}
//
//				context.accessToken = token
//			}
//
//			"logout" -> {
//				context.accessToken = null
//				performLogout(context)
//			}
//
//		}
//
//	}
//
//}