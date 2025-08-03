package debug;

import flixel.FlxG;
import openfl.Lib;
import haxe.Timer;
import openfl.text.TextField;
import openfl.text.TextFormat;

import openfl.system.System as OpenFlSystem;
import lime.system.System as LimeSystem;
import backend.Paths;

/**
    The FPS class provides an easy-to-use monitor to display
    the current frame rate of an OpenFL project
**/
#if cpp
#if windows
@:cppFileCode('#include <windows.h>')
#elseif (ios || mac)
@:cppFileCode('#include <mach-o/arch.h>')
#else
@:headerInclude('sys/utsname.h')
#end
#end
class FPSCounter extends TextField
{
    public var currentFPS(default, null):Int;
    public var memoryMegas(get, never):Float;

    @:noCompletion private var times:Array<Float>;
    @:noCompletion private var lastFramerateUpdateTime:Float;
    @:noCompletion private var updateTime:Int;
    @:noCompletion private var framesCount:Int;
    @:noCompletion private var prevTime:Int;

    public var os:String = '';

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
    {
        super();

        #if !officialBuild
        if (LimeSystem.platformName == LimeSystem.platformVersion || LimeSystem.platformVersion == null)
            os = '\nOS: ${LimeSystem.platformName}' #if cpp + ' ${getArch() != "Unknown" ? getArch() : ""}' #end;
        else
            os = '\nOS: ${LimeSystem.platformName}' #if cpp + ' ${getArch() != "Unknown" ? getArch() : ""}' #end + ' - ${LimeSystem.platformVersion}';
        #end

        positionFPS(x, y);

        currentFPS = 0;
        selectable = false;
        mouseEnabled = false;

        // Cargar la fuente VCR del juego de forma más segura
        var vcrFont:String = null;
        try {
            // Intentar cargar la fuente del juego
            vcrFont = Paths.font("vcr.ttf");
        } catch(e:Dynamic) {
            trace('FPSCounter: Error cargando fuente VCR: $e');
            // Intentar rutas alternativas
            try {
                vcrFont = "assets/fonts/vcr.ttf";
            } catch(e2:Dynamic) {
                trace('FPSCounter: Ruta alternativa falló: $e2');
                vcrFont = null;
            }
        }
        
        // Usar fuente por defecto si VCR falla
        if (vcrFont == null) {
            vcrFont = "_sans";
            trace('FPSCounter: Usando fuente por defecto _sans');
        }
        
        defaultTextFormat = new TextFormat(vcrFont, 14, color);

        autoSize = LEFT;
        multiline = true;
        text = "FPS: ";

        times = [];
        lastFramerateUpdateTime = Timer.stamp();
        prevTime = Lib.getTimer();
        updateTime = prevTime + 500;
    }

    public dynamic function updateText():Void // so people can override it in hscript
    {
        text = 
        'FPS: $currentFPS' + 
        '\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}' +
        os;

        // Recolor dinámico según FPS
        var targetFPS = Reflect.hasField(ClientPrefs.data, "framerate") ? ClientPrefs.data.framerate : 60;
        var halfFPS = targetFPS * 0.5;

        if (currentFPS >= targetFPS) {
            textColor = 0xFF00FF00; // Verde
        } else if (currentFPS <= halfFPS) {
            textColor = 0xFFFF0000; // Rojo
        } else {
            // Interpola de amarillo a rojo
            var t = (halfFPS - (currentFPS - halfFPS)) / halfFPS;
            textColor = lerpColor(0xFFFFFF00, 0xFFFF0000, t);
        }
    }

    // Función para interpolar entre dos colores ARGB
    function lerpColor(color1:Int, color2:Int, t:Float):Int {
        var a1 = (color1 >> 24) & 0xFF;
        var r1 = (color1 >> 16) & 0xFF;
        var g1 = (color1 >> 8) & 0xFF;
        var b1 = color1 & 0xFF;

        var a2 = (color2 >> 24) & 0xFF;
        var r2 = (color2 >> 16) & 0xFF;
        var g2 = (color2 >> 8) & 0xFF;
        var b2 = color2 & 0xFF;

        var a = Std.int(a1 + (a2 - a1) * t);
        var r = Std.int(r1 + (r2 - r1) * t);
        var g = Std.int(g1 + (g2 - g1) * t);
        var b = Std.int(b1 + (b2 - b1) * t);

        return (a << 24) | (r << 16) | (g << 8) | b;
    }

    var deltaTimeout:Float = 0.0;
    private override function __enterFrame(deltaTime:Float):Void
    {
        if (Reflect.hasField(ClientPrefs.data, "fpsRework") && ClientPrefs.data.fpsRework)
        {
            // Flixel keeps reseting this to 60 on focus gained
            if (FlxG.stage.window.frameRate != ClientPrefs.data.framerate && FlxG.stage.window.frameRate != FlxG.game.focusLostFramerate)
                FlxG.stage.window.frameRate = ClientPrefs.data.framerate;

            var currentTime = openfl.Lib.getTimer();
            framesCount++;

            if (currentTime >= updateTime)
            {
                var elapsed = currentTime - prevTime;
                currentFPS = Math.ceil((framesCount * 1000) / elapsed);
                framesCount = 0;
                prevTime = currentTime;
                updateTime = currentTime + 500;
            }

            // Set Update and Draw framerate to the current FPS every 1.5 second to prevent "slowness" issue
            if ((FlxG.updateFramerate >= currentFPS + 5 || FlxG.updateFramerate <= currentFPS - 5)
                && haxe.Timer.stamp() - lastFramerateUpdateTime >= 1.5
                && currentFPS >= 30)
            {
                FlxG.updateFramerate = FlxG.drawFramerate = currentFPS;
                lastFramerateUpdateTime = haxe.Timer.stamp();
            }
        }
        else
        {
            final now:Float = haxe.Timer.stamp() * 1000;
            times.push(now);
            while (times[0] < now - 1000)
                times.shift();
            // prevents the overlay from updating every frame
            if (deltaTimeout < 50)
            {
                deltaTimeout += deltaTime;
                return;
            }

            currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
            deltaTimeout = 0.0;
        }

        updateText();
    }

    inline function get_memoryMegas():Float
        return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);

    public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
        scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
        x = FlxG.game.x + X;
        y = FlxG.game.y + Y;
    }

    #if cpp
    #if windows
    @:functionCode('
        SYSTEM_INFO osInfo;

        GetSystemInfo(&osInfo);

        switch(osInfo.wProcessorArchitecture)
        {
            case 9:
                return ::String("x86_64");
            case 5:
                return ::String("ARM");
            case 12:
                return ::String("ARM64");
            case 6:
                return ::String("IA-64");
            case 0:
                return ::String("x86");
            default:
                return ::String("Unknown");
        }
    ')
    #elseif (ios || mac)
    @:functionCode('
        const NXArchInfo *archInfo = NXGetLocalArchInfo();
        return ::String(archInfo == NULL ? "Unknown" : archInfo->name);
    ')
    #else
    @:functionCode('
        struct utsname osInfo{};
        uname(&osInfo);
        return ::String(osInfo.machine);
    ')
    #end
    @:noCompletion
    private function getArch():String
    {
        return "Unknown";
    }
    #end
}
