package ui;

import flixel.graphics.FlxGraphic;
import ui.TrackerSprite.TrackerDirection;
import flixel.FlxSprite;

using StringTools;

class Icon extends TrackerSprite
{
	var isPixel:Bool = false;
	public var isPlayer:Bool = false;

	public function new(?iconPath:String = "test", ?tracker:FlxSprite, ?isPlayer:Bool = false, ?xOff:Float = 10, ?yOff:Float = -30, ?direction:TrackerDirection = RIGHT, ?swagChar:String = "bf")
	{
		super(tracker, xOff, yOff, direction);

		if(!Std.isOfType(Util.getImage(iconPath, false), FlxGraphic))
		{
			trace("Oops! Looks like the icon you tried to load: " + iconPath + " doesn't exist.");
			iconPath = "characters/images/placeholder/icons";
		}

		switch(swagChar)
		{
			case "senpai" | "senpai-angry" | "spirit": // hardcoded char override bc i can't be bothered rn
				isPixel = true;
		}

		if(iconPath.contains('-pixel') || isPixel)
			antialiasing = false;
		else
			antialiasing = Options.getData('anti-aliasing');

		loadIcon(iconPath, isPlayer);
	}

	public function loadIcon(iconPath:String, isPlayer:Bool)
	{
		this.isPlayer = isPlayer;
		
		if(!Std.isOfType(Util.getImage(iconPath, false), FlxGraphic))
			iconPath = "characters/images/placeholder/icons";

		loadGraphic(Util.getImage(iconPath, false), true, 150, 150);

		animation.add("default", [0], 0, false, isPlayer);
		animation.add("dead", [1], 0, false, isPlayer);
		animation.add("winning", [2], 0, false, isPlayer);

		animation.play("default");
	}
}