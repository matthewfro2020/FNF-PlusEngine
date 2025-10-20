package objects;

import backend.Conductor;
import backend.ClientPrefs;
import backend.Controls;
import backend.InputFormatter;
import backend.CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.Shape;

using StringTools;

class KeyViewer extends FlxSpriteGroup
{
	public static var instance:KeyViewer;
	
	public var keys:Array<KeyButton> = [];
	public var keyTexts:Array<FlxText> = [];
	public var keyCount:Int = 4;
	
	public var kpsText:FlxText;
	public var totalText:FlxText;
	
	// Para KPS tracking
	public var hitArray:Array<Date> = [];
	public var kps:Int = 0;
	public var total:Int = 0;
	
	public function new(x:Float = 50, y:Float = 50)
	{
		super(x, y);
		instance = this;
		
		// Engine es solo 4K (4 teclas fijas)
		keyCount = 4;
		
		createKeyViewer();
		centerOnScreen(); // Llamar centerOnScreen como el original
		alpha = 0.6; // Transparencia como en NovaFlare
	}
	
	function createKeyViewer()
	{
		var keySize:Float = 45; // Más grande que antes (era 35)
		var spacing:Float = 6; // Más espacio entre teclas
		var totalWidth:Float = (keySize + spacing) * keyCount - spacing;
		
		// Crear botones de teclas
		for (i in 0...keyCount)
		{
			var keyButton = new KeyButton(i * (keySize + spacing), 0, keySize, i);
			keys.push(keyButton);
			add(keyButton);
			
			// Crear texto de tecla
			var keyName:String = getKeyName(i);
			var keyText = new FlxText(keyButton.x, keyButton.y, keySize, keyName, 14); // Texto más grande
			var textColor = FlxColor.BLACK; // Negro para fondo blanco
			keyText.setFormat(Paths.font("vcr.ttf"), 14, textColor, CENTER);
			keyText.y += (keySize - keyText.height) / 2; // Centrar verticalmente
			keyTexts.push(keyText);
			add(keyText);
		}
		
		// KPS Text
		kpsText = new FlxText(0, keySize + 10, totalWidth, "KPS: 0", 14); // Más grande
		kpsText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, CENTER);
		kpsText.alpha = 0.8;
		add(kpsText);
		
