//Tengo sueño
//Im sleepy

/*
    FunkinModchart - Plantilla avanzada para scripts de modchart en FNF PlusEngine
    https://github.com/TheoDevelops/FunkinModchart

    AUTOR PRINCIPAL:
      - TheoDev (TheoDevelops)
    CONTRIBUIDORES:
      - Ne_Eo (Neo)
      - Edwhak
      - Tsaku
      - Y más en el repositorio oficial.

    -----------------------------------------------
    ¿QUÉ ES FUNKINMODCHART?
    -----------------------------------------------
    Es una librería para Friday Night Funkin' que permite modificar visualmente las flechas, HUD y más, 
    inspirada en NotITG/StepMania. Puedes crear efectos avanzados como trayectorias, rotaciones 3D, 
    escalados, transparencias, cambios de color, rebotes, efectos por beat, eventos personalizados, 
    playfields múltiples y mucho más.

    -----------------------------------------------
    ¿CÓMO USAR ESTA PLANTILLA?
    -----------------------------------------------
    1. No
    2. IMPORTANTE: Usa SIEMPRE la función onCreatePost() para inicializar el Manager y los modificadores.
       Así evitas errores de inicialización y aseguras que las flechas y strums ya existen.
    3. Si quieres efectos dinámicos por frame, usa onUpdatePost(elapsed:Float).
    4. Importa siempre lo necesario:
*/

import modchart.Manager;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

/*
    -----------------------------------------------
    EJEMPLO DE USO AVANZADO
    -----------------------------------------------
*/

var instance:Manager = null;

function onCreatePost() {
    // Instancia y agrega el Manager al estado
    instance = new Manager();
    add(instance);

    // MODIFICADORES DISPONIBLES (puedes agregar más si tu engine/modchart los soporta)
    instance.addModifier("drunk", -1);     // Zigzag horizontal
    instance.addModifier("tipsy", -1);     // Zigzag vertical
    instance.addModifier("roll", -1);      // Rotación 3D
    instance.addModifier("mini", -1);      // Escalado
    instance.addModifier("alpha", -1);     // Transparencia
    instance.addModifier("color", -1);     // Color (usa FlxColor o hex)
    instance.addModifier("bumpy", -1);     // Rebote vertical
    // Puedes registrar modificadores personalizados con instance.registerModifier(nombre, clase);

    // PLAYFIELDS: Puedes crear varios playfields para efectos independientes
    // instance.addPlayfield();

    // EFECTOS INICIALES
    instance.setPercent("drunk", 0, -1);
    instance.setPercent("tipsy", 0, -1);
    instance.setPercent("roll", 0, -1);
    instance.setPercent("mini", 1, -1);
    instance.setPercent("alpha", 1, -1);
    instance.setPercent("color", 0xFFFFFFFF, -1);

    // EJEMPLOS DE EVENTOS Y TWEENS
    instance.ease("drunk", 4, 4, 0.5, FlxEase.sineInOut, -1, -1); // Zigzag horizontal suave en beat 4
    instance.ease("tipsy", 16, 4, 0.7, FlxEase.sineInOut, -1, -1); // Zigzag vertical en beat 16
    instance.ease("roll", 16, 8, 1, FlxEase.cubeInOut, -1, -1);    // Rotación en beat 16
    instance.set("color", 16, FlxColor.RED, -1, -1);               // Cambia a rojo en beat 16
    instance.ease("bumpy", 32, 8, 1, FlxEase.sineInOut, -1, -1);   // Rebote en beat 32
    instance.ease("alpha", 32, 8, 0.5, FlxEase.cubeInOut, -1, -1); // Transparencia baja en beat 32

    // Parpadeo de transparencia entre beats 72 y 80
    instance.repeater(72, 8, function() {
        var val = instance.getPercent("alpha", -1) == 1 ? 0.2 : 1;
        instance.setPercent("alpha", val, -1);
    }, -1);

    // Efecto arcoíris en los últimos beats
    for (i in 0...14) {
        var hue = Std.int(360 * (i / 14));
        var color = FlxColor.fromHSB(hue, 1, 1);
        instance.set("color", 120 + i, color, -1, -1);
    }

    // Callbacks de mensajes
    instance.callback(16, function() trace("¡Beat 16! Rotación y color rojo activados."), -1);
    instance.callback(120, function() trace("¡Beat 120! Efecto arcoíris."), -1);
}

