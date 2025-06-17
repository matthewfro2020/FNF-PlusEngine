package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.Font;
import openfl.system.System;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	var vcrFontName:String;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFFFF)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;

		// Carga la fuente solo una vez
		var vcrFont:Font = Font.fromFile(Paths.font("vcr.ttf"));
		vcrFontName = vcrFont.fontName;

		defaultTextFormat = new TextFormat(vcrFontName, 18, color);
		setTextFormat(defaultTextFormat);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 50) {
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText();
		deltaTimeout = 0.0;
	}

	// Función para interpolar colores RGB
	function lerpColor(color1:Int, color2:Int, t:Float):Int {
		var r1 = (color1 >> 16) & 0xFF;
		var g1 = (color1 >> 8) & 0xFF;
		var b1 = color1 & 0xFF;

		var r2 = (color2 >> 16) & 0xFF;
		var g2 = (color2 >> 8) & 0xFF;
		var b2 = color2 & 0xFF;

		var r = Std.int(r1 + (r2 - r1) * t);
		var g = Std.int(g1 + (g2 - g1) * t);
		var b = Std.int(b1 + (b2 - b1) * t);

		return 0xFF000000 | (r << 16) | (g << 8) | b;
	}

	public dynamic function updateText():Void {
		text = 'FPS: ${currentFPS}'
			+ '\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';

		if (ClientPrefs.data.showStateInFPS) {
			var stateName = "";
			if (FlxG.state != null)
				stateName = Type.getClassName(Type.getClass(FlxG.state));
			text += '\nState: $stateName';
		}

		var targetFPS = ClientPrefs.data.framerate;
		var percent = currentFPS / targetFPS;

		var color:Int;
		if (percent >= 1.0) {
			color = 0xFF00FF00;
		} else if (percent >= 0.8) {
			var t = (percent - 0.8) / 0.2;
			color = lerpColor(0xFFFFFF00, 0xFF00FF00, t);
		} else {
			var t = percent / 0.8;
			color = lerpColor(0xFFFF0000, 0xFFFFFF00, t);
		}
		textColor = color;

		// Usa el nombre de la fuente ya cargada
		var vcrFormat = new TextFormat(vcrFontName, 18, color);
		setTextFormat(vcrFormat);
		defaultTextFormat = vcrFormat;
	}

	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}
