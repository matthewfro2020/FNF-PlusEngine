# Video Script Guide for FNF PlusEngine

Esta guía te ayudará a reproducir videos en tus charts usando tanto **Haxe** como **Lua**.

## 📋 Requisitos

- **hxvlc** instalado en tu proyecto
- Archivo de video en formato `.mp4` en la carpeta `assets/videos/`
- FNF PlusEngine/Psych Engine

## 🎬 Implementación Básica

### Versión Haxe (.hx)

```haxe
import hxvlc.flixel.FlxVideoSprite;
import flixel.FlxCamera;
import backend.Conductor;
import Main;

var miVideo:FlxVideoSprite;
var videoArray:Array<FlxVideoSprite> = [];
var videosToDestroy:Array<FlxVideoSprite> = [];

function onCreate()
{
    FlxG.autoPause = false;

    miVideo = new FlxVideoSprite();
    miVideo.load(Paths.video('nombreDelVideo')); // Sin extensión

    videoArray = [miVideo];
    
    for (i in videoArray)
    {
        i.bitmap.rate = game.playbackRate;
        i.alpha = 0.001;
        i.cameras = [game.camOther];
        game.add(i);
    }
}

function onCreatePost()
{
    for (i in videoArray)
    {
        i.play();
        new FlxTimer().start(0.0001, function(tmr) {
            i.pause();
            i.bitmap.time = 0;
        });
    }

    FlxG.autoPause = true;
}

function onSongStart() 
{
    playVideo(miVideo, 15.0); // Duración en segundos
}

function playVideo(vid:FlxVideoSprite, endTime:Float)
{
    vid.screenCenter();
    vid.alpha = 1;
    vid.bitmap.time = 0;
    vid.resume();

    new FlxTimer().start(endTime / game.playbackRate, function(tmr) {
        vid.alpha = 0.001;
        videosToDestroy.push(vid);
    });
}

function onPause() {
    for (i in videoArray)
        if (i != null && i.alpha == 1) i.pause();
}

function onResume() {
    for (i in videoArray)
        if (i != null && i.alpha == 1) i.resume();
}

function onUpdatePost(e) {
    for (i in videoArray) if (i.alpha == 1) i.screenCenter();

    if (videosToDestroy.length > 0) 
        for (i in videosToDestroy) 
            if (i != null) i.destroy();
}

function onDestroy() {
    for (i in videoArray) if (i != null) i.destroy();
}
```

### Versión Lua (.lua)

```lua
function onCreate()
    addHaxeLibrary('FlxVideoSprite', 'hxvlc.flixel')
    addHaxeLibrary('FlxCamera', 'flixel')
    addHaxeLibrary('Conductor', 'backend')
    addHaxeLibrary('Main')
    
    runHaxeCode([[
        var miVideo:FlxVideoSprite;
        var videoArray:Array<FlxVideoSprite> = [];
        var videosToDestroy:Array<FlxVideoSprite> = [];
        
        FlxG.autoPause = false;

        miVideo = new FlxVideoSprite();
        miVideo.load(Paths.video('nombreDelVideo'));

        videoArray = [miVideo];
        
        for (i in videoArray)
        {
            i.bitmap.rate = game.playbackRate;
            i.alpha = 0.001;
            i.cameras = [game.camOther];
            game.add(i);
        }
        
        function playVideo(vid:FlxVideoSprite, endTime:Float)
        {
            vid.screenCenter();
            vid.alpha = 1;
            vid.bitmap.time = 0;
            vid.resume();

            new FlxTimer().start(endTime / game.playbackRate, function(tmr) {
                vid.alpha = 0.001;
                var videosToDestroy = getVar('videosToDestroy');
                videosToDestroy.push(vid);
                setVar('videosToDestroy', videosToDestroy);
            });
        }
        
        setVar('miVideo', miVideo);
        setVar('videoArray', videoArray);
        setVar('videosToDestroy', videosToDestroy);
    ]])
end

function onSongStart()
    runHaxeCode([[
        var miVideo = getVar('miVideo');
        playVideo(miVideo, 15.0);
    ]])
end

function onUpdatePost()
    runHaxeCode([[
        var videoArray = getVar('videoArray');
        var videosToDestroy = getVar('videosToDestroy');
        
        for (i in videoArray) if (i.alpha == 1) i.screenCenter();

        if (videosToDestroy.length > 0) 
            for (i in videosToDestroy) 
                if (i != null) i.destroy();
    ]])
end
```

## 🎛️ Personalización del Video

### Cambiar Tamaño

```haxe
// En la función playVideo, después de vid.bitmap.time = 0;
vid.scale.set(0.5, 0.5);  // 50% del tamaño original
// O tamaño específico:
vid.setGraphicSize(640, 360);
vid.updateHitbox();
```

### Cambiar Posición

```haxe
// Posición personalizada
vid.x = 100;
vid.y = 50;

// Diferentes posiciones
vid.screenCenter();           // Centro
vid.x = 0; vid.y = 0;        // Esquina superior izquierda
vid.x = FlxG.width - vid.width; // Esquina superior derecha
```

### Cambiar Opacidad

```haxe
vid.alpha = 0.8;  // 80% de opacidad
```

