package menus;

import menus.FreeplayMenuState;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.AlphabetText;

using StringTools;

class NoteBGOpacityMenu extends BasicSubState
{
	var bg:FlxSprite;
	var offsetWarning:FlxText;
	var funnyOffset:FlxText;
	var holdTime:Float = 0;
	var stupidDumb:Float = 0;

	var leftP:Bool = false;
	var left:Bool = false;
	var rightP:Bool = false;
	var right:Bool = false;
	var accept:Bool = false;

	var maxOffset:Int = 1;

	override public function create()
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		funnyOffset = new FlxText(0, 0, 0, "placeholder", 64);
		funnyOffset.setFormat(Util.getFont('vcr'), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyOffset.scrollFactor.set();
		funnyOffset.screenCenter();
		funnyOffset.borderSize = 2.4;
		add(funnyOffset);

		offsetWarning = new FlxText(0, FlxG.height * 0.8, 0, "Press LEFT & RIGHT to adjust the opacity of the Note BG.", 32);
		offsetWarning.setFormat(Util.getFont('vcr'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetWarning.scrollFactor.set();
		offsetWarning.screenCenter(X);
		offsetWarning.borderSize = 2.4;
		add(offsetWarning);

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
			var daMultiplier:Float = left ? -0.1 : 0.1;
			changeOffset(daMultiplier);
		} else {
			holdTime = 0;
		}

		funnyOffset.text = "Current Note BG Opacity: " + FlxMath.roundDecimal(Options.getData('note-bg-opacity'), 1);
		funnyOffset.screenCenter();

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));

		stupidDumb = elapsed;

		super.update(elapsed);
	}

	public function changeOffset(?change:Float = 0)
	{
		holdTime += stupidDumb;

		if(holdTime > 0.5 || leftP || rightP)
		{
			var offset:Float = Options.getData('note-bg-opacity');
			offset += change;

			if(offset < 0)
				offset = 0;

			if(offset > maxOffset)
				offset = maxOffset;

			Options.saveData('note-bg-opacity', offset);
		}
	}
}