/*
    -----------------------------------------------
    EFECTOS DINÁMICOS POR FRAME (opcional)
    -----------------------------------------------
    Usa onUpdatePost(elapsed:Float) para efectos avanzados que cambian cada frame.
    Ejemplo: hacer que el escalado (mini) oscile con el tiempo.
*/

function onUpdatePost(elapsed:Float) {
    if (instance != null) {
        var osc = 0.5 + 0.5 * Math.sin(FlxG.game.ticks / 10);
        instance.setPercent("mini", osc, -1);
    }
}

/*
    -----------------------------------------------
    FUNCIONES Y UTILIDADES DEL MANAGER (RESUMEN)
    -----------------------------------------------
    - instance.addModifier(mod, field): Añade un modificador al playfield.
    - instance.setPercent(mod, value, field): Cambia el valor de un modificador.
    - instance.getPercent(mod, field): Obtiene el valor actual de un modificador.
    - instance.registerModifier(modN, mod): Registra un modificador personalizado.
    - instance.set(mod, beat, value, player, field): Cambia el valor de un modificador en un beat.
    - instance.ease(mod, beat, length, value, ease, player, field): Tweenea el valor de un modificador.
    - instance.callback(beat, func, field): Ejecuta una función en un beat.
    - instance.repeater(beat, length, func, field): Ejecuta una función varias veces desde un beat.
    - instance.addEvent(event, field): Añade un evento personalizado.
    - instance.addPlayfield(): Añade un nuevo playfield (recuerda añadir los mods a ese playfield).
    - Puedes usar FlxColor o valores hexadecimales para colores.

    -----------------------------------------------
    NOTAS IMPORTANTES PARA MODDERS
    -----------------------------------------------
    - Siempre usa onCreatePost para inicializar el Manager y los mods.
    - Usa onUpdatePost para efectos dinámicos por frame.
    - No crees más de una instancia de Manager por canción.
    - Consulta la documentación oficial para más detalles y ejemplos:
      https://github.com/TheoDevelops/FunkinModchart

    ¡Diviértete creando modcharts avanzados!
*/

//English

/*
    FunkinModchart - Advanced Template for Modchart Scripts in FNF PlusEngine
    https://github.com/TheoDevelops/FunkinModchart

    MAIN AUTHOR:
      - TheoDev (TheoDevelops)
    CONTRIBUTORS:
      - Ne_Eo (Neo)
      - Edwhak
      - Tsaku
      - And more on the official repository.

    -----------------------------------------------
    WHAT IS FUNKINMODCHART?
    -----------------------------------------------
    It is a library for Friday Night Funkin' that allows you to visually modify arrows, HUD, and more,
    inspired by NotITG/StepMania. You can create advanced effects like trajectories, 3D rotations,
    scaling, transparency, color changes, bounces, beat-based effects, custom events, multiple playfields,
    and much more.

    -----------------------------------------------
    HOW TO USE THIS TEMPLATE?
    -----------------------------------------------
    1. No
    2. IMPORTANT: ALWAYS use the onCreatePost() function to initialize the Manager and modifiers.
       This avoids initialization errors and ensures arrows and strums already exist.
    3. For dynamic per-frame effects, use onUpdatePost(elapsed:Float).
    4. Always import the required classes:
*/

import modchart.Manager;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

/*
    -----------------------------------------------
    ADVANCED USAGE EXAMPLE
    -----------------------------------------------
*/

var instance:Manager = null;

