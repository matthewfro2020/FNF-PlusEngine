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

package mobile.backend;

import haxe.io.Path;

/**
 * A storage class for mobile.
 * @author Karim Akra and Homura Akemi (HomuHomu833)
 */
class StorageUtil
{
	#if sys
	public static function getStorageDirectory():String
	{
		return #if android 
			Path.addTrailingSlash(AndroidContext.getExternalFilesDir()) 
		#elseif ios 
			lime.system.System.documentsDirectory 
		#else 
			Sys.getCwd() 
		#end;
	}

	public static function getSMDirectory():String
	{
		final baseDir = #if android 
			getExternalStorageDirectory() 
		#else 
			'./' 
		#end;
		return Path.join([baseDir, 'sm']);
	}

	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
	{
		final baseDir = #if android 
			getExternalStorageDirectory() 
		#else 
			Sys.getCwd() 
		#end;
		
		final folder = Path.join([baseDir, 'saves']);
		final filePath = Path.join([folder, fileName]);
		
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent(filePath, fileData);
			if (alert)
				CoolUtil.showPopUp(Language.getPhrase('file_save_success', '{1} has been saved.', [fileName]), Language.getPhrase('mobile_success', "Success!"));
		}
		catch (e:Dynamic)
		{
			final errorMsg = Std.string(e);
			if (alert)
				CoolUtil.showPopUp(Language.getPhrase('file_save_fail', '{1} couldn\'t be saved.\n({2})', [fileName, errorMsg]), Language.getPhrase('mobile_error', "Error!"));
			else
				trace('$fileName couldn\'t be saved. ($errorMsg)');
		}
	}

	#if android
	public static function getExternalStorageDirectory():String
	{
		var basePath = AndroidEnvironment.getExternalStorageDirectory();
		if (basePath == null || basePath == '') {
			basePath = '/sdcard';
		}
		return Path.join([basePath, '.PlusEngine']);
	}

	private static function ensureDirectory(path:String):Bool
	{
		try
		{
			if (!FileSystem.exists(path)) {
				FileSystem.createDirectory(path);
				trace('Created directory: $path');
			}
			return true;
		}
		catch (e:Dynamic)
		{
			trace('Failed to create directory $path: ${Std.string(e)}');
			return false;
		}
	}

	private static function hasRequiredPermissions():Bool
	{
		final granted = AndroidPermissions.getGrantedPermissions();
		
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU) {
			return granted.contains('android.permission.READ_MEDIA_IMAGES') ||
				   granted.contains('android.permission.READ_MEDIA_VIDEO');
		} else {
			return granted.contains('android.permission.READ_EXTERNAL_STORAGE') ||
				   granted.contains('android.permission.WRITE_EXTERNAL_STORAGE');
		}
	}

	public static function requestPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU) {
			AndroidPermissions.requestPermissions([
				'READ_MEDIA_IMAGES', 
				'READ_MEDIA_VIDEO', 
				'READ_MEDIA_AUDIO'
			]);
		} else {
			AndroidPermissions.requestPermissions([
				'READ_EXTERNAL_STORAGE', 
				'WRITE_EXTERNAL_STORAGE'
			]);
		}

		if (AndroidVersion.SDK_INT >= AndroidVersionCode.R && 
			!AndroidEnvironment.isExternalStorageManager()) {
			AndroidSettings.requestSetting('MANAGE_EXTERNAL_STORAGE');
		}

		if (!hasRequiredPermissions()) {
			CoolUtil.showPopUp(
				Language.getPhrase('permissions_message', 
					'Storage permissions are required for saving game data and mods.\n' +
					'Please grant the requested permissions when prompted.'),
				Language.getPhrase('mobile_notice', "Notice!")
			);
		}

		initializeStorageDirectories();
	}

	private static function initializeStorageDirectories():Void
	{
		final directories = [
			getStorageDirectory(),
			Path.join([getExternalStorageDirectory(), 'mods']),
			getSMDirectory(),
			Path.join([getExternalStorageDirectory(), 'saves'])
		];

		var allDirectoriesCreated = true;
		var failedDirectories = [];
		
		for (dir in directories) {
			if (!ensureDirectory(dir)) {
				allDirectoriesCreated = false;
				failedDirectories.push(dir);
			}
		}

		if (!allDirectoriesCreated) {
			final errorMsg = Language.getPhrase('create_directory_error', 
				'Failed to create the following directories:\n{1}\n' +
				'Please check storage permissions or available space.\n' +
				'The app may not function correctly without these directories.',
				[failedDirectories.join('\n')]);
			
			CoolUtil.showPopUp(errorMsg, Language.getPhrase('mobile_warning', "Warning!"));
		}
	}
	#end
	#end
}
