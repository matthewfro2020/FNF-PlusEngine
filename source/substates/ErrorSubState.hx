package substates;

// NOTE: This ErrorSubState is modified from the NovaFlare Engine.

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.text.FlxText.FlxTextAlign;
import states.FreeplayState;
import states.MainMenuState;
import states.PlayState;
import backend.Paths;
import backend.MusicBeatSubstate;
import backend.MusicBeatState;

import DateTools;

using StringTools;

class ErrorSubState extends MusicBeatSubstate
{
    var errorText:FlxText;
    var tips:FlxText;
    var error:String = "Oh Shit!";
    var bg:FlxSprite;
    var subcameras:FlxCamera;
    
    var saveMouseY:Int = 0;
    var moveData:Int = 0;
    var avgSpeed:Float = 0;

    var pressas:Int = 0;

    public function new(stack:String)
    {
        super();
        error = stack + "\n\nError message saved";
        FlxG.mouse.visible = true;
    }

    override function create()
    {
        super.create();
        FlxG.state.persistentUpdate = false;

        subcameras = new FlxCamera();

        // Imagen centrada y un poco más abajo
		bg = new FlxSprite().loadGraphic(Paths.image('egg'));
		bg.width = FlxG.width;
		bg.height = FlxG.height;
		bg.x = -639;
        bg.y = -179;
		bg.alpha = 0;
		add(bg);

        // Separar mensaje de error y stack trace
        var split = error.split("\n");
        var mainError = split[0];
        var stackTrace = split.slice(1).join("\n");

        // Texto de error principal (más grande)
        errorText = new FlxText(0, FlxG.height / 2 - 160, FlxG.width, mainError, 32);
        errorText.setFormat(Paths.font('vcr.ttf'), 32, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
        add(errorText);

        // Stack trace debajo del error, más pequeño
        var stackText = new FlxText(0, errorText.y + errorText.height + 10, FlxG.width, stackTrace, 20);
        stackText.setFormat(Paths.font('vcr.ttf'), 20, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
        add(stackText);

        // Texto de ayuda arriba a la izquierda, más pequeño
        var date = Date.now();
        var fechaHora = DateTools.format(date, "%A - %B %d, %Y");
        var so = "OS: " + #if windows "Windows" #elseif linux "Linux" #elseif mac "MacOS" #else "Unknown" #end;
        tips = new FlxText(
            0, 12, FlxG.width - 24,
            "Press ENTER or wait 10 seconds to close\n" + fechaHora + "\n" + so,
            20
        );
		tips.setFormat(Paths.font('vcr.ttf'), 20, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tips.x = FlxG.width - tips.width - 12; // Pegado a la derecha con un margen de 12 píxeles
		add(tips);

        errorText.cameras = [subcameras];
        stackText.cameras = [subcameras];
        tips.cameras = [subcameras];

        FlxG.cameras.add(subcameras, false);
        subcameras.bgColor.alpha = 0;

        new FlxTimer().start(10, function(tmr:FlxTimer){
           close();
        });
    }

    override function update(elapsed:Float)
    {
        bg.alpha += elapsed * 1.5;
        if(bg.alpha > 0.85) bg.alpha = 0.85; // Más claro
        if(FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end){
            pressas++;
        }

        if(pressas >= 1) {
            FlxG.state.persistentUpdate = true; // Restaura la actualización
            if (Type.getClass(FlxG.state) == PlayState) MusicBeatState.switchState(new FreeplayState());
            else MusicBeatState.switchState(new MainMenuState());

            close();
        }

        if(FlxG.mouse.pressed){
            if (errorText.height > FlxG.height)
            {
                if (FlxG.mouse.justPressed) saveMouseY = FlxG.mouse.y;
                moveData = FlxG.mouse.y - saveMouseY;
                saveMouseY = FlxG.mouse.y;

                errorText.y += moveData;
            }
            if (errorText.y < (FlxG.height - errorText.height)) errorText.y = FlxG.height - errorText.height;
            if (errorText.y > 50) errorText.y = 50;
            // Limita el rango de desplazamiento del texto de error
        }
        super.update(elapsed);
    }
    override function destroy(){
        bg = FlxDestroyUtil.destroy(bg);
        errorText = FlxDestroyUtil.destroy(errorText);
        #if mobile
            FlxG.mouse.visible = false;
        #end
        super.destroy();
    }
}
