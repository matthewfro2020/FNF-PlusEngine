/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package states;

#if COPYSTATE_ALLOWED
import states.TitleState;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.ByteArray;
import haxe.io.Path;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import lime.system.ThreadPool;
import sys.thread.Mutex;
import sys.thread.Tls;

#if android
import lime.system.System;
#end

/**
 * ...
 * @author: Karim Akra
 */
class CopyState extends MusicBeatState
{
	private static final textFilesExtensions:Array<String> = ['ini', 'txt', 'xml', 'hxs', 'hx', 'lua', 'json', 'frag', 'vert'];
	public static final IGNORE_FOLDER_FILE_NAME:String = "CopyState-Ignore.txt";
	private static var directoriesToIgnore:Array<String> = [];
	public static var locatedFiles:Array<String> = [];
	public static var maxLoopTimes:Int = 0;

	private static var fileCopyMutex:Mutex = new Mutex();
	private var loopTimes:AtomicInt = 0;
	private var failedFiles:MutexArray<String> = new MutexArray<String>();
	private var failedFilesStack:MutexArray<String> = new MutexArray<String>();
	private var filesToRetry:MutexArray<String> = new MutexArray<String>();
	private var maxRetryAttempts:Int = 3;
	private var retryCounts:Map<String, Int> = new Map();

	private static var cachedAssetList:Array<String> = null;
	private static var cacheTimestamp:Float = 0;
	private static final CACHE_DURATION:Float = 300000;

	public var loadingImage:FlxSprite;
	public var loadingBar:FlxBar;
	public var loadedText:FlxText;
	public var statusText:FlxText;
	public var thread:ThreadPool;

	var shouldCopy:Bool = false;
	var canUpdate:Bool = true;
	var currentFileName:String = "";
	var isRetryPhase:Bool = false;

