package backend;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import states.MainMenuState;
import haxe.ds.List;

typedef TransitionRequest = {
    var duration:Float;
    var isTransIn:Bool;
    var callback:Void->Void;
    var id:String;
}

enum TransitionState {
    NONE;
    CREATING;
    ACTIVE;
    CLOSING;
    DESTROYED;
}

class CustomFadeTransition extends MusicBeatSubstate {
    public var finishCallback:Void->Void;

    private static var transitionQueue:List<TransitionRequest> = new List();
    private static var queueMutex:Bool = false;

    private static var cameraPool:Array<FlxCamera> = [];
    private static var MAX_CAMERA_POOL:Int = 2;

    public static var currentTransition(default, null):CustomFadeTransition = null;

    private var state:TransitionState = NONE;

    private var topDoor:FlxSprite;
    private var bottomDoor:FlxSprite;
    private var waterMark:FlxText;
    private var eventText:FlxText;
    private var iconSprite:FlxSprite;

    static final DOOR_COLOR_LIGHT:FlxColor = 0xFF8B5CF6;
    static final DOOR_COLOR_MAIN:FlxColor = 0xFF6B46C1;
    static final DOOR_COLOR_DARK:FlxColor = 0xFF4C1D95;
    static final DOOR_COLOR_DARKER:FlxColor = 0xFF2D1B69;
    
    private var duration:Float;
    private var isTransIn:Bool;
    private var transitionId:String;

    private var activeTweens:Array<FlxTween> = [];

    public static function requestTransition(duration:Float = 0.5, isTransIn:Bool, callback:Void->Void = null):String {
        var id = generateId();
        
        queueTransition({
            duration: duration,
            isTransIn: isTransIn,
            callback: callback,
            id: id
        });
        
        return id;
    }

    public static function cancelTransition(id:String):Bool {
        if (currentTransition != null && currentTransition.transitionId == id) {
            currentTransition.unifiedCleanup();
            return true;
        }

        acquireMutex();
        var removed = false;
        for (req in transitionQueue) {
            if (req.id == id) {
                transitionQueue.remove(req);
                removed = true;
                break;
            }
        }
        releaseMutex();
        
        return removed;
    }

    public static function cancelAllTransitions():Void {
        if (currentTransition != null) {
            currentTransition.unifiedCleanup();
        }
        
        acquireMutex();
        transitionQueue = new List();
        releaseMutex();
    }

    private static function generateId():String {
        static var counter:Int = 0;
        return 'transition_${counter++}_${Date.now().getTime()}';
    }
    
    private static function acquireMutex():Void {
        while (queueMutex) {
            Sys.sleep(0.001);
        }
        queueMutex = true;
    }
    
    private static function releaseMutex():Void {
        queueMutex = false;
    }
    
    private static function queueTransition(request:TransitionRequest):Void {
        acquireMutex();
        transitionQueue.add(request);
        releaseMutex();

        if (currentTransition == null) {
            processNextTransition();
        }
    }
    
    private static function processNextTransition():Void {
        if (currentTransition != null) return;
        
        acquireMutex();
        var request = transitionQueue.pop();
        releaseMutex();
        
        if (request != null) {
            var transition = new CustomFadeTransition();
            transition.setup(request.duration, request.isTransIn, request.callback, request.id);
            currentTransition = transition;

            if (FlxG.state != null) {
                FlxG.state.openSubState(transition);
            }
        }
    }
    
    private static function getCameraFromPool():FlxCamera {
        if (cameraPool.length > 0) {
            return cameraPool.pop();
        }

        var cam = new FlxCamera();
        cam.bgColor = 0x00;
        cam.followLerp = 0;
        cam.pixelPerfectRender = false;
        cam.antialiasing = ClientPrefs.data.antialiasing;
        
        return cam;
    }
    
    private static function returnCameraToPool(cam:FlxCamera):Void {
        if (cam != null && cameraPool.length < MAX_CAMERA_POOL) {
            cam.clearEffects();
            cam.clearFlash();
            cam.clearShake();
            cam.target = null;
            cam.follow();
            cam.scroll.set();
            cam.zoom = 1;
            cam.alpha = 1;
            cam.angle = 0;
            
            cameraPool.push(cam);
        } else {
            cam.destroy();
        }
    }

