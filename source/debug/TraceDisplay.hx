package debug;

import flixel.FlxG;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.display.Graphics;
import openfl.display.Shape;
import haxe.Log;
import haxe.PosInfos;
import backend.Paths;

/**
 * TraceDisplay - Sistema para mostrar traces/logs dentro del juego
 * Se activa/desactiva con F4 y muestra los últimos traces en pantalla
 */
class TraceDisplay extends TextField
{
    /**
     * Lista de traces almacenados
     */
    public var traces:Array<String> = [];
    
    /**
     * Máximo número de traces a mostrar
     */
    public var maxTraces:Int = 20;
    
    /**
     * Si el display está visible o no
     */
    public var isVisible:Bool = false;
    
    /**
     * Fondo semi-transparente para mejor legibilidad
     */
    private var backgroundShape:Shape;
    
    /**
     * Referencia al trace original de Haxe
     */
    private var originalTrace:Dynamic;
    
    public function new(x:Float = 10, y:Float = 50, textColor:Int = 0xFFFFFF)
    {
        super();
        
        this.x = x;
        this.y = y;
        this.selectable = false;
        this.mouseEnabled = false;
        this.defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 14, textColor);
        this.autoSize = openfl.text.TextFieldAutoSize.LEFT;
        this.multiline = true;
        this.wordWrap = false;
        
        // Crear fondo
        backgroundShape = new Shape();
        
        // Interceptar traces
        setupTraceCapture();
        
        // Configurar listener para F4
        if (FlxG.stage != null) {
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
        
        // Inicialmente oculto
        this.visible = false;
        backgroundShape.visible = false;
    }
    
    /**
     * Configurar la captura de traces
     */
    private function setupTraceCapture():Void
    {
        // Guardar la función trace original
        originalTrace = Log.trace;
        
        // Reemplazar con nuestra función personalizada
        Log.trace = function(v:Dynamic, ?infos:PosInfos):Void {
            // Llamar al trace original para mantener funcionalidad
            originalTrace(v, infos);
            
            // Agregar a nuestro display
            addTrace(v, infos);
        };
    }
    
    /**
     * Agregar un trace a la lista
     */
    private function addTrace(value:Dynamic, ?infos:PosInfos):Void
    {
        var traceText:String;
        
        if (infos != null) {
            // Extraer solo el nombre del archivo sin path ni extensión
            var fileName = infos.fileName;
            if (fileName.indexOf("/") != -1) {
                fileName = fileName.substr(fileName.lastIndexOf("/") + 1);
            }
            if (fileName.indexOf("\\") != -1) {
                fileName = fileName.substr(fileName.lastIndexOf("\\") + 1);
            }
            if (fileName.indexOf(".") != -1) {
                fileName = fileName.substr(0, fileName.lastIndexOf("."));
            }
            
            // Formato: "NombreArchivo - línea: mensaje"
            traceText = '${fileName} - ${infos.lineNumber}: ${Std.string(value)}';
        } else {
            traceText = Std.string(value);
        }
        
        traces.push(traceText);
        
        // Limitar el número de traces
        if (traces.length > maxTraces) {
            traces.shift();
        }
        
        // Actualizar display si está visible
        if (isVisible) {
            updateDisplay();
        }
    }
    
    /**
     * Configurar el fondo después de ser agregado al parent
     */
    public function setupBackground():Void
    {
        if (parent != null && backgroundShape != null) {
            parent.addChildAt(backgroundShape, parent.getChildIndex(this));
        }
    }
    
    /**
     * Actualizar el contenido mostrado
     */
    private function updateDisplay():Void
    {
        if (!isVisible) return;
        
        var displayText:String = "=== TRACES (F4 para ocultar) ===\n";
        
        if (traces.length == 0) {
            displayText += "No hay traces recientes...";
        } else {
            for (i in 0...traces.length) {
                displayText += traces[i];
                if (i < traces.length - 1) displayText += "\n";
            }
        }
        
        this.text = displayText;
        updateBackground();
    }
    
    /**
     * Actualizar el fondo
     */
    private function updateBackground():Void
    {
        if (!isVisible || backgroundShape == null) return;
        
        backgroundShape.graphics.clear();
        backgroundShape.graphics.beginFill(0x000000, 0.7);
        backgroundShape.graphics.drawRect(x - 5, y - 5, textWidth + 10, textHeight + 10);
        backgroundShape.graphics.endFill();
    }
    
    /**
     * Toggle del display con F4
     */
    private function onKeyDown(event:KeyboardEvent):Void 
    {
        if (event.keyCode == Keyboard.F4) {
            toggleDisplay();
        }
    }
    
    /**
     * Mostrar/ocultar el display
     */
    public function toggleDisplay():Void
    {
        isVisible = !isVisible;
        this.visible = isVisible;
        backgroundShape.visible = isVisible;
        
        if (isVisible) {
            updateDisplay();
        }
    }
    
    /**
     * Mostrar el display
     */
    public function show():Void
    {
        isVisible = true;
        this.visible = true;
        backgroundShape.visible = true;
        updateDisplay();
    }
    
    /**
     * Ocultar el display
     */
    public function hide():Void
    {
        isVisible = false;
        this.visible = false;
        backgroundShape.visible = false;
    }
    
    /**
     * Limpiar todos los traces
     */
    public function clear():Void
    {
        traces = [];
        if (isVisible) {
            updateDisplay();
        }
    }
    
    /**
     * Posicionar el display
     */
    public function positionTrace(x:Float, y:Float):Void
    {
        this.x = x;
        this.y = y;
        updateBackground();
    }
    
    /**
     * Cleanup al destruir
     */
    public function destroy():Void
    {
        // Restaurar trace original
        if (originalTrace != null) {
            Log.trace = originalTrace;
        }
        
        // Remover listener
        if (FlxG.stage != null) {
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
        
        // Limpiar
        traces = null;
        if (backgroundShape != null && backgroundShape.parent != null) {
            backgroundShape.parent.removeChild(backgroundShape);
        }
        backgroundShape = null;
        
        if (this.parent != null) {
            this.parent.removeChild(this);
        }
    }
}