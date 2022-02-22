package menus;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import mods.Mods;
import lime.utils.Assets;

using StringTools;

class HitsoundMenu extends BasicSubState
{
	var bg:FlxSprite;
	var scrollSpeedWarning:FlxText;
	var funnyScrollSpeed:FlxText;
	var holdTime:Float = 0;
	var stupidDumb:Float = 0;

	var leftP:Bool = false;
	var left:Bool = false;
	var rightP:Bool = false;
	var right:Bool = false;
	var accept:Bool = false;

	static var rawHitsounds:Dynamic;
	static var hitsounds:Array<Dynamic>;

	override public function create()
	{
		getHitsounds();

		trace(hitsounds);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		funnyScrollSpeed = new FlxText(0, 0, 0, "placeholder", 64);
		funnyScrollSpeed.setFormat(Util.getFont('vcr'), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyScrollSpeed.scrollFactor.set();
		funnyScrollSpeed.screenCenter();
		funnyScrollSpeed.borderSize = 2.4;
		add(funnyScrollSpeed);

		scrollSpeedWarning = new FlxText(0, FlxG.height * 0.8, 0, "Press LEFT & RIGHT to change hitsound.", 32);
		scrollSpeedWarning.setFormat(Util.getFont('vcr'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollSpeedWarning.scrollFactor.set();
		scrollSpeedWarning.screenCenter(X);
		scrollSpeedWarning.borderSize = 2.4;
		add(scrollSpeedWarning);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	override public function update(elapsed:Float)
	{
		leftP = Controls.UI_LEFT;
		left = Controls.UI_LEFT_P;
		rightP = Controls.UI_RIGHT;
		right = Controls.UI_RIGHT_P;
		accept = Controls.accept;

		if(Controls.back)
			close();

		if(left || right) {
			var daMultiplier:Int = left ? -1 : 1;
			changeOffset(daMultiplier);
		} else {
			holdTime = 0;
		}

		funnyScrollSpeed.text = "Current Hitsound: " + hitsounds[Options.getData('hitsound')].name;
		funnyScrollSpeed.screenCenter();

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		stupidDumb = elapsed;

		super.update(elapsed);
	}

	public function changeOffset(?change:Float = 0)
	{
		holdTime += stupidDumb;

		if(holdTime > 0.5 || leftP || rightP)
		{
			var speed:Float = Options.getData('hitsound');
			speed += change;

			if(speed < 0)
				speed = hitsounds.length - 1;

			if(speed > hitsounds.length - 1)
				speed = 0;

			Options.saveData('hitsound', speed);

			playCurrentHitsound();
		}
	}

	function playCurrentHitsound()
	{
		var hitsoundList:Dynamic = menus.HitsoundMenu.getHitsounds();

		var hitSound:FlxSound;

		hitSound = FlxG.sound.load(Util.getSound('gameplay/hitsounds/${hitsoundList[Options.getData('hitsound')].fileName}'));

		hitSound.play(true);
	}

	public static function getHitsounds()
	{
        rawHitsounds = Util.getJsonContents(Util.getJsonPath("data/hitsoundList"));
        hitsounds = rawHitsounds.hitsounds;

        #if sys
        Mods.updateActiveMods();
        
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/hitsoundList.json'))
                {
                    var coolData:Dynamic = Util.getJsonContents('mods/$mod/data/hitsoundList.json').hitsounds;

                    for(i in 0...coolData.length)
                    {
                        hitsounds.push(coolData[i]);
                    }
                }
            }
        }
        #end

		return hitsounds;
	}
}

typedef HitsoundList =
{
    var hitsounds:Array<SwagHitsound>;
}

typedef SwagHitsound =
{
    var name:String;
    var fileName:String;
}