    private function new() {
        super();
        state = CREATING;
    }

    private function setup(duration:Float, isTransIn:Bool, callback:Void->Void, id:String):Void {
        this.duration = duration;
        this.isTransIn = isTransIn;
        this.finishCallback = callback;
        this.transitionId = id;
    }
    
    override function create():Void {
        super.create();
        
        if (state != CREATING) {
            unifiedCleanup();
            return;
        }
        
        try {
            var cam = getCameraFromPool();
            FlxG.cameras.add(cam, false);
            cameras = [cam];
            
            var width = FlxG.width;
            var height = FlxG.height;

            createVisualElements(width, height);

            if (isTransIn) {
                createTransitionIn(width, height);
            } else {
                createTransitionOut(width, height);
            }
            
            state = ACTIVE;
            
        } catch (e:Dynamic) {
            trace('Error creating transition: $e');
            unifiedCleanup();
        }
    }
    
    private function createVisualElements(width:Int, height:Int):Void {
        topDoor = new FlxSprite();
        topDoor.loadGraphic(Paths.image('ui/transUp'));
        topDoor.scrollFactor.set();
        topDoor.setGraphicSize(width, height);
        topDoor.updateHitbox();
        topDoor.antialiasing = ClientPrefs.data.antialiasing;

        bottomDoor = new FlxSprite();
        bottomDoor.loadGraphic(Paths.image('ui/transDown'));
        bottomDoor.scrollFactor.set();
        bottomDoor.setGraphicSize(width, height);
        bottomDoor.updateHitbox();
        bottomDoor.antialiasing = ClientPrefs.data.antialiasing;

        iconSprite = new FlxSprite();
        iconSprite.loadGraphic(Paths.image('loading_screen/icon'));
        iconSprite.scrollFactor.set();
        iconSprite.scale.set(0.5, 0.5);
        iconSprite.screenCenter();

        waterMark = new FlxText(0, height - 140, 300, 'Plus Engine\nv${MainMenuState.plusEngineVersion}', 32);
        waterMark.x = (width - waterMark.width) / 2;
        waterMark.setFormat(Paths.font("aller.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        waterMark.scrollFactor.set();
        waterMark.borderSize = 2;

        eventText = new FlxText(50, height - 60, 300, '', 28);
        eventText.x = (width - eventText.width) / 2;
        eventText.setFormat(Paths.font("aller.ttf"), 28, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        eventText.scrollFactor.set();
        eventText.borderSize = 2;
        
        add(topDoor);
        add(bottomDoor);
        add(iconSprite);
        add(waterMark);
        add(eventText);
    }
    
    private function createTransitionIn(width:Int, height:Int):Void {
        topDoor.y = 0;
        bottomDoor.y = 0;
        iconSprite.alpha = 1;
        
        waterMark.alpha = 1;
        eventText.alpha = 1;
        eventText.text = Language.getPhrase('trans_opening', 'Opening...');

        try {
            FlxG.sound.play(Paths.sound('FadeTransition'), 0.4);
        } catch (e:Dynamic) {}

        addTween(FlxTween.tween(topDoor, {y: -height}, duration, {
            ease: FlxEase.expoInOut
        }));
        
        addTween(FlxTween.tween(bottomDoor, {y: height}, duration, {
            ease: FlxEase.expoInOut,
            onComplete: function(tween:FlxTween) {
                safeTransitionComplete();
            }
        }));
        
        addTween(FlxTween.tween(waterMark, {y: waterMark.y + 100, alpha: 0}, duration, {
            ease: FlxEase.expoInOut
        }));
        
        addTween(FlxTween.tween(eventText, {y: eventText.y + 100, alpha: 0}, duration, {
            ease: FlxEase.expoInOut
        }));
        
        addTween(FlxTween.tween(iconSprite, {alpha: 0}, duration, {
            ease: FlxEase.expoInOut
        }));
    }
    
    private function createTransitionOut(width:Int, height:Int):Void {
        topDoor.y = -height;
        bottomDoor.y = height;
        iconSprite.alpha = 0;
        
        eventText.text = Language.getPhrase('trans_loading', 'Loading...');
        waterMark.y = waterMark.y + 100;
        waterMark.alpha = 0;
        eventText.y = eventText.y + 100;
        eventText.alpha = 0;

        addTween(FlxTween.tween(waterMark, {y: waterMark.y - 100, alpha: 1}, duration, {
            ease: FlxEase.expoInOut
        }));
        
        addTween(FlxTween.tween(eventText, {y: eventText.y - 100, alpha: 1}, duration, {
            ease: FlxEase.expoInOut
        }));
        
        addTween(FlxTween.tween(topDoor, {y: 0}, duration, {
            ease: FlxEase.expoInOut
        }));
        
        addTween(FlxTween.tween(bottomDoor, {y: 0}, duration, {
            ease: FlxEase.expoInOut,
            onComplete: function(tween:FlxTween) {
                addTween(FlxTween.tween(iconSprite, {alpha: 1}, 0.3, {
                    ease: FlxEase.sineIn,
                    onComplete: function(tween:FlxTween) {
                        safeTransitionComplete();
                    }
                }));
            }
        }));
    }

    private function unifiedCleanup():Void {
        if (state == DESTROYED) return;

        var previousState = state;
        state = CLOSING;
        
        trace('Cleaning up transition: $transitionId (from state: $previousState)');

        cancelAllTweens();

        if (previousState == ACTIVE && finishCallback != null) {
            try {
                finishCallback();
            } catch (e:Dynamic) {
                trace("Error in finish callback: " + e);
            }
        }

        finishCallback = null;

        if (cameras != null && cameras.length > 0) {
            var cam = cameras[0];
            if (cam != null) {
                FlxG.cameras.remove(cam, false);
                returnCameraToPool(cam);
            }
            cameras = [];
        }

        destroyVisualElements();

        if (currentTransition == this) {
            currentTransition = null;

            processNextTransition();
        }

        if (previousState != DESTROYED) {
            try {
                super.close();
            } catch (e:Dynamic) {
                trace("Error in super.close(): " + e);
            }
        }
        
        state = DESTROYED;
    }
    
    private function safeTransitionComplete():Void {
        if (state == ACTIVE) {
            unifiedCleanup();
        }
    }
    
    private function destroyVisualElements():Void {
        var elements = [topDoor, bottomDoor, iconSprite, waterMark, eventText];
        for (element in elements) {
            if (element != null) {
                try {
                    if (exists) remove(element);
                    element.destroy();
                } catch (e:Dynamic) {
                    trace("Error destroying element: " + e);
                }
            }
        }
        
        topDoor = null;
        bottomDoor = null;
        iconSprite = null;
        waterMark = null;
        eventText = null;
    }

    private function addTween(tween:FlxTween):FlxTween {
        if (tween != null && state == ACTIVE) {
            activeTweens.push(tween);
        }
        return tween;
    }
    
    private function cancelAllTweens():Void {
        try {
            for (tween in activeTweens) {
                if (tween != null && !tween.finished) {
                    tween.cancel();
                }
            }
            activeTweens = [];
        } catch (e:Dynamic) {
            trace("Error canceling tweens: " + e);
        }
    }
    
    override function update(elapsed:Float):Void {
        super.update(elapsed);

        if (state == ACTIVE && currentTransition != this) {
            trace('Transition $transitionId orphaned, cleaning up');
            unifiedCleanup();
        }
    }
    
    override function close():Void {
        unifiedCleanup();
    }
    
    override function destroy():Void {
        unifiedCleanup();
        super.destroy();
    }

    public function getId():String {
        return transitionId;
    }
    
    public function getState():String {
        return switch(state) {
            case NONE: "none";
            case CREATING: "creating";
            case ACTIVE: "active";
            case CLOSING: "closing";
            case DESTROYED: "destroyed";
        }
    }
}