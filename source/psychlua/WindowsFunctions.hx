package psychlua;

#if WINDOWS_FUNCTIONS_ALLOWED
import psychlua.WindowTweens;
#end

class WindowsFunctions
{
	public static function implement(funk:FunkinLua) {
		#if WINDOWS_FUNCTIONS_ALLOWED
		var lua = funk.lua;
		
		// Window Tween Functions
		Lua_helper.add_callback(lua, "winTweenSize", function(width:Int, height:Int, duration:Float = 1, ease:String = "linear") {
			return WindowTweens.winTweenSize(width, height, duration, ease);
		});
		
		Lua_helper.add_callback(lua, "winTweenX", function(tag:String, targetX:Int, duration:Float = 1, ease:String = "linear") {
			return WindowTweens.winTweenX(tag, targetX, duration, ease);
		});
		
		Lua_helper.add_callback(lua, "winTweenY", function(tag:String, targetY:Int, duration:Float = 1, ease:String = "linear") {
			return WindowTweens.winTweenY(tag, targetY, duration, ease);
		});

		// Window Position Functions (Immediate)
		Lua_helper.add_callback(lua, "setWindowX", function(x:Int) {
			WindowTweens.setWindowX(x);
		});
		
		Lua_helper.add_callback(lua, "setWindowY", function(y:Int) {
			WindowTweens.setWindowY(y);
		});
		
		Lua_helper.add_callback(lua, "setWindowSize", function(width:Int, height:Int) {
			WindowTweens.setWindowSize(width, height);
		});
		
		// Window Information Functions
		Lua_helper.add_callback(lua, "getWindowX", function() {
			return WindowTweens.getWindowX();
		});
		
		Lua_helper.add_callback(lua, "getWindowY", function() {
			return WindowTweens.getWindowY();
		});
		
		Lua_helper.add_callback(lua, "getWindowWidth", function() {
			return WindowTweens.getWindowWidth();
		});
		
		Lua_helper.add_callback(lua, "getWindowHeight", function() {
			return WindowTweens.getWindowHeight();
		});
		
		// Window State Control Functions
		Lua_helper.add_callback(lua, "centerWindow", function() {
			WindowTweens.centerWindow();
		});
		
		// Window Properties Functions
		Lua_helper.add_callback(lua, "setWindowTitle", function(title:String) {
			WindowTweens.setWindowTitle(title);
		});
		
		Lua_helper.add_callback(lua, "getWindowTitle", function() {
			return WindowTweens.getWindowTitle();
		});
		
		Lua_helper.add_callback(lua, "setWindowIcon", function(iconPath:String) {
			WindowTweens.setWindowIcon(iconPath);
		});
		
		Lua_helper.add_callback(lua, "setWindowResizable", function(enable:Bool) {
			WindowTweens.setWindowResizable(enable);
		});
		
		Lua_helper.add_callback(lua, "randomizeWindowPosition", function(?minX:Int = 0, ?maxX:Int = -1, ?minY:Int = 0, ?maxY:Int = -1) {
			WindowTweens.randomizeWindowPosition(minX, maxX, minY, maxY);
		});
		
		// Screen Information Functions
		Lua_helper.add_callback(lua, "getScreenWidth", function() {
			return WindowTweens.getScreenResolution().width;
		});
		
		Lua_helper.add_callback(lua, "getScreenHeight", function() {
			return WindowTweens.getScreenResolution().height;
		});
		
		Lua_helper.add_callback(lua, "getScreenResolution", function() {
			return WindowTweens.getScreenResolution();
		});
		
		// Window Fullscreen Functions
		Lua_helper.add_callback(lua, "setWindowFullscreen", function(enable:Bool) {
			WindowTweens.setWindowFullscreen(enable);
		});
		
		Lua_helper.add_callback(lua, "isWindowFullscreen", function() {
			return WindowTweens.isWindowFullscreen();
		});
		
		// Window State Management Functions
		Lua_helper.add_callback(lua, "saveWindowState", function() {
			return WindowTweens.saveWindowState();
		});
		
		Lua_helper.add_callback(lua, "loadWindowState", function(stateJson:String) {
			WindowTweens.loadWindowState(stateJson);
		});
		
		// === NUEVAS FUNCIONES CON WINDOWS API ===
		
		// Window State Information Functions
		Lua_helper.add_callback(lua, "getWindowState", function() {
			return WindowTweens.getWindowState();
		});
		
		// Desktop/System Control Functions
		Lua_helper.add_callback(lua, "setDesktopWallpaper", function(path:String) {
			WindowTweens.setDesktopWallpaper(path);
		});
		
		Lua_helper.add_callback(lua, "hideDesktopIcons", function(hide:Bool) {
			WindowTweens.hideDesktopIcons(hide);
		});
		
		Lua_helper.add_callback(lua, "hideTaskBar", function(hide:Bool) {
			WindowTweens.hideTaskBar(hide);
		});
		
		Lua_helper.add_callback(lua, "moveDesktopElements", function(x:Int, y:Int) {
			WindowTweens.moveDesktopElements(x, y);
		});
		
		Lua_helper.add_callback(lua, "setDesktopTransparency", function(alpha:Float) {
			WindowTweens.setDesktopTransparency(alpha);
		});
		
		Lua_helper.add_callback(lua, "setTaskBarTransparency", function(alpha:Float) {
			WindowTweens.setTaskBarTransparency(alpha);
		});
		
		// System Information Functions
		Lua_helper.add_callback(lua, "getCursorPosition", function() {
			return WindowTweens.getCursorPosition();
		});
		
		Lua_helper.add_callback(lua, "getSystemRAM", function() {
			return WindowTweens.getSystemRAM();
		});
		
		// System Notification Functions
		Lua_helper.add_callback(lua, "showNotification", function(title:String, message:String) {
			WindowTweens.showNotification(title, message);
		});
		
		// System Reset Functions
		Lua_helper.add_callback(lua, "resetSystemChanges", function() {
			WindowTweens.resetSystemChanges();
		});

		Lua_helper.add_callback(lua, "getDesktopWindowsXPos", function() {
			return WindowTweens.getDesktopWindowsXPos();
		});

		Lua_helper.add_callback(lua, "getDesktopWindowsYPos", function() {
			return WindowTweens.getDesktopWindowsYPos();
		});

		Lua_helper.add_callback(lua, "setWindowBorderColor", function(r:Int, g:Int, b:Int) {
			WindowTweens.setWindowBorderColor(r, g, b);
		});

		Lua_helper.add_callback(lua, "setWindowOpacity", function(alpha:Float) {
			WindowTweens.setWindowOpacity(alpha);
		});

		Lua_helper.add_callback(lua, "getWindowOpacity", function() {
			return WindowTweens.getWindowOpacity();
		});

		Lua_helper.add_callback(lua, "setWindowVisible", function(visible:Bool) {
			WindowTweens.setWindowVisible(visible);
		});

		Lua_helper.add_callback(lua, "showMessageBox", function(message:String, caption:String, ?icon:String = "WARNING") {
			WindowTweens.showMessageBox(message, caption, icon);
		});

		Lua_helper.add_callback(lua, "changeWindowsWallpaper", function(path:String) {
			WindowTweens.changeWindowsWallpaper(path);
		});

		Lua_helper.add_callback(lua, "saveCurrentWallpaper", function() {
			WindowTweens.saveCurrentWallpaper();
		});

		Lua_helper.add_callback(lua, "restoreOldWallpaper", function() {
			WindowTweens.restoreOldWallpaper();
		});

		Lua_helper.add_callback(lua, "reDefineMainWindowTitle", function(title:String) {
			WindowTweens.reDefineMainWindowTitle(title);
		});

		Lua_helper.add_callback(lua, "allocConsole", function() {
			WindowTweens.allocConsole();
		});

		Lua_helper.add_callback(lua, "clearTerminal", function() {
			WindowTweens.clearTerminal();
		});

		Lua_helper.add_callback(lua, "hideMainWindow", function() {
			WindowTweens.hideMainWindow();
		});

		Lua_helper.add_callback(lua, "setConsoleTitle", function(title:String) {
			WindowTweens.setConsoleTitle(title);
		});

		Lua_helper.add_callback(lua, "setConsoleWindowIcon", function(path:String) {
			WindowTweens.setConsoleWindowIcon(path);
		});

		Lua_helper.add_callback(lua, "centerConsoleWindow", function() {
			WindowTweens.centerConsoleWindow();
		});

		Lua_helper.add_callback(lua, "disableResizeConsoleWindow", function() {
			WindowTweens.disableResizeConsoleWindow();
		});

		Lua_helper.add_callback(lua, "disableCloseConsoleWindow", function() {
			WindowTweens.disableCloseConsoleWindow();
		});

		Lua_helper.add_callback(lua, "maximizeConsoleWindow", function() {
			WindowTweens.maximizeConsoleWindow();
		});

		Lua_helper.add_callback(lua, "getConsoleWindowWidth", function() {
			return WindowTweens.getConsoleWindowWidth();
		});

		Lua_helper.add_callback(lua, "getConsoleWindowHeight", function() {
			return WindowTweens.getConsoleWindowHeight();
		});

		Lua_helper.add_callback(lua, "setConsoleCursorPosition", function(x:Int, y:Int) {
			WindowTweens.setConsoleCursorPosition(x, y);
		});

		Lua_helper.add_callback(lua, "getConsoleCursorPositionX", function() {
			return WindowTweens.getConsoleCursorPositionX();
		});

		Lua_helper.add_callback(lua, "getConsoleCursorPositionY", function() {
			return WindowTweens.getConsoleCursorPositionY();
		});

		Lua_helper.add_callback(lua, "setConsoleWindowPositionX", function(posX:Int) {
			WindowTweens.setConsoleWindowPositionX(posX);
		});

		Lua_helper.add_callback(lua, "setConsoleWindowPositionY", function(posY:Int) {
			WindowTweens.setConsoleWindowPositionY(posY);
		});

		Lua_helper.add_callback(lua, "hideConsoleWindow", function() {
			WindowTweens.hideConsoleWindow();
		});
		
		Lua_helper.add_callback(lua, "hideWindowBorder", function(enable:Bool) {
			WindowTweens.setWindowBorderless(enable);
		});
		
		Lua_helper.add_callback(lua, "setWinRCenter", function(width:Int, height:Int, ?skip:Bool = false) {
			WindowTweens.winResizeCenter(width, height, skip);
		});
		#end
	}
}