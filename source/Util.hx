package;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.events.Event;
import mods.ModSoundUtil;
import openfl.media.Sound;
import flixel.system.FlxSound;
import mods.Mods;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import haxe.Json;
import lime.app.Application;

using StringTools;

class Util
{
	static public var soundExt:String = #if web '.mp3' #else '.ogg' #end;
	static public var funnyStringArray:Array<String> = [];
	static public var engineName:String = "Infinity Engine";
	static public var engineVersion:String = "0.1a";

	static public function getJsonContents(path:String):Dynamic {
		#if sys
		if(!Assets.exists(path))
		{
			if(sys.FileSystem.exists(Sys.getCwd() + path))
				return Json.parse(sys.io.File.getContent(Sys.getCwd() + path));

			return "File couldn't be found!";
		}
		else
		{
		#end
		if(Assets.exists(path))
			return Json.parse(Assets.getText(path));
		else 
			return null;
		#if sys
		}
		#end
	}
	
	static public function getText(filePath:String)
	{
		#if sys
		for(mod in Mods.activeMods)
		{
			if(sys.FileSystem.exists(Sys.getCwd() + "mods/" + mod + "/" + filePath))
				return sys.io.File.getContent(Sys.getCwd() + "mods/" + mod + "/" + filePath);
		}
		#end
		
		if(Assets.exists("assets/" + filePath))
			return Assets.getText("assets/" + filePath);
		
		return "";
	}

	static public function getPacker(filePath:String, ?fromImagesFolder:Bool = true, ?txtPath:String)
	{
		var png = filePath;
		var txt = txtPath;

		if (txt == null)
			txt = png;

		if (fromImagesFolder)
		{
			png = "assets/images/" + png;
			txt = "assets/images/" + txt;
		}
		else
		{
			png = "assets/" + png;
			txt = "assets/" + txt;
		}

		#if sys
		if(!Assets.exists(png + ".png") || !Assets.exists(txt + ".txt"))
		{
			for(mod in Mods.activeMods)
			{
				var newPng = filePath;
		
				if (fromImagesFolder)
					newPng = "mods/" + mod + "/images/" + newPng;
				else
					newPng = "mods/" + mod + "/" + newPng;

				var newTxt = txtPath;

				if (newTxt == null)
					newTxt = newPng;
				else
				{
					if (fromImagesFolder)
						newTxt = "mods/" + mod + "/images/" + newTxt;
					else
						newTxt = "mods/" + mod + "/" + newTxt;
				}

				if(sys.FileSystem.exists(Sys.getCwd() + newPng + ".png") && sys.FileSystem.exists(Sys.getCwd() + newTxt + ".txt"))
				{
					var txtData = sys.io.File.getContent(Sys.getCwd() + newTxt + ".txt");

					if(Cache.getFromCache(newPng, "image") == null)
					{
						var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + newPng + ".png"), false, newPng, false);
						graphic.destroyOnNoUse = false;

						Cache.addToCache(newPng, graphic, "image");
					}
	
					return FlxAtlasFrames.fromSpriteSheetPacker(Cache.getFromCache(newPng, "image"), txtData);
				}
			}

