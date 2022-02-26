package ui;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class StoryWeekSprite extends FlxSprite
{
	public var flashingInt:Int = 0;

	override public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		fakeFramerate = Math.round((1 / FlxG.elapsed) / 10);

		if(fakeFramerate <= 1)
			fakeFramerate = 1;

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2) && isFlashing)
			color = 0xFF33ffff;
		else
			color = FlxColor.WHITE;
	}
}