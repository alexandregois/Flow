package com.denox.flow

import androidx.multidex.MultiDexApplication

class FlowApplication : MultiDexApplication() {

//	@Suppress("unused") //this is user for Flutter
//	var currentActivity: Activity? = null


	override fun onCreate() {
		super.onCreate()
//		FlutterMain.startInitialization(applicationContext)
//		FlutterMain.ensureInitializationComplete(applicationContext, arrayOf<String>())
//
//		if (accessToken != null) {
//			val ambientUrl = getStringPreference(Constants.AMBIENT_URL, null)
//			Constants.setApplicationAmbient(this, ambientUrl)
//		}
//
//		JodaTimeAndroid.init(this)
//		LoggedPersonModel.init(this)
//		setDefaultFont()
//		scheduleRefreshJob(this)

//		BluetoothSession.init(this) 

	}

//	private fun setDefaultFont() {
//
//		try {
//			val assets = assets
//			val regular = Typeface.createFromAsset(assets, "OpenSans-Light.ttf")
////			val italic = Typeface.createFromAsset(assets, "OpenSans-LightItalic.ttf")
////			val bold = Typeface.createFromAsset(assets, "OpenSans-Semibold.ttf")
////			val boldItalic = Typeface.createFromAsset(assets, "OpenSans-SemiboldItalic.ttf")
//
////			if (Util.isLollipop()) {
//
////				val newMap = HashMap<String, Typeface>()
////				newMap["sans-serif"] = regular
//			val staticField = Typeface::class.java.getDeclaredField("sSystemFontMap")
//			staticField.isAccessible = true
//			staticField.set(null, hashMapOf("sans-serif" to regular))
//
////			} else {
////				val DEFAULT = Typeface::class.java.getDeclaredField("DEFAULT")
////				DEFAULT.isAccessible = true
////				DEFAULT.set(null, regular)
////
////				val DEFAULT_BOLD = Typeface::class.java.getDeclaredField("DEFAULT_BOLD")
////				DEFAULT_BOLD.isAccessible = true
////				DEFAULT_BOLD.set(null, bold)
////
////				val sDefaults = Typeface::class.java.getDeclaredField("sDefaults")
////				sDefaults.isAccessible = true
////				sDefaults.set(null, arrayOf(regular, bold, italic, boldItalic))
////			}
//
//		} catch (e: NoSuchFieldException) {
//			e.printStackTrace()
//		} catch (e: IllegalAccessException) {
//			e.printStackTrace()
//		} catch (e: Throwable) {
//			e.printStackTrace()
//			//cannot crash app if there is a failure with overriding the default font!
//		}
//
//	}

}