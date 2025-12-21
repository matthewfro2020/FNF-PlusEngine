package backend;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import sys.io.File;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import lime.system.System;

#if cpp
@:cppFileCode('#include <thread>')
#end

class CoolUtil
{
	public static var hasUpdate:Bool = false;
	public static var latestVersion:String = "";

	public static var onUpdateChecked:UpdateCheckCallback->Void = null;

	typedef UpdateCheckCallback = {
		success:Bool,
		hasUpdate:Bool,
		currentVersion:String,
		latestVersion:String,
		errorMessage:String
	};
	
	public static function checkForUpdates(url:String = null, ?callback:UpdateCheckCallback->Void):Void {
		if (url == null || url.length == 0)
			url = "https://raw.githubusercontent.com/Psych-Plus-Team/FNF-PlusEngine/refs/heads/main/gitVersion.txt";
		
		var currentVersion:String = states.MainMenuState.plusEngineVersion.trim();
		hasUpdate = false;
		latestVersion = currentVersion;
		
		if (!ClientPrefs.data.checkForUpdates) {
			trace('Update checking is disabled in settings');
			if (callback != null) {
				callback({
					success: false,
					hasUpdate: false,
					currentVersion: currentVersion,
					latestVersion: currentVersion,
					errorMessage: "Update checking is disabled"
				});
			}
			return;
		}
		
		trace('Checking for updates...');
		
		var http = new haxe.Http(url);
		http.onData = function(data:String) {
			try {
				var remoteVersion:String = data.split('\n')[0].trim();
				trace('Version online: $remoteVersion, your version: $currentVersion');
				
				var updateFound = remoteVersion != currentVersion;
				hasUpdate = updateFound;
				latestVersion = remoteVersion;
				
				if (updateFound) {
					trace('Update available! Please update from $currentVersion to $remoteVersion');
					#if (desktop && !android)
					showPopUp('Update available!\nCurrent: $currentVersion\nLatest: $remoteVersion\n\nPlease download from GitHub.', 'Plus Engine Update');
					#end
				} else {
					trace('Versions match! No update needed');
				}
				
				if (callback != null) {
					callback({
						success: true,
						hasUpdate: updateFound,
						currentVersion: currentVersion,
						latestVersion: remoteVersion,
						errorMessage: ""
					});
				}

				if (onUpdateChecked != null) {
					onUpdateChecked({
						success: true,
						hasUpdate: updateFound,
						currentVersion: currentVersion,
						latestVersion: remoteVersion,
						errorMessage: ""
					});
				}
			} catch (e:Dynamic) {
				trace('Error parsing update data: $e');
				if (callback != null) {
					callback({
						success: false,
						hasUpdate: false,
						currentVersion: currentVersion,
						latestVersion: currentVersion,
						errorMessage: 'Parse error: $e'
					});
				}
			}
			
			http.onData = null;
			http.onError = null;
			http = null;
		}
		
		http.onError = function(error:String) {
			trace('Error checking for updates: $error');
			hasUpdate = false;
			
			if (callback != null) {
				callback({
					success: false,
					hasUpdate: false,
					currentVersion: currentVersion,
					latestVersion: currentVersion,
					errorMessage: 'Network error: $error'
				});
			}

			if (onUpdateChecked != null) {
				onUpdateChecked({
					success: false,
					hasUpdate: false,
					currentVersion: currentVersion,
					latestVersion: currentVersion,
					errorMessage: 'Network error: $error'
				});
			}
		}

		#if (sys && !nodejs)
		http.cnxTimeout = 10;
		#end
		
		http.request();
	}
	
	inline public static function quantize(f:Float, snap:Float):Float {
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}
	
	inline public static function capitalize(text:String):String {
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();
	}
	
	inline public static function coolTextFile(path:String):Array<String> {
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		if (FileSystem.exists(path))
			daList = File.getContent(path);
		#else
		if (Assets.exists(path))
			daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}
	
	inline public static function colorFromString(color:String):FlxColor {
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if (color.startsWith('0x'))
			color = color.substring(color.length - 6);
		
		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null)
			colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
	
	inline public static function listFromString(string:String):Array<String> {
		var daList:Array<String> = [];
		daList = string.trim().split('\n');
		
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		
		return daList;
	}
	