### Cambiar Cámara

```haxe
// En onCreate(), cambiar la cámara:
i.cameras = [game.camHUD];     // UI/HUD
i.cameras = [game.camGame];    // Juego principal
i.cameras = [game.camOther];   // Otra cámara
i.cameras = [FlxG.camera];     // Cámara principal
```

### Reproducir en Diferentes Momentos

```haxe
function onStepHit()
{
    switch (curStep)
    {
        case 128:  // Step 128
            playVideo(miVideo, 10.0);
        case 256:  // Step 256
            playVideo(otroVideo, 5.0);
    }
}

function onBeatHit()
{
    if (curBeat == 32) // Beat 32
        playVideo(miVideo, 8.0);
}
```

### Múltiples Videos

```haxe
var video1:FlxVideoSprite;
var video2:FlxVideoSprite;
var video3:FlxVideoSprite;

function onCreate()
{
    // ... código base ...
    
    video1 = new FlxVideoSprite();
    video1.load(Paths.video('intro'));
    
    video2 = new FlxVideoSprite();
    video2.load(Paths.video('drop'));
    
    video3 = new FlxVideoSprite();
    video3.load(Paths.video('outro'));

    videoArray = [video1, video2, video3];
    
    // ... resto del código ...
}

function onStepHit()
{
    switch (curStep)
    {
        case 0:   playVideo(video1, 5.0);   // Intro
        case 512: playVideo(video2, 10.0);  // Drop
        case 1024: playVideo(video3, 8.0);  // Outro
    }
}
```

## 🎨 Efectos Especiales

### Video con Fade In/Out

```haxe
function playVideoWithFade(vid:FlxVideoSprite, endTime:Float)
{
    vid.screenCenter();
    vid.alpha = 0;
    vid.bitmap.time = 0;
    vid.resume();
    
    // Fade In
    FlxTween.tween(vid, {alpha: 1}, 0.5);
    
    // Fade Out antes de terminar
    new FlxTimer().start((endTime - 1.0) / game.playbackRate, function(tmr) {
        FlxTween.tween(vid, {alpha: 0}, 1.0, {
            onComplete: function(tween) {
                videosToDestroy.push(vid);
            }
        });
    });
}
```

### Video que Gira

```haxe
function playVideoSpinning(vid:FlxVideoSprite, endTime:Float)
{
    vid.screenCenter();
    vid.alpha = 1;
    vid.bitmap.time = 0;
    vid.resume();
    
    // Rotar continuamente
    FlxTween.tween(vid, {angle: 360}, 2.0, {type: LOOPING});
    
    new FlxTimer().start(endTime / game.playbackRate, function(tmr) {
        vid.alpha = 0.001;
        videosToDestroy.push(vid);
    });
}
```

### Video con Zoom

```haxe
function playVideoZoom(vid:FlxVideoSprite, endTime:Float)
{
    vid.screenCenter();
    vid.alpha = 1;
    vid.bitmap.time = 0;
    vid.scale.set(0.1, 0.1);
    vid.resume();
    
    // Zoom In
    FlxTween.tween(vid.scale, {x: 1, y: 1}, 1.0, {ease: FlxEase.elasticOut});
    
    new FlxTimer().start(endTime / game.playbackRate, function(tmr) {
        vid.alpha = 0.001;
        videosToDestroy.push(vid);
    });
}
```

## ⚙️ Configuraciones Avanzadas

### Control de Velocidad de Reproducción

```haxe
// En onCreate()
vid.bitmap.rate = game.playbackRate * 1.5;  // 1.5x más rápido
vid.bitmap.rate = game.playbackRate * 0.5;  // 0.5x más lento
```

### Video en Loop

```haxe
function playVideoLoop(vid:FlxVideoSprite)
{
    vid.screenCenter();
    vid.alpha = 1;
    vid.bitmap.time = 0;
    vid.resume();
    vid.bitmap.onEndReached.add(function() {
        vid.bitmap.time = 0;  // Reiniciar cuando termine
    });
}
```

### Sincronización con BPM

```haxe
function onBeatHit()
{
    // Video cada 4 beats
    if (curBeat % 4 == 0)
        playVideoShort(efectoVideo, Conductor.stepCrochet * 4 / 1000);
}
```

## 📝 Consejos y Buenas Prácticas

1. **Formato de Video**: Usa `.mp4` con codec H.264 para mejor compatibilidad
2. **Rendimiento**: Videos más pequeños (resolución y duración) mejoran el rendimiento
3. **Memoria**: Siempre limpia los videos con `onDestroy()` para evitar memory leaks
4. **Timing**: Testa la sincronización en diferentes playback rates
5. **Cámaras**: Usa `camOther` para videos que no deben afectarse por efectos de cámara

## 🐛 Solución de Problemas

- **Video no aparece**: Verifica que el archivo esté en `assets/videos/`
- **Crashes**: Asegúrate de tener hxvlc instalado correctamente
- **Lag**: Reduce la resolución del video o usa compresión
- **Sincronización**: Ajusta los valores de timing según tu BPM

---

*¡Disfruta creando charts épicos con videos! 🎵🎬*

