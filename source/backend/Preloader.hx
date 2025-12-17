package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;

/**
 * Global preloader for the engine
 * Simple and fast asset preloader inspired by Kade Engine
 */
class Preloader extends FlxState
{
	var loadingImage:FlxSprite;
	var loadingBar:FlxBar;
	var loadedText:FlxText;
	
	var assetsToLoad:Array<String> = [];
	var currentAsset:Int = 0;
	var totalAssets:Int = 0;
	
	var loadedAssets:Int = 0;
	var failedAssets:Int = 0;
	
	override function create():Void
	{
		super.create();
		
		// Black background (full screen)
		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		add(bg);
		
		// Logo (same style as CopyState)
		loadingImage = new FlxSprite(0, 0, Paths.image('funkay'));
		loadingImage.setGraphicSize(0, FlxG.height);
		loadingImage.updateHitbox();
		loadingImage.screenCenter();
		add(loadingImage);
		
		// Loading bar (same style as CopyState)
		loadingBar = new FlxBar(0, FlxG.height - 50, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.8), 20, this, 'currentAsset', 0, 1);
		loadingBar.screenCenter(X);
		loadingBar.createFilledBar(0xFF000000, 0xFF00FF00);
		add(loadingBar);
		
		// Loading text
		loadedText = new FlxText(0, loadingBar.y - 30, FlxG.width, "Loading...", 16);
		loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(loadedText);
		
		// Collect and start loading
		collectAssets();
		loadingBar.setRange(0, totalAssets);
	}
	
	function collectAssets():Void
	{
		trace('Collecting assets to preload...');
		
		// Only preload critical menu assets, nothing more
		// Menu music
		assetsToLoad.push('music:freakyMenu');
		
		// Essential menu images
		assetsToLoad.push('image:menuDesat');
		assetsToLoad.push('image:alphabet');
		
		totalAssets = assetsToLoad.length;
		trace('Total assets to load: $totalAssets');
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Load assets directly in update loop (Kade Engine style)
		if (currentAsset < totalAssets)
		{
			var asset:String = assetsToLoad[currentAsset];
			var parts:Array<String> = asset.split(':');
			var type:String = parts[0];
			var path:String = parts[1];
			
			loadedText.text = 'Loading: $path ($currentAsset/$totalAssets)';
			
			try
			{
				switch (type)
				{
					case 'image':
						Paths.image(path);
						trace('Loaded image: $path');
						loadedAssets++;
					
					case 'music':
						Paths.music(path);
						trace('Loaded music: $path');
						loadedAssets++;
					
					case 'sound':
						Paths.sound(path);
						trace('Loaded sound: $path');
						loadedAssets++;
					
					default:
						trace('Unknown asset type: $type');
						failedAssets++;
				}
			}
			catch (e:Dynamic)
			{
				trace('Failed to load asset: $asset - Error: $e');
				failedAssets++;
			}
			
			currentAsset++;
		}
		else if (currentAsset >= totalAssets)
		{
			// Loading complete
			loadedText.text = "Loading complete!";
			trace('Preload complete! Loaded: $loadedAssets / Failed: $failedAssets');
			
			// Switch to TitleState
			FlxG.switchState(new states.TitleState());
		}
		
		// Allow skipping with ENTER
		if (FlxG.keys.justPressed.ENTER && currentAsset >= Math.floor(totalAssets * 0.5))
		{
			FlxG.switchState(new states.TitleState());
		}
	}
}