	public static function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1)
			return Math.floor(value);
		
		return Math.floor(value * Math.pow(10, decimals)) / Math.pow(10, decimals);
	}
	
	#if linux
	public static function sortAlphabetically(list:Array<String>):Array<String> {
		if (list == null)
			return [];
		
		list.sort((a, b) -> {
			var upperA = a.toUpperCase();
			var upperB = b.toUpperCase();
			
			return upperA < upperB ? -1 : upperA > upperB ? 1 : 0;
		});
		return list;
	}
	#end
	
	inline public static function dominantColor(sprite:FlxSprite, ?sampleSize:Int = 16):Int {
		if (sprite == null || sprite.pixels == null)
			return FlxColor.BLACK;

		if (sprite.frameWidth <= sampleSize * 2 || sprite.frameHeight <= sampleSize * 2) {
			return dominantColorFullScan(sprite);
		}
		
		var countByColor:Map<Int, Int> = [];
		var xStep:Int = Math.ceil(sprite.frameWidth / sampleSize);
		var yStep:Int = Math.ceil(sprite.frameHeight / sampleSize);
		
		for (col in 0...sprite.frameWidth step xStep) {
			for (row in 0...sprite.frameHeight step yStep) {
				var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel.alphaFloat > 0.05) {
					colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
					var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
					countByColor[colorOfThisPixel] = count + 1;
				}
			}
		}
		
		return findDominantColor(countByColor);
	}
	
	static function dominantColorFullScan(sprite:FlxSprite):Int {
		var countByColor:Map<Int, Int> = [];
		
		for (col in 0...sprite.frameWidth) {
			for (row in 0...sprite.frameHeight) {
				var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel.alphaFloat > 0.05) {
					colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
					var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
					countByColor[colorOfThisPixel] = count + 1;
				}
			}
		}
		
		return findDominantColor(countByColor);
	}
	
	static function findDominantColor(countByColor:Map<Int, Int>):Int {
		var maxCount = 0;
		var maxKey:Int = FlxColor.BLACK;
		countByColor[FlxColor.BLACK] = 0;
		
		for (key => count in countByColor) {
			if (count > maxCount) {
				maxCount = count;
				maxKey = key;
			}
		}
		
		return maxKey;
	}
	
	inline public static function numberArray(max:Int, ?min = 0):Array<Int> {
		var dumbArray:Array<Int> = [];
		for (i in min...max)
			dumbArray.push(i);
		
		return dumbArray;
	}
	
	inline public static function browserLoad(site:String) {
		try {
			System.openURL(site);
		} catch (e:Dynamic) {
			trace('Failed to open URL with System.openURL: $e');
			#if linux
			Sys.command('/usr/bin/xdg-open', [site]);
			#else
			FlxG.openURL(site);
			#end
		}
	}
	
	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
		if (!absolute)
			folder = Sys.getCwd() + folder;

		var systemName = Sys.systemName();
		if (systemName == "Windows") {
			folder = StringTools.replace(folder, "/", "\\");
			if (folder.endsWith("\\"))
				folder = folder.substr(0, folder.length - 1);
		} else {
			folder = StringTools.replace(folder, "\\", "/");
			if (folder.endsWith("/"))
				folder = folder.substr(0, folder.length - 1);
		}
		
		try {
			System.openFile(folder);
		} catch (e:Dynamic) {
			trace('Failed to open folder with System.openFile: $e');
			var command:String;
			var args:Array<String> = [folder];
			
			switch (systemName) {
				case "Linux":
					command = '/usr/bin/xdg-open';
				case "Mac":
					command = 'open';
				case "Windows":
					command = 'explorer.exe';
					args = [folder];
				default:
					trace('Unsupported platform for folder opening: $systemName');
					return;
			}
			
			try {
				Sys.command(command, args);
				trace('$command $folder');
			} catch (e2:Dynamic) {
				trace('Failed to open folder: $e2');
				FlxG.error('Failed to open folder: $folder');
			}
		}
		#else
		FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}
	
	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
	}
	
	public static function setTextBorderFromString(text:FlxText, border:String) {
		if (text == null)
			return;
		
		switch (border.toLowerCase().trim()) {
			case 'shadow':
				text.borderStyle = flixel.text.FlxTextBorderStyle.SHADOW;
			case 'outline':
				text.borderStyle = flixel.text.FlxTextBorderStyle.OUTLINE;
			case 'outline_fast' | 'outlinefast':
				text.borderStyle = flixel.text.FlxTextBorderStyle.OUTLINE_FAST;
			default:
				text.borderStyle = flixel.text.FlxTextBorderStyle.NONE;
		}
	}
	
	public static function showPopUp(message:String, title:String):Void {
		#if android
		// AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		FlxG.stage.window.alert(message, title);
		#else
		FlxG.stage.window.alert(message, title);
		#end

		trace('Popup - $title: $message');
	}
	
	#if cpp
	@:functionCode('
		return std::thread::hardware_concurrency();
	')
	#end
	public static function getCPUThreadsCount():Int {
		#if cpp
		return 1;
		#elseif (sys && !nodejs)
		try {
			#if linux
			var output = Sys.command("nproc", []);
			if (output != null)
				return Std.parseInt(output);
			#elseif mac
			var output = Sys.command("sysctl", ["-n", "hw.ncpu"]);
			if (output != null)
				return Std.parseInt(output);
			#end
		} catch (e:Dynamic) {
			trace('Could not determine CPU threads: $e');
		}
		return 1;
		#else
		return 1;
		#end
	}
}