	override function create()
	{
		locatedFiles = [];
		maxLoopTimes = 0;
		failedFiles.clear();
		failedFilesStack.clear();
		filesToRetry.clear();
		retryCounts.clear();
		
		if (!validateAndCheckExistingFiles())
		{
			MusicBeatState.switchState(new TitleState());
			return;
		}

		var message = "Seems like you have some missing files that are necessary to run the game.\n\n" +
					 "Missing files: " + locatedFiles.length + "\n" +
					 "Press OK to begin the copy process.";
		CoolUtil.showPopUp(message, Language.getPhrase('mobile_notice', 'Notice!'));

		shouldCopy = true;

		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d));

		loadingImage = new FlxSprite(0, 0, Paths.image('funkay'));
		loadingImage.setGraphicSize(0, FlxG.height);
		loadingImage.updateHitbox();
		loadingImage.screenCenter();
		add(loadingImage);

		loadingBar = new FlxBar(0, FlxG.height - 52, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 26);
		loadingBar.setRange(0, maxLoopTimes);
		add(loadingBar);

		loadedText = new FlxText(loadingBar.x, loadingBar.y + 4, FlxG.width, '', 16);
		loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(loadedText);

		statusText = new FlxText(loadingBar.x, loadingBar.y + 30, FlxG.width, 'Preparing...', 14);
		statusText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, CENTER);
		add(statusText);

		thread = new ThreadPool(0, Std.int(Math.min(4, CoolUtil.getCPUThreadsCount())));
		thread.doWork.add(function(poop)
		{
			copyAssetsInThread();
		});
		
		new FlxTimer().start(0.5, (tmr) ->
		{
			thread.queue({});
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (shouldCopy)
		{
			var currentLoop = loopTimes.get();
			
			if (currentLoop >= maxLoopTimes && canUpdate)
			{
				handleCopyCompletion();
			}

			if (currentLoop >= maxLoopTimes)
			{
				loadedText.text = "Completed!";
				statusText.text = isRetryPhase ? "Retrying failed files..." : "All files processed";
			}
			else
			{
				loadedText.text = '$currentLoop/$maxLoopTimes';
				statusText.text = currentFileName != "" ? 'Copying: ${Path.withoutDirectory(currentFileName)}' : 'Processing...';
			}

			loadingBar.percent = Math.min((currentLoop / maxLoopTimes) * 100, 100);
		}
		super.update(elapsed);
	}

	private function copyAssetsInThread()
	{
		var filesToProcess = locatedFiles.copy();
		
		for (file in filesToProcess)
		{
			currentFileName = file;
			copyAssetWithRetry(file);
			loopTimes.increment();
		}

		if (!failedFiles.isEmpty() && !isRetryPhase)
		{
			isRetryPhase = true;
			var retryFiles = failedFiles.getCopy();
			failedFiles.clear();
			maxLoopTimes = retryFiles.length;
			loopTimes.set(0);
			
			for (file in retryFiles)
			{
				currentFileName = file;
				copyAssetWithRetry(file, true);
				loopTimes.increment();
			}
		}
		
		currentFileName = "";
	}

	private function copyAssetWithRetry(file:String, isRetry:Bool = false)
	{
		var attempts = 0;
		var maxAttempts = isRetry ? 1 : maxRetryAttempts;
		var success = false;
		
		while (attempts < maxAttempts && !success)
		{
			success = copyAsset(file);
			attempts++;
			
			if (!success && attempts < maxAttempts)
			{
				Sys.sleep(Math.pow(2, attempts) * 0.1);
			}
		}
		
		if (!success)
		{
			var errorMsg = 'Failed after ${attempts} attempt(s)';
			failedFiles.push('${getFile(file)} ($errorMsg)');
			failedFilesStack.push('${getFile(file)} - Failed after ${attempts} attempts');
			filesToRetry.push(file);
		}
	}

	public function copyAsset(file:String):Bool
	{
		if (!validateFilePath(file))
		{
			failedFilesStack.push('Invalid file path: $file');
			return false;
		}

		var targetPath = getTargetPath(file);
		
		if (FileSystem.exists(targetPath))
			return true;

		var directory = Path.directory(targetPath);
		if (!FileSystem.exists(directory))
		{
			try
			{
				FileSystem.createDirectory(directory);
			}
			catch (e:Dynamic)
			{
				failedFilesStack.push('Failed to create directory $directory: $e');
				return false;
			}
		}
		
		try
		{
			var internalPath = getFile(file);
			if (!OpenFLAssets.exists(internalPath))
			{
				failedFilesStack.push('Asset does not exist internally: $internalPath');
				return false;
			}

			if (textFilesExtensions.contains(Path.extension(file)))
			{
				return createContentFromInternal(file);
			}
			else
			{
				File.saveBytes(targetPath, getFileBytes(internalPath));
				return true;
			}
		}
		catch (e:haxe.Exception)
		{
			failedFilesStack.push('Error copying ${getFile(file)}: ${e.message}\nStack: ${e.stack}');
			return false;
		}
	}

	public function createContentFromInternal(file:String):Bool
	{
		var targetPath = getTargetPath(file);
		var directory = Path.directory(targetPath);
		
		try
		{
			var fileData:String = OpenFLAssets.getText(getFile(file));
			if (fileData == null)
				fileData = '';
				
			if (!FileSystem.exists(directory))
				FileSystem.createDirectory(directory);
				
			File.saveContent(targetPath, fileData);
			return true;
		}
		catch (e:haxe.Exception)
		{
			failedFilesStack.push('Error creating text file ${getFile(file)}: ${e.message}');
			return false;
		}
	}

	private function getTargetPath(file:String):String
	{
		#if android
		if (file.startsWith('mods/'))
		{
			return getAndroidModsPath() + file.substring(5);
		}
		#end
		return file;
	}

	#if android
	private function getAndroidModsPath():String
	{
		var possiblePaths = [
			Sys.getEnv("EXTERNAL_STORAGE") + "/Android/data/" + System.applicationID + "/mods/",
			Sys.getEnv("EXTERNAL_STORAGE") + "/mods/",
			"/sdcard/Android/data/" + System.applicationID + "/mods/",
			"/sdcard/mods/"
		];
		
		for (path in possiblePaths)
		{
			if (FileSystem.exists(path) || ensureDirectoryExists(path))
			{
				return path;
			}
		}

		var fallback = possiblePaths[0];
		ensureDirectoryExists(fallback);
		return fallback;
	}
	
	private function ensureDirectoryExists(path:String):Bool
	{
		try
		{
			if (!FileSystem.exists(path))
			{
				FileSystem.createDirectory(path);
			}
			return true;
		}
		catch (e:Dynamic)
		{
			trace('Failed to create directory: $path - $e');
			return false;
		}
	}
	#end

	public function getFileBytes(file:String):ByteArray
	{
		try
		{
			switch (Path.extension(file).toLowerCase())
			{
				case 'otf' | 'ttf':
					if (FileSystem.exists(file))
						return ByteArray.fromFile(file);
					else
						return OpenFLAssets.getBytes(file);
				default:
					return OpenFLAssets.getBytes(file);
			}
		}
		catch (e:Dynamic)
		{
			throw new haxe.Exception('Failed to get bytes for $file: $e');
		}
	}

	public static function getFile(file:String):String
	{
		if (OpenFLAssets.exists(file))
			return file;

		@:privateAccess
		for (library in LimeAssets.libraries.keys())
		{
			if (OpenFLAssets.exists('$library:$file') && library != 'default')
				return '$library:$file';
		}

		return file;
	}

	public static function validateAndCheckExistingFiles():Bool
	{
		locatedFiles = getCachedAssetList();

		var assets = locatedFiles.filter(folder -> folder.startsWith('assets/') || folder.startsWith('mods/'));
		locatedFiles = assets.filter(file -> !fileExistsExternally(file));

		var filesToRemove:Array<String> = [];

		for (file in locatedFiles)
		{
			if (filesToRemove.contains(file))
				continue;

			if(file.endsWith(IGNORE_FOLDER_FILE_NAME) && !directoriesToIgnore.contains(Path.directory(file)))
				directoriesToIgnore.push(Path.directory(file));

			if (directoriesToIgnore.length > 0)
			{
				for (directory in directoriesToIgnore)
				{
					if (file.startsWith(directory))
						filesToRemove.push(file);
				}
			}
		}

		locatedFiles = locatedFiles.filter(file -> !filesToRemove.contains(file));

		locatedFiles = locatedFiles.filter(validateFilePath);

		maxLoopTimes = locatedFiles.length;

		return (maxLoopTimes > 0);
	}
	
	private static function getCachedAssetList():Array<String>
	{
		var now = Date.now().getTime();
		
		if (cachedAssetList == null || (now - cacheTimestamp) > CACHE_DURATION)
		{
			cachedAssetList = OpenFLAssets.list();
			cacheTimestamp = now;
		}
		
		return cachedAssetList.copy();
	}
	
	private static function fileExistsExternally(file:String):Bool
	{
		#if android
		if (file.startsWith('mods/'))
		{
			var externalPath = getAndroidModsPathStatic() + file.substring(5);
			return FileSystem.exists(externalPath);
		}
		#end
		
		return FileSystem.exists(file);
	}
	
	#if android
	private static function getAndroidModsPathStatic():String
	{
		var possiblePaths = [
			Sys.getEnv("EXTERNAL_STORAGE") + "/Android/data/" + System.applicationID + "/mods/",
			Sys.getEnv("EXTERNAL_STORAGE") + "/mods/",
			"/sdcard/Android/data/" + System.applicationID + "/mods/",
			"/sdcard/mods/"
		];
		
		for (path in possiblePaths)
		{
			if (FileSystem.exists(path))
			{
				return path;
			}
		}
		
		return possiblePaths[0];
	}
	#end
	
	private static function validateFilePath(file:String):Bool
	{
		if (file == null || file.trim() == "")
			return false;

		var invalidChars = ~/[<>:"|?*\x00-\x1F]/;
		if (invalidChars.match(file))
			return false;

		if (file.indexOf("..") != -1 || file.indexOf("//") != -1)
			return false;

		if (file.length > 260)
			return false;
			
		return true;
	}

	private function handleCopyCompletion()
	{
		var failedCount = failedFiles.length;
		
		if (failedCount > 0)
		{
			var errorMessage = 'Failed to copy ${failedCount} file(s).\n\n';
			errorMessage += 'Common issues:\n';
			errorMessage += '1. Check storage permissions\n';
			errorMessage += '2. Ensure sufficient storage space\n';
			errorMessage += '3. Restart the app and try again\n\n';
			errorMessage += 'Failed files logged to: /logs/';
			
			CoolUtil.showPopUp(errorMessage, 'Copy Incomplete');
			
			final folder:String = #if android getAndroidModsPath() + '../logs/' #else Sys.getCwd() + 'logs/' #end;
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);
				
			var timestamp = Date.now().toString().replace(' ', '-').replace(':', "'");
			var logContent = 'CopyState Log - $timestamp\n';
			logContent += '=====================\n';
			logContent += 'Total files: $maxLoopTimes\n';
			logContent += 'Failed: $failedCount\n';
			logContent += 'Successful: ${maxLoopTimes - failedCount}\n\n';
			logContent += 'Failed files:\n';
			logContent += failedFiles.getCopy().join('\n');
			logContent += '\n\nStack traces:\n';
			logContent += failedFilesStack.getCopy().join('\n');
			
			File.saveContent(folder + timestamp + '-CopyState.log', logContent);
		}
		
		FlxG.sound.play(Paths.sound('confirmMenu')).onComplete = () ->
		{
			MusicBeatState.switchState(new TitleState());
		};

		canUpdate = false;
	}
}

