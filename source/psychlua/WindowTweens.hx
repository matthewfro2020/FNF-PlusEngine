package psychlua;

import openfl.Lib;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class WindowTweens {
    public static function winTweenX(tag:String, targetX:Int, duration:Float = 1, ease:String = "linear", ?onComplete:Void->Void) {
        #if windows
        var window = Lib.current.stage.window;
        var startX = window.x;
        var variables = MusicBeatState.getVariables();
        if(tag != null) {
            var originalTag:String = tag;
            tag = LuaUtils.formatVariable('wintween_$tag');
            variables.set(tag, FlxTween.num(startX, targetX, duration, {
                ease: LuaUtils.getTweenEaseByString(ease),
                onUpdate: function(tween:FlxTween) {
                    window.x = Std.int(FlxMath.lerp(startX, targetX, tween.percent));
                },
                onComplete: function(_) {
                    variables.remove(tag);
                    if (onComplete != null) onComplete();
                    if(PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag, 'window.x']);
                }
            }));
            return tag;
        } else {
            FlxTween.num(startX, targetX, duration, {
                ease: LuaUtils.getTweenEaseByString(ease),
                onUpdate: function(tween:FlxTween) {
                    window.x = Std.int(FlxMath.lerp(startX, targetX, tween.percent));
                },
                onComplete: function(_) {
                    if (onComplete != null) onComplete();
                }
            });
        }
        #end
        return null;
    }

    public static function winTweenY(tag:String, targetY:Int, duration:Float = 1, ease:String = "linear", ?onComplete:Void->Void) {
        #if windows
        var window = Lib.current.stage.window;
        var startY = window.y;
        var variables = MusicBeatState.getVariables();
        if(tag != null) {
            var originalTag:String = tag;
            tag = LuaUtils.formatVariable('wintween_$tag');
            variables.set(tag, FlxTween.num(startY, targetY, duration, {
                ease: LuaUtils.getTweenEaseByString(ease),
                onUpdate: function(tween:FlxTween) {
                    window.y = Std.int(FlxMath.lerp(startY, targetY, tween.percent));
                },
                onComplete: function(_) {
                    variables.remove(tag);
                    if (onComplete != null) onComplete();
                    if(PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag, 'window.y']);
                }
            }));
            return tag;
        } else {
            FlxTween.num(startY, targetY, duration, {
                ease: LuaUtils.getTweenEaseByString(ease),
                onUpdate: function(tween:FlxTween) {
                    window.y = Std.int(FlxMath.lerp(startY, targetY, tween.percent));
                },
                onComplete: function(_) {
                    if (onComplete != null) onComplete();
                }
            });
        }
        #end
        return null;
    }

    public static function winTweenSize(targetW:Int, targetH:Int, duration:Float = 1, ease:String = "linear", ?onComplete:Void->Void) {
        #if windows
        var window = Lib.current.stage.window;
        var startW = window.width;
        var startH = window.height;
        FlxTween.num(0, 1, duration, {
            ease: LuaUtils.getTweenEaseByString(ease),
            onUpdate: function(tween:FlxTween) {
                window.resize(
                    Std.int(FlxMath.lerp(startW, targetW, tween.percent)),
                    Std.int(FlxMath.lerp(startH, targetH, tween.percent))
                );
                FlxG.resizeGame(window.width, window.height);
            },
            onComplete: function(_) {
                if (onComplete != null) onComplete();
            }
        });
        #end
    }
}