			return FlxAtlasFrames.fromSparrow("assets/images/StoryMode_UI_Assets" + ".png", "assets/images/StoryMode_UI_Assets" + ".xml");
		}
		else
		{
			var txtData = Assets.getText(txt + ".txt");

			if(Cache.getFromCache(png, "image") == null)
			{
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return FlxAtlasFrames.fromSpriteSheetPacker(Cache.getFromCache(png, "image"), txtData);
		}
		#end

		return FlxAtlasFrames.fromSpriteSheetPacker(png + ".png", txt + ".txt");
	}

	static public function getPath(?path:Null<String>):Null<String>
	{
		var gaming = null;

		if(Assets.exists('assets/$path'))
			gaming = 'assets/$path';
		else
		{
			for(mod in Mods.activeMods)
			{
				if(sys.FileSystem.exists('mods/$mod/$path'))
				{
					gaming = 'mods/$mod/$path';
					break;
				}
			}
		}

		return gaming;
	}

	static public function getSparrow(filePath:String, ?fromImagesFolder:Bool = true, ?xmlPath:String)
	{
		var png = filePath;
		var xml = xmlPath;

		if (xml == null)
			xml = png;

		if (fromImagesFolder)
		{
			png = "assets/images/" + png;
			xml = "assets/images/" + xml;
		}
		else
		{
			png = "assets/" + png;
			xml = "assets/" + xml;
		}

		#if sys
		for(mod in Mods.activeMods)
		{
			var newPng = filePath;
	
			if (fromImagesFolder)
				newPng = "mods/" + mod + "/images/" + newPng;
			else
				newPng = "mods/" + mod + "/" + newPng;

			var newXml = xmlPath;

			if (newXml == null)
				newXml = newPng;
			else
			{
				if (fromImagesFolder)
					newXml = "mods/" + mod + "/images/" + newXml;
				else
					newXml = "mods/" + mod + "/" + newXml;
			}

			if(sys.FileSystem.exists(Sys.getCwd() + newPng + ".png") && sys.FileSystem.exists(Sys.getCwd() + newXml + ".xml"))
			{
				var xmlData = sys.io.File.getContent(Sys.getCwd() + newXml + ".xml");

				if(Cache.getFromCache(newPng, "image") == null)
				{
					var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + newPng + ".png"), false, newPng, false);
					graphic.destroyOnNoUse = false;

					Cache.addToCache(newPng, graphic, "image");
				}

				return FlxAtlasFrames.fromSparrow(Cache.getFromCache(newPng, "image"), xmlData);
			}
		}

		if(Assets.exists(png + ".png") && Assets.exists(xml + ".xml"))
		{
			var xmlData = Assets.getText(xml + ".xml");

			if(Cache.getFromCache(png, "image") == null)
			{
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return FlxAtlasFrames.fromSparrow(Cache.getFromCache(png, "image"), xmlData);
		}
		#end

		return FlxAtlasFrames.fromSparrow("assets/images/StoryMode_UI_Assets" + ".png", "assets/images/StoryMode_UI_Assets" + ".xml");
	}

	static public function getImage(filePath:String, ?fromImagesFolder:Bool = true, ?specificMod:Null<String>):Dynamic
	{
		var png = filePath;
		
		if (fromImagesFolder)
			png = "assets/images/" + png;
		else
			png = "assets/" + png;

		#if sys
		for(mod in Mods.activeMods)
		{
			var amongUs = mod;

			var modPng = filePath;

			if(specificMod != null) amongUs = specificMod;
	
			if (fromImagesFolder)
				modPng = "mods/" + amongUs + "/images/" + modPng;
			else
				modPng = "mods/" + amongUs + "/" + modPng;

			if(sys.FileSystem.exists(Sys.getCwd() + modPng + ".png"))
			{
				if(Cache.getFromCache(modPng, "image") == null)
				{
					var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + modPng + ".png"), false, modPng, false);
					graphic.destroyOnNoUse = false;

					Cache.addToCache(modPng, graphic, "image");
				}
				
				return Cache.getFromCache(modPng, "image");
			}
		}

		if(Assets.exists(png + ".png", IMAGE))
		{
			if(Cache.getFromCache(png, "image") == null)
			{
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}
			
			return Cache.getFromCache(png, "image");
		}
		#end

		return png + '.png';
	}

	static public function getSound(filePath:String, ?fromSoundsFolder:Bool = true, ?useUrOwnFolderLmfao:Bool = false):Dynamic
	{
		var base:String = "";

		if(!useUrOwnFolderLmfao)
		{
			if(fromSoundsFolder)
				base = "sounds/";
			else
				base = "music/";
		}

		var gamingPath = base + filePath + soundExt;

		if(Assets.exists("assets/" + gamingPath))
		{
			if(Cache.getFromCache(gamingPath, "sound") == null)
			{
				var sound:Sound = null;

				#if sys
				sound = Sound.fromFile("assets/" + gamingPath);
				Cache.addToCache(gamingPath, sound, "sound");
				#else
				return "assets/" + gamingPath;
				#end
			}

			return Cache.getFromCache(gamingPath, "sound");
		}
		else
		{
			if(Cache.getFromCache(gamingPath, "sound") == null)
			{
				var sound:Sound = null;

				#if sys
				var modFoundFirst:String = "";
		
				for(mod in Mods.activeMods)
				{
					if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/' + gamingPath))
						modFoundFirst = mod;
				}
		
				if(modFoundFirst != "")
				{
					sound = Sound.fromFile('mods/$modFoundFirst/' + gamingPath);
					Cache.addToCache(gamingPath, sound, "sound");
				}
				else
				#end
					return "assets/" + gamingPath;
			}

			return Cache.getFromCache(gamingPath, "sound");
		}
	}

	// haha leather goes coding---

	static public function getInst(songName:String) {
		return getSound("songs/" + songName.toLowerCase() + "/Inst", false, true);
	}

	static public function getVoices(songName:String) {
		return getSound("songs/" + songName.toLowerCase() + "/Voices", false, true);
	}

	static public function getCharacterIcons(charName:String, ?haveAssetsLol:Bool = false)
	{
		return (haveAssetsLol ? "assets/" : "") + 'characters/images/$charName/icons';
	}

	static public function getJsonPath(path:String)
	{
		return "assets/" + path + ".json";
	}

	public static function openURL(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;

		if(newValue < min)
			newValue = min;
		else if(newValue > max)
			newValue = max;
		
		return newValue;
	}

	public static function mouseOverlappingSprite(spr:FlxSprite) {
		if (FlxG.mouse.x > spr.x && FlxG.mouse.x < spr.x+spr.width && FlxG.mouse.y > spr.y && FlxG.mouse.y < spr.y+spr.height)
			return true;
		else
			return false;
	}

	
	public static function clearMemoryStuff()
	{
		for (key in Cache.imageCache.keys())
		{
			if (key != null)
			{
				Assets.cache.clear(key);
				Cache.imageCache.remove(key);
			}
		}

		Cache.imageCache = [];
		
		for (key in Cache.soundCache.keys())
		{
			if (key != null)
			{
				openfl.Assets.cache.clear(key);
				Cache.soundCache.remove(key);
			}
		}

		Cache.soundCache = [];
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}
}

class Log
{
    public static var logFileName:String = "test log, if u see this ur game broke";

    #if sys
    public static var file:sys.io.FileOutput;
    #end

    public static function init(?fileName:Null<String>)
    {
        if(fileName != null)
            logFileName = fileName;

        logFileName = logFileName.replace(":", "-"); // basically we cant use colons in file names (at least on linux) so brrrrrrr

        #if sys
        sys.FileSystem.createDirectory("logs");

        file = sys.io.File.write("logs/" + logFileName + ".log", false);
        #end

        log("Infinity Engine Log file started at " + Date.now().toString() + " running version " + Application.current.meta.get('version'), false);

        #if debug
		log("This is a DEBUG build.");
		#else
		log("This is a RELEASE build.");
		#end

		log('HaxeFlixel version: ${Std.string(FlxG.VERSION)}');
    }

    public static function log(data:Dynamic, ?debugPrint:Bool = true, ?timePrefix:Bool = true)
    {
        if(debugPrint)
            trace(data);

        #if sys
        if(file != null)
        {
            file.writeString((timePrefix ? "[" + Date.now().toString() + "]: " : "") + Std.string(data) + "\n");
            file.flush();
            file.flush();
        }
        #end
    }
}