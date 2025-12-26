package psychlua;

import modchart.Manager;
import modchart.backend.standalone.Adapter;
import psychlua.FunkinLua;
import flixel.tweens.FlxEase;

class LuaModchart
{
    public static function implement(funk:FunkinLua) {
        var lua:State = funk.lua;
        
        // Agregar modificador
        Lua_helper.add_callback(lua, "addModifier", function(name:String, ?field:Int = -1) {
            if (Manager.instance != null)
                Manager.instance.addModifier(name, field);
        });
        
        // Establecer porcentaje de modificador
        Lua_helper.add_callback(lua, "setPercent", function(name:String, value:Float, ?player:Int = -1, ?field:Int = -1) {
            if (Manager.instance != null)
                Manager.instance.setPercent(name, value, player, field);
        });
        
        // Obtener porcentaje de modificador
        Lua_helper.add_callback(lua, "getPercent", function(name:String, ?player:Int = 0, ?field:Int = 0):Float {
            if (Manager.instance != null)
                return Manager.instance.getPercent(name, player, field);
            return 0.0;
        });
        
        // Establecer valor absoluto de modificador
        Lua_helper.add_callback(lua, "setRawValue", function(name:String, value:Float, ?player:Int = -1, ?field:Int = -1) {
            if (Manager.instance != null)
                Manager.instance.setRawValue(name, value, player, field);
        });
        
        // Obtener valor absoluto de modificador
        Lua_helper.add_callback(lua, "getRawValue", function(name:String, ?player:Int = 0, ?field:Int = 0):Float {
            if (Manager.instance != null)
                return Manager.instance.getRawValue(name, player, field);
            return 0.0;
        });
        
        // Establecer valor en un beat específico
        Lua_helper.add_callback(lua, "set", function(name:String, beat:Float, value:Float, ?player:Int = -1, ?field:Int = -1) {
            if (Manager.instance != null)
                Manager.instance.set(name, beat, value, player, field);
        });
        
        // Aplicar easing a un modificador
        Lua_helper.add_callback(lua, "ease", function(name:String, beat:Float, length:Float, value:Float, easeName:String, ?player:Int = -1, ?field:Int = -1) {
            if (Manager.instance != null) {
                var easeFunc = getEaseFunction(easeName);
                Manager.instance.ease(name, beat, length, value, easeFunc, player, field);
            }
        });
        
        // Agregar valor con easing
        Lua_helper.add_callback(lua, "add", function(name:String, beat:Float, length:Float, value:Float, easeName:String, ?player:Int = -1, ?field:Int = -1) {
            if (Manager.instance != null) {
                var easeFunc = getEaseFunction(easeName);
                Manager.instance.add(name, beat, length, value, easeFunc, player, field);
            }
        });
        
        // Establecer y agregar valor
        Lua_helper.add_callback(lua, "setAdd", function(name:String, beat:Float, value:Float, ?player:Int = -1, ?field:Int = -1) {
            if (Manager.instance != null)
                Manager.instance.setAdd(name, beat, value, player, field);
        });
        
        // Agregar nuevo playfield
        Lua_helper.add_callback(lua, "addPlayfield", function() {
            if (Manager.instance != null)
                Manager.instance.addPlayfield();
        });
        
        // Crear alias para modificador
        Lua_helper.add_callback(lua, "alias", function(name:String, aliasName:String, field:Int) {
            if (Manager.instance != null)
                Manager.instance.alias(name, aliasName, field);
        });
        
        // Constantes útiles
        Lua_helper.add_callback(lua, "getHoldSize", function():Float {
            return Manager.HOLD_SIZE;
        });
        
        Lua_helper.add_callback(lua, "getHoldSizeDiv2", function():Float {
            return Manager.HOLD_SIZEDIV2;
        });
        
        Lua_helper.add_callback(lua, "getArrowSize", function():Float {
            return Manager.ARROW_SIZE;
        });
        
        Lua_helper.add_callback(lua, "getArrowSizeDiv2", function():Float {
            return Manager.ARROW_SIZEDIV2;
        });
        
        // Evento callback: ejecutar una función en un beat específico
        Lua_helper.add_callback(lua, "callback", function(beat:Float, funcName:String, ?field:Int = -1) {
            if (Manager.instance != null) {
                Manager.instance.callback(beat, function(event) {
                    funk.call(funcName, []); // No pasar el objeto event a Lua
                }, field);
            }
        });
        
        // Programar callback en un beat específico (una vez, sinónimo de callback)
        Lua_helper.add_callback(lua, "scheduleCallback", function(beat:Float, funcName:String, ?field:Int = -1) {
            if (Manager.instance != null) {
                Manager.instance.scheduleCallback(beat, function(event) {
                    funk.call(funcName, []); // No pasar el objeto event a Lua
                }, field);
            }
        });
        
        // Evento repeater: ejecutar una función repetidamente durante un período
        Lua_helper.add_callback(lua, "repeater", function(beat:Float, length:Float, funcName:String, ?field:Int = -1) {
            if (Manager.instance != null) {
                Manager.instance.repeater(beat, length, function(event) {
                    funk.call(funcName, []); // No pasar el objeto event a Lua
                }, field);
            }
        });
        
        // Agregar modifier scriptado (custom)
        Lua_helper.add_callback(lua, "addScriptedModifier", function(name:String, modifierInstance:Dynamic, ?field:Int = -1) {
            if (Manager.instance != null && modifierInstance != null) {
                // El modifierInstance debe ser una instancia de Modifier creada desde Lua/HScript
                Manager.instance.addScriptedModifier(name, modifierInstance, field);
            }
        });
        
        // Crear nodo (node): vincular inputs y outputs con una función
        Lua_helper.add_callback(lua, "node", function(inputs:Array<String>, outputs:Array<String>, funcName:String, ?field:Int = -1) {
            if (Manager.instance != null) {
                Manager.instance.node(inputs, outputs, function(curInput:Array<Float>, curOutput:Int):Array<Float> {
                    // Llamar función Lua con los valores de entrada
                    var result:Dynamic = funk.call(funcName, [curInput]);
                    // Retornar resultado como array de floats, o array con curOutput si no hay resultado
                    if (result != null && Std.isOfType(result, Array)) {
                        return cast result;
                    }
                    return [curOutput]; // Default to array with curOutput
                }, field);
            }
        });
        
        // Obtener beat actual desde Conductor
        Lua_helper.add_callback(lua, "getCurrentBeat", function():Float {
            return Conductor.songPosition / Conductor.crochet;
        });
        
        // Obtener step actual desde Conductor
        Lua_helper.add_callback(lua, "getCurrentStep", function():Float {
            return Conductor.songPosition / Conductor.stepCrochet;
        });
        
        // Obtener tiempo de la canción en milisegundos
        Lua_helper.add_callback(lua, "getSongPosition", function():Float {
            return Conductor.songPosition;
        });
        
        // Obtener BPM actual
        Lua_helper.add_callback(lua, "getBPM", function():Float {
            return Conductor.bpm;
        });
        
        // Obtener cantidad de jugadores/playfields
        Lua_helper.add_callback(lua, "getPlayerCount", function():Int {
            return Adapter.instance.getPlayerCount();
        });
    }
    
    // Función auxiliar para convertir nombres de easing a funciones
    private static function getEaseFunction(easeName:String) {
        return LuaUtils.getTweenEaseByString(easeName);
    }
}