		// Total Text
		totalText = new FlxText(0, keySize + 28, totalWidth, "Total: " + total, 14); // Más grande
		totalText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, CENTER);
		totalText.alpha = 0.8;
		add(totalText);
	}
	
	function getKeyName(keyIndex:Int):String
	{
		// Solo 4 teclas: LEFT, DOWN, UP, RIGHT
		var keysArray = ['note_left', 'note_down', 'note_up', 'note_right'];
		
		if (keyIndex < keysArray.length) {
			var keyBind = Controls.instance.keyboardBinds.get(keysArray[keyIndex]);
			if (keyBind != null && keyBind.length > 0) {
				return InputFormatter.getKeyName(keyBind[0]);
			}
		}
		
		return "?";
	}
	
	public function keyPressed(keyIndex:Int)
	{
		if (keyIndex >= 0 && keyIndex < keys.length)
		{
			// Activar visual de la tecla
			keys[keyIndex].press();
			var textColor = FlxColor.BLACK; // Texto negro cuando se presiona
			keyTexts[keyIndex].color = textColor;
			
			// Registrar hit para KPS
			hitArray.unshift(Date.now());
			total++;
			updateTexts();
		}
	}
	
	public function keyReleased(keyIndex:Int)
	{
		if (keyIndex >= 0 && keyIndex < keys.length)
		{
			// Desactivar visual de la tecla
			keys[keyIndex].release();
			var textColor = FlxColor.BLACK; // Texto negro siempre (para fondo blanco)
			keyTexts[keyIndex].color = textColor;
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		// Actualizar KPS
		var i = hitArray.length - 1;
		while (i >= 0)
		{
			var time:Date = hitArray[i];
			if (time != null && time.getTime() + 1000 < Date.now().getTime())
				hitArray.remove(time);
			else
				i = -1; // salir del bucle
			i--;
		}
		
		var newKps = hitArray.length;
		if (kps != newKps) {
			kps = newKps;
			updateTexts();
		}
	}
	
	function updateTexts()
	{
		if (kpsText != null) {
			kpsText.text = "KPS: " + kps;
		}
		if (totalText != null) {
			totalText.text = "Total: " + total;
		}
	}
	
	function getTextColorForBackground(colorName:String):FlxColor
	{
		// Para colores claros usar texto oscuro, para colores oscuros usar texto claro
		switch(colorName.toLowerCase())
		{
			case 'white', 'cyan', 'pink', 'orange': 
				return FlxColor.BLACK;
			default: 
				return FlxColor.WHITE;
		}
	}
	
	// Métodos adicionales requeridos por otros archivos
	public function updateKeyColors()
	{
		// Actualizar colores de las teclas según su estado
		for (key in keys) {
			if (key.isPressed) {
				var keyColor = CoolUtil.colorFromString(ClientPrefs.data.keyViewerColor);
				key.color = keyColor;
			} else {
				key.color = FlxColor.WHITE; // Blanco cuando no está presionada
			}
		}
		
		// Actualizar colores del texto según el estado de las teclas
		for (i in 0...keyTexts.length) {
			keyTexts[i].color = FlxColor.BLACK; // Negro siempre para fondo blanco
		}
	}
	
	public function centerOnScreen()
	{
		// Centrar el KeyViewer en la pantalla (4 teclas fijas)
		var keySize:Float = 45; // Mismo tamaño que en createKeyViewer
		var spacing:Float = 6;
		var totalWidth = (keySize + spacing) * 4 - spacing; // 45px tecla + 6px spacing * 4 teclas
		
		// Usar la misma posición que el backup original + offset aplicado
		x = (FlxG.width - totalWidth) / 2 + ClientPrefs.data.keyViewerOffset[0];
		y = FlxG.height - 150 + ClientPrefs.data.keyViewerOffset[1]; // Misma posición que el original
	}
}

class KeyButton extends FlxSprite
{
	public var keyIndex:Int;
	public var isPressed:Bool = false;
	private var originalAlpha:Float = 0.6;
	
	public function new(x:Float, y:Float, size:Float, keyIndex:Int)
	{
		super(x, y);
		this.keyIndex = keyIndex;
		
		// Intentar cargar gráfico externo
		if (Paths.fileExists('images/ui/key.png', IMAGE)) {
			loadGraphic(Paths.image('ui/key'));
			setGraphicSize(Std.int(size), Std.int(size));
			updateHitbox();
		} else {
			// Fallback: crear rectángulo con bordes redondeados
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(2, FlxColor.WHITE, 0.8);
			shape.graphics.drawRoundRect(0, 0, size, size, size/6, size/6);
			shape.graphics.lineStyle();
			shape.graphics.beginFill(FlxColor.WHITE, 0.3);
			shape.graphics.drawRoundRect(0, 0, size, size, size/6, size/6);
			shape.graphics.endFill();
			
			var bitmapData:BitmapData = new BitmapData(Std.int(size), Std.int(size), true, 0x00FFFFFF);
			bitmapData.draw(shape);
			loadGraphic(bitmapData);
		}
		
		// Las teclas empiezan en blanco
		color = FlxColor.WHITE;
		alpha = originalAlpha;
	}
	
	public function press()
	{
		isPressed = true;
		// Cambiar al color personalizado cuando se presiona
		var keyColor = CoolUtil.colorFromString(ClientPrefs.data.keyViewerColor);
		color = keyColor;
		alpha = 1.0; // Brillo completo al presionar
		
		// Escalar la tecla para que se vea más grande
		scale.set(1.1, 1.1); // 10% más grande
	}
	
	public function release()
	{
		isPressed = false;
		// Volver a blanco cuando se suelta
		color = FlxColor.WHITE;
		alpha = originalAlpha; // Volver a la transparencia original
		
		// Volver al tamaño normal
		scale.set(1.0, 1.0);
	}
}