class AtomicInt
{
	private var value:Int = 0;
	private var mutex:Mutex = new Mutex();
	
	public function new(initialValue:Int = 0)
	{
		value = initialValue;
	}
	
	public function get():Int
	{
		mutex.acquire();
		var v = value;
		mutex.release();
		return v;
	}
	
	public function set(v:Int):Void
	{
		mutex.acquire();
		value = v;
		mutex.release();
	}
	
	public function increment():Int
	{
		mutex.acquire();
		value++;
		var v = value;
		mutex.release();
		return v;
	}
}

class MutexArray<T>
{
	private var array:Array<T> = [];
	private var mutex:Mutex = new Mutex();
	
	public function new() {}
	
	public function push(item:T):Void
	{
		mutex.acquire();
		array.push(item);
		mutex.release();
	}
	
	public function getCopy():Array<T>
	{
		mutex.acquire();
		var copy = array.copy();
		mutex.release();
		return copy;
	}
	
	public function clear():Void
	{
		mutex.acquire();
		array = [];
		mutex.release();
	}
	
	public function isEmpty():Bool
	{
		mutex.acquire();
		var empty = array.length == 0;
		mutex.release();
		return empty;
	}
	
	public var length(get, never):Int;
	
	private function get_length():Int
	{
		mutex.acquire();
		var len = array.length;
		mutex.release();
		return len;
	}
}
#end