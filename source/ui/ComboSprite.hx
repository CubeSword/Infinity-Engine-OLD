package ui;

import mods.Mods;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class ComboSprite extends FlxSprite
{
	var isComboText:Bool = false;

	public var origPos:Array<Float> = [0, 0];

	public function new(?x = 0, ?y = 0, ?isComboTextB:Bool = false)
	{
		isComboText = isComboTextB;
		super(x, y);

		loadCombo('0');

		origPos = [x, y];
	}

	public function loadCombo(daCombo:String = '0', skin:String = "default", ?isPixel:Null<Bool>)
	{
		loadGraphic(Util.getImage('ratings/$skin/' + 'num' + daCombo));

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
			setGraphicSize(Std.int(this.width * game.PlayState.pixelAssetZoom * 0.95));
		else
			setGraphicSize(Std.int(this.width * 0.67));

		updateHitbox();
	}

	public function tweenSprite()
	{
		var random1:Float = FlxG.random.float(0.2, 0.6);
		var random2:Float = FlxG.random.float(20, 30);

		FlxTween.cancelTweensOf(this);
		x = origPos[0];
		y = origPos[1];
		alpha = 1;
		/*FlxTween.tween(this, {y: this.y - random2}, random1, {
			ease: FlxEase.cubeOut,
			onComplete: function(twn:FlxTween)
			{
				// this probably won't work
				FlxTween.tween(this, {alpha: 0}, random1, {
					ease: FlxEase.cubeInOut,
				});

			}
		});*/
	}
}
