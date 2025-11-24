package psychlua;

#if (WINDOWS_FUNCTIONS_ALLOWED && GDI_ENABLED)
import winapi.gdi.WindowsGDI;
import winapi.gdi.WindowsGDIThread;
#end

class WindowsGDIFunctions
{
	public static function implement(funk:FunkinLua) {
		#if (WINDOWS_FUNCTIONS_ALLOWED && GDI_ENABLED)
		var lua = funk.lua;

		Lua_helper.add_callback(lua, "initGDIThread", function() {
			WindowsGDIThread.initWindowsGDIThread();
		});

		Lua_helper.add_callback(lua, "stopGDIThread", function() {
			WindowsGDIThread.stopWindowsGDIThread();
		});

		Lua_helper.add_callback(lua, "pauseGDIThread", function(pause:Bool) {
			WindowsGDIThread.temporarilyPaused = pause;
		});

		Lua_helper.add_callback(lua, "isGDIThreadRunning", function() {
			return WindowsGDIThread.runningThread;
		});

		Lua_helper.add_callback(lua, "getGDIElapsedTime", function() {
			return WindowsGDIThread.elapsedTime;
		});

		Lua_helper.add_callback(lua, "prepareGDIEffect", function(effect:String, ?wait:Float = 0) {
			WindowsGDI.prepareGDIEffect(effect, wait);
		});

		Lua_helper.add_callback(lua, "enableGDIEffect", function(effect:String, ?enabled:Bool = true) {
			WindowsGDI.enableGDIEffect(effect, enabled);
		});

		Lua_helper.add_callback(lua, "removeGDIEffect", function(effect:String) {
			WindowsGDI.removeGDIEffect(effect);
		});

		Lua_helper.add_callback(lua, "setGDIEffectWaitTime", function(effect:String, wait:Float) {
			WindowsGDI.setGDIEffectWaitTime(effect, wait);
		});

		Lua_helper.add_callback(lua, "setGDIElapsedTime", function(elapsed:Float) {
			WindowsGDI.setElapsedTime(elapsed);
		});

		#end
	}
}
