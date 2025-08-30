package psychlua;

import openfl.Lib;
import openfl.system.Capabilities;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import states.PlayState;
import haxe.Timer;

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
    
    public static function setWindowBorderless(enable:Bool) {
    #if windows
    var window = Lib.current.stage.window;
    window.borderless = enable;
    #end
    }

    public static function setWindowX(x:Int) {
        #if windows
        var window = Lib.current.stage.window;
        window.x = x;
        #end
    }

    public static function setWindowY(y:Int) {
        #if windows
        var window = Lib.current.stage.window;
        window.y = y;
        #end
    }

    public static function setWindowSize(width:Int, height:Int) {
        #if windows
        var window = Lib.current.stage.window;
        window.resize(width, height);
        FlxG.resizeGame(width, height);
        #end
    }

    public static function getWindowX():Int {
        #if windows
        var window = Lib.current.stage.window;
        return window.x;
        #else
        return 0;
        #end
    }

    public static function getWindowY():Int {
        #if windows
        var window = Lib.current.stage.window;
        return window.y;
        #else
        return 0;
        #end
    }

    public static function getWindowWidth():Int {
        #if windows
        var window = Lib.current.stage.window;
        return window.width;
        #else
        return FlxG.width;
        #end
    }

    public static function getWindowHeight():Int {
        #if windows
        var window = Lib.current.stage.window;
        return window.height;
        #else
        return FlxG.height;
        #end
    }

    public static function centerWindow() {
        #if windows
        var window = Lib.current.stage.window;
        var screenWidth = Capabilities.screenResolutionX;
        var screenHeight = Capabilities.screenResolutionY;
        window.x = Std.int((screenWidth - window.width) / 2);
        window.y = Std.int((screenHeight - window.height) / 2);
        #end
    }

    // Las funciones maximize, minimize y restore no están disponibles en Lime 8.1.2
    public static function maximizeWindow() {}
    public static function minimizeWindow() {}
    public static function restoreWindow() {}

    public static function setWindowTitle(title:String) {
        #if windows
        var window = Lib.current.stage.window;
        window.title = title;
        #end
    }

    public static function getWindowTitle():String {
        #if windows
        var window = Lib.current.stage.window;
        return window.title;
        #else
        return "";
        #end
    }

    public static function setWindowIcon(iconPath:String) {
        #if windows
        try {
            var window = Lib.current.stage.window;
            var iconBitmap = openfl.display.BitmapData.fromFile(iconPath);
            if (iconBitmap != null) {
                window.setIcon(lime.graphics.Image.fromBitmapData(iconBitmap));
            }
        } catch (e:Dynamic) {
            trace('Error setting window icon: $e');
        }
        #end
    }

    // alwaysOnTop no está disponible en Lime 8.1.2
    public static function setWindowAlwaysOnTop(enable:Bool) {}

    public static function setWindowResizable(enable:Bool) {
        #if windows
        var window = Lib.current.stage.window;
        window.resizable = enable;
        #end
    }

    // requestAttention no está disponible en Lime 8.1.2
    public static function flashWindow() {}

    public static function setWindowOpacity(opacity:Float) {
        #if windows
        var window = Lib.current.stage.window;
        // Clamp opacity between 0.0 and 1.0
        var clampedOpacity = Math.max(0.0, Math.min(1.0, opacity));
        // Convert to 0-255 range for window
        var alphaValue = Std.int(clampedOpacity * 255);
        // This requires additional native implementation
        // For now, we'll store the value for potential future use
        trace('Window opacity set to: $clampedOpacity');
        #end
    }

    public static function shakeWindow(intensity:Float = 5.0, duration:Float = 0.5) {
        #if windows
        var window = Lib.current.stage.window;
        var originalX = window.x;
        var originalY = window.y;
        var startTime = haxe.Timer.stamp();
        
        var shakeTimer = new haxe.Timer(16); // ~60 FPS
        shakeTimer.run = function() {
            var elapsed = haxe.Timer.stamp() - startTime;
            if (elapsed >= duration) {
                window.x = originalX;
                window.y = originalY;
                shakeTimer.stop();
                return;
            }
            
            var progress = elapsed / duration;
            var currentIntensity = intensity * (1.0 - progress); // Decrease over time
            
            var shakeX = Std.int(originalX + (Math.random() - 0.5) * currentIntensity * 2);
            var shakeY = Std.int(originalY + (Math.random() - 0.5) * currentIntensity * 2);
            
            window.x = shakeX;
            window.y = shakeY;
        };
        #end
    }

    public static function bounceWindow(bounces:Int = 3, height:Float = 50.0, duration:Float = 1.0) {
        #if windows
        var window = Lib.current.stage.window;
        var originalY = window.y;
        var bounceHeight = Std.int(height);
        
        // Create a bounce animation
        var bounceCount = 0;
        var isGoingUp = true;
        var targetY = originalY - bounceHeight;
        
        function doBounce() {
            if (bounceCount >= bounces) {
                // Return to original position
                winTweenY(null, originalY, 0.2, "quadOut");
                return;
            }
            
            var bounceIntensity = 1.0 - (bounceCount / bounces); // Decrease each bounce
            var currentHeight = Std.int(bounceHeight * bounceIntensity);
            
            if (isGoingUp) {
                targetY = originalY - currentHeight;
            } else {
                targetY = originalY;
                bounceCount++;
            }
            
            winTweenY(null, targetY, duration / (bounces * 2), "quadInOut", function() {
                isGoingUp = !isGoingUp;
                doBounce();
            });
        }
        
        doBounce();
        #end
    }

    public static function orbitWindow(centerX:Int, centerY:Int, radius:Float = 100.0, speed:Float = 1.0, duration:Float = 5.0) {
        #if windows
        var window = Lib.current.stage.window;
        var startTime = haxe.Timer.stamp();
        var angle:Float = 0.0;
        
        var orbitTimer = new haxe.Timer(16); // ~60 FPS
        orbitTimer.run = function() {
            var elapsed = haxe.Timer.stamp() - startTime;
            if (elapsed >= duration) {
                orbitTimer.stop();
                return;
            }
            
            angle += speed * 0.1; // Adjust speed multiplier as needed
            var x = centerX + Math.cos(angle) * radius;
            var y = centerY + Math.sin(angle) * radius;
            
            window.x = Std.int(x);
            window.y = Std.int(y);
        };
        #end
    }

    public static function pulseWindow(minScale:Float = 0.8, maxScale:Float = 1.2, pulseSpeed:Float = 2.0, duration:Float = 3.0) {
        #if windows
        var window = Lib.current.stage.window;
        var originalWidth = window.width;
        var originalHeight = window.height;
        var originalX = window.x;
        var originalY = window.y;
        var startTime = haxe.Timer.stamp();
        
        var pulseTimer = new haxe.Timer(16); // ~60 FPS
        pulseTimer.run = function() {
            var elapsed = haxe.Timer.stamp() - startTime;
            if (elapsed >= duration) {
                // Restore original size and position
                window.resize(originalWidth, originalHeight);
                window.x = originalX;
                window.y = originalY;
                FlxG.resizeGame(originalWidth, originalHeight);
                pulseTimer.stop();
                return;
            }
            
            var pulse = Math.sin(elapsed * pulseSpeed * Math.PI) * 0.5 + 0.5; // 0 to 1
            var scale = minScale + (maxScale - minScale) * pulse;
            
            var newWidth = Std.int(originalWidth * scale);
            var newHeight = Std.int(originalHeight * scale);
            
            // Center the window while scaling
            var newX = originalX + Std.int((originalWidth - newWidth) / 2);
            var newY = originalY + Std.int((originalHeight - newHeight) / 2);
            
            window.resize(newWidth, newHeight);
            window.x = newX;
            window.y = newY;
            FlxG.resizeGame(newWidth, newHeight);
        };
        #end
    }

    public static function spinWindow(rotations:Int = 1, duration:Float = 2.0) {
        #if windows
        var window = Lib.current.stage.window;
        var centerX = window.x + Std.int(window.width / 2);
        var centerY = window.y + Std.int(window.height / 2);
        var startTime = haxe.Timer.stamp();
        var totalRotation = rotations * 360.0;
        
        var spinTimer = new haxe.Timer(16); // ~60 FPS
        spinTimer.run = function() {
            var elapsed = haxe.Timer.stamp() - startTime;
            if (elapsed >= duration) {
                // Return to original position
                window.x = centerX - Std.int(window.width / 2);
                window.y = centerY - Std.int(window.height / 2);
                spinTimer.stop();
                return;
            }
            
            var progress = elapsed / duration;
            var currentRotation = totalRotation * progress;
            var radians = currentRotation * Math.PI / 180.0;
            
            // Calculate position as if rotating around center point
            var radius = Math.sqrt(Math.pow(window.width / 2, 2) + Math.pow(window.height / 2, 2));
            var x = centerX + Math.cos(radians) * (window.width / 2) - Std.int(window.width / 2);
            var y = centerY + Math.sin(radians) * (window.height / 2) - Std.int(window.height / 2);
            
            window.x = Std.int(x);
            window.y = Std.int(y);
        };
        #end
    }

    public static function randomizeWindowPosition(minX:Int = 0, maxX:Int = -1, minY:Int = 0, maxY:Int = -1) {
        #if windows
        var window = Lib.current.stage.window;
        var screenWidth = Capabilities.screenResolutionX;
        var screenHeight = Capabilities.screenResolutionY;
        
        // Use screen bounds if not specified
    if (maxX == -1) maxX = Std.int(screenWidth - window.width);
    if (maxY == -1) maxY = Std.int(screenHeight - window.height);
        
        // Ensure mins don't exceed maxs
        minX = Std.int(Math.min(minX, maxX));
        minY = Std.int(Math.min(minY, maxY));
        
        var randomX = Std.int(minX + Math.random() * (maxX - minX));
        var randomY = Std.int(minY + Math.random() * (maxY - minY));
        
        window.x = randomX;
        window.y = randomY;
        #end
    }

    public static function getScreenResolution():{width:Int, height:Int} {
        return {
            width: Std.int(Capabilities.screenResolutionX),
            height: Std.int(Capabilities.screenResolutionY)
        };
    }

    public static function getMonitorCount():Int {
        #if windows
        // This would require additional native implementation
        // For now, return 1 as default
        return 1;
        #else
        return 1;
        #end
    }

    public static function moveWindowToMonitor(monitorIndex:Int) {
        #if windows
        // This would require additional native implementation
        // For now, just move to screen bounds
        centerWindow();
        #end
    }

    public static function setWindowFullscreen(enable:Bool) {
        #if windows
        var window = Lib.current.stage.window;
        window.fullscreen = enable;
        #end
    }

    public static function isWindowFullscreen():Bool {
        #if windows
        var window = Lib.current.stage.window;
        return window.fullscreen;
        #else
        return false;
        #end
    }

    public static function saveWindowState():String {
        #if windows
        var window = Lib.current.stage.window;
        var state = {
            x: window.x,
            y: window.y,
            width: window.width,
            height: window.height,
            borderless: window.borderless,
            resizable: window.resizable,
            title: window.title
        };
        return haxe.Json.stringify(state);
        #else
        return "{}";
        #end
    }

    public static function loadWindowState(stateJson:String) {
        #if windows
        try {
            var state = haxe.Json.parse(stateJson);
            var window = Lib.current.stage.window;
            
            if (state.x != null) window.x = state.x;
            if (state.y != null) window.y = state.y;
            if (state.width != null && state.height != null) {
                window.resize(state.width, state.height);
                FlxG.resizeGame(state.width, state.height);
            }
            if (state.borderless != null) window.borderless = state.borderless;
            if (state.resizable != null) window.resizable = state.resizable;
            if (state.title != null) window.title = state.title;
        } catch (e:Dynamic) {
            trace('Error loading window state: $e');
        }
        #end
    }

    public static function winTweenSize(targetW:Int, targetH:Int, duration:Float = 1, ease:String = "linear", ?onComplete:Void->Void) {
        #if windows
        var window = Lib.current.stage.window;
        var startW = window.width;
        var startH = window.height;

        // Cambia el modo de escala para que el juego se estire con la ventana
        FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();

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

    public static function winResizeCenter(width:Int, height:Int, ?skip:Bool = false) {
        PlayState.instance.windowResizedByScript = true;
        var window = Lib.application.window;
        var camHUD = PlayState.instance.camHUD;
        var winYRatio = 1;
        var winY = height * winYRatio;
        var winX = width * winYRatio;

        FlxTween.cancelTweensOf(window);
        if (!skip) {
            FlxTween.tween(window, {
                width: winX,
                height: winY,
                y: Math.floor((Capabilities.screenResolutionY / 2) - (winY / 2)),
                x: Math.floor((Capabilities.screenResolutionX / 2) - (winX / 2)) + (Capabilities.screenResolutionX * Math.floor(window.x / (Capabilities.screenResolutionX)))
            }, 0.4, {
                ease: FlxEase.quadInOut,
                onComplete: function(_) camHUD.fade(FlxColor.BLACK, 0, true)
            });
        } else {
            FlxG.resizeWindow(width, height);
            window.y = Math.floor((Capabilities.screenResolutionY / 2) - (winY / 2));
            window.x = Std.int(Math.floor((Capabilities.screenResolutionX / 2) - (winX / 2)) + (Capabilities.screenResolutionX * Math.floor(window.x / (Capabilities.screenResolutionX))));
        }
        FlxG.scaleMode = new RatioScaleMode(true);
        window.resizable = width == 1280;
    }
}