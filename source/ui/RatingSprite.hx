package ui;

import mods.Mods;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class RatingSprite extends FlxSprite
{
	public var origPos:Array<Float> = [0, 0];

	public function new(x, y)
	{
		super(x, y);

		loadRating('sick');

		origPos = [x, y];
	}

	public function loadRating(daRating:String = 'sick', skin:String = 'default', ?isPixel:Null<Bool>)
	{
		loadGraphic(Util.getImage('ratings/$skin/' + daRating));

		if(isPixel == null)
		{
			if(Assets.exists('assets/images/noteskins/$skin/config.json'))
				isPixel = Util.getJsonContents('assets/images/noteskins/$skin/config.json').isPixel;
			#if sys
			else
			{
				#if sys
				for(mod in Mods.activeMods)
				{
					if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/images/noteskins/$skin/config.json'))
					{
						isPixel = Util.getJsonContents('mods/$mod/images/noteskins/$skin/config.json').isPixel;
					}
				}
				#end
			}
			#end
		}

		if(isPixel)
			antialiasing = false;
		else
			antialiasing = Options.getData('anti-aliasing');

		if(isPixel)
			setGraphicSize(Std.int(this.width * game.PlayState.pixelAssetZoom * 0.7));
		else
			setGraphicSize(Std.int(this.width * 0.7));

		updateHitbox();
	}

	public function tweenRating()
	{
		FlxTween.cancelTweensOf(this);
		x = origPos[0];
		y = origPos[1];
		alpha = 1;
		/*FlxTween.tween(this, {y: this.y - 25}, 0.4, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(this, {alpha: 0}, 0.4, {
					ease: FlxEase.cubeInOut,
				});
			}
		});*/
	}
}