function onCreatePost() {
    // Instantiate and add the Manager to the state
    instance = new Manager();
    add(instance);

    // AVAILABLE MODIFIERS (add more if your engine/modchart supports them)
    instance.addModifier("drunk", -1);     // Horizontal zigzag
    instance.addModifier("tipsy", -1);     // Vertical zigzag
    instance.addModifier("roll", -1);      // 3D rotation
    instance.addModifier("mini", -1);      // Scaling
    instance.addModifier("alpha", -1);     // Transparency
    instance.addModifier("color", -1);     // Color (use FlxColor or hex)
    instance.addModifier("bumpy", -1);     // Vertical bounce
    // You can register custom modifiers with instance.registerModifier(name, class);

    // PLAYFIELDS: You can create multiple playfields for independent effects
    // instance.addPlayfield();

    // INITIAL EFFECTS
    instance.setPercent("drunk", 0, -1);
    instance.setPercent("tipsy", 0, -1);
    instance.setPercent("roll", 0, -1);
    instance.setPercent("mini", 1, -1);
    instance.setPercent("alpha", 1, -1);
    instance.setPercent("color", 0xFFFFFFFF, -1);

    // EVENTS AND TWEENS EXAMPLES
    instance.ease("drunk", 4, 4, 0.5, FlxEase.sineInOut, -1, -1); // Smooth horizontal zigzag at beat 4
    instance.ease("tipsy", 16, 4, 0.7, FlxEase.sineInOut, -1, -1); // Vertical zigzag at beat 16
    instance.ease("roll", 16, 8, 1, FlxEase.cubeInOut, -1, -1);    // Rotation at beat 16
    instance.set("color", 16, FlxColor.RED, -1, -1);               // Change to red at beat 16
    instance.ease("bumpy", 32, 8, 1, FlxEase.sineInOut, -1, -1);   // Bounce at beat 32
    instance.ease("alpha", 32, 8, 0.5, FlxEase.cubeInOut, -1, -1); // Low transparency at beat 32

    // Transparency blinking between beats 72 and 80
    instance.repeater(72, 8, function() {
        var val = instance.getPercent("alpha", -1) == 1 ? 0.2 : 1;
        instance.setPercent("alpha", val, -1);
    }, -1);

    // Rainbow effect in the last beats
    for (i in 0...14) {
        var hue = Std.int(360 * (i / 14));
        var color = FlxColor.fromHSB(hue, 1, 1);
        instance.set("color", 120 + i, color, -1, -1);
    }

    // Message callbacks
    instance.callback(16, function() trace("Beat 16! Rotation and red color activated."), -1);
    instance.callback(120, function() trace("Beat 120! Rainbow effect."), -1);
}

/*
    -----------------------------------------------
    PER-FRAME DYNAMIC EFFECTS (optional)
    -----------------------------------------------
    Use onUpdatePost(elapsed:Float) for advanced effects that change every frame.
    Example: make the scaling (mini) oscillate over time.
*/

function onUpdatePost(elapsed:Float) {
    if (instance != null) {
        var osc = 0.5 + 0.5 * Math.sin(FlxG.game.ticks / 10);
        instance.setPercent("mini", osc, -1);
    }
}

/*
    -----------------------------------------------
    MANAGER FUNCTIONS AND UTILITIES (SUMMARY)
    -----------------------------------------------
    - instance.addModifier(mod, field): Adds a modifier to the playfield.
    - instance.setPercent(mod, value, field): Changes the value of a modifier.
    - instance.getPercent(mod, field): Gets the current value of a modifier.
    - instance.registerModifier(modN, mod): Registers a custom modifier.
    - instance.set(mod, beat, value, player, field): Changes the value of a modifier at a beat.
    - instance.ease(mod, beat, length, value, ease, player, field): Tweens the value of a modifier.
    - instance.callback(beat, func, field): Executes a function at a beat.
    - instance.repeater(beat, length, func, field): Executes a function several times from a beat.
    - instance.addEvent(event, field): Adds a custom event.
    - instance.addPlayfield(): Adds a new playfield (remember to add mods to that playfield).
    - You can use FlxColor or hexadecimal values for colors.

    -----------------------------------------------
    IMPORTANT NOTES FOR MODDERS
    -----------------------------------------------
    - Always use onCreatePost to initialize the Manager and mods.
    - Use onUpdatePost for dynamic per-frame effects.
    - Do not create more than one Manager instance per song.
    - Check the official documentation for more details and examples:
      https://github.com/TheoDevelops/FunkinModchart

    Have fun creating advanced modcharts!
*/



