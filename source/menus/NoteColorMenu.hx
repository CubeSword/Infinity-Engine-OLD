package menus;

import game.Note;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.AlphabetText;

using StringTools;

class NoteColorMenu extends BasicSubState
{
	var bg:FlxSprite;
	var noteColorWarning:FlxText;
	var colorTypeText:FlxText;

	var colorType:Int = 0;
	var holdTime:Float = 0;

	var colorNumbers:FlxTypedGroup<FlxText>;
	var shaderArray:Array<ColorSwap> = [];
	
	var daNotes:FlxTypedGroup<Note>;

	var colors:Array<Dynamic> = [];

	var keyCount:Int = 4;

	var selectedKey:Int = 0;
	var menuState:String = 'selectKey';

	var left = Controls.UI_LEFT;
	var leftP = Controls.UI_LEFT_P;
	var right = Controls.UI_RIGHT;
	var rightP = Controls.UI_RIGHT_P;
	var accept = Controls.accept;

	public function new()
	{
		super();
		
		colors = Options.getData('note-colors')[keyCount - 1];

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		noteColorWarning = new FlxText(0, FlxG.height * 0.8, 0, "Press any key to continue.", 32);
		noteColorWarning.setFormat(Util.getFont('vcr'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noteColorWarning.scrollFactor.set();
		noteColorWarning.screenCenter(X);
		noteColorWarning.borderSize = 2.4;
		add(noteColorWarning);

		colorTypeText = new FlxText(0, 100, 0, "", 32);
		colorTypeText.setFormat(Util.getFont('vcr'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		colorTypeText.scrollFactor.set();
		colorTypeText.screenCenter(X);
		colorTypeText.borderSize = 2.4;
		add(colorTypeText);

		daNotes = new FlxTypedGroup<Note>();
		add(daNotes);

		colorNumbers = new FlxTypedGroup<FlxText>();
		add(colorNumbers);

		for(i in 0...4)
		{
			var note:Note = new Note((125 * i) + 395, 0, i, 0, false, Options.getData('ui-skin'));
			note.antialiasing = true;
			note.centerOffsets();
			note.centerOrigin();
			note.updateHitbox();
			note.screenCenter(Y);
			note.ID = i;
			daNotes.add(note);

			var newShader:ColorSwap = new ColorSwap();
			note.shader = newShader.shader;
			newShader.hue = colors[i][0] / 360;
			newShader.saturation = colors[i][1] / 100;
			newShader.brightness = colors[i][2] / 100;
			shaderArray.push(newShader);
		}

		for(i in 0...3)
		{
			var number:FlxText = new FlxText(0, 135, 0, "", 32);
			number.setFormat(Util.getFont('vcr'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			number.scrollFactor.set();
			number.screenCenter(X);
			number.borderSize = 2.4;
			colorNumbers.add(number);
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		left = Controls.UI_LEFT;
		leftP = Controls.UI_LEFT_P;
		right = Controls.UI_RIGHT;
		rightP = Controls.UI_RIGHT_P;
		accept = Controls.accept;

		if(Controls.back)
		{
			var fuck = Options.getData('note-colors');
			fuck[keyCount - 1] = colors;

			Options.saveData('note-colors', fuck);
			close();
		}

		var numberMultiplier:Int = 190;

		for(i in 0...colorNumbers.members.length)
		{
			colorNumbers.members[i].text = colors[selectedKey][i];
			colorNumbers.members[i].screenCenter(X);

			switch(i)
			{
				case 0:
					colorNumbers.members[i].x -= numberMultiplier;
				case 2:
					colorNumbers.members[i].x += numberMultiplier;
			}
		}

		switch(menuState)
		{
			case 'selectKey':
				colorTypeText.text = "";
				noteColorWarning.text = "Press LEFT & RIGHT to select an arrow";

				for(i in 0...colorNumbers.members.length)
				{
					colorNumbers.members[i].visible = false;
				}

				if(left)
					changeSelection(-1);

				if(right)
					changeSelection(1);

				if(accept)
				{
					FlxG.sound.play(Util.getSound('menus/confirmMenu'));
					menuState = 'selectType';
				}
			case 'selectType':
				colorTypeText.text = "Hue       Sat       Brt";
				colorTypeText.screenCenter(X);

				noteColorWarning.text = "Press LEFT & RIGHT to select a value to set\nPress ACCEPT to edit the value\n";

				for(i in 0...colorNumbers.members.length)
				{
					colorNumbers.members[i].visible = true;
					colorNumbers.members[i].color = (colorType == i) ? FlxColor.CYAN : FlxColor.WHITE;
				}

				if(left)
					changeColorTypeSelection(-1);

				if(right)
					changeColorTypeSelection(1);

				if(accept)
				{
					FlxG.sound.play(Util.getSound('menus/confirmMenu'));
					menuState = 'changeType';
				}
			case 'changeType':
				colorTypeText.text = "Hue       Sat       Brt";
				colorTypeText.screenCenter(X);

				if(leftP || rightP)
				{
					if(leftP) changeColorTypeValue(-1, elapsed);
					if(rightP) changeColorTypeValue(1, elapsed);
				}
				else
					holdTime = 0;

				if(accept)
				{
					FlxG.sound.play(Util.getSound('menus/confirmMenu'));
					menuState = 'selectKey';
				}

				noteColorWarning.text = "Press LEFT & RIGHT to change the value\nPress ACCEPT to confirm and save\n";
		}

		noteColorWarning.screenCenter(X);

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));
	}

	public function changeSelection(?change:Int = 0)
	{
		selectedKey += change;

		if(selectedKey < 0)
			selectedKey = daNotes.members.length - 1;

		if(selectedKey > daNotes.members.length - 1)
			selectedKey = 0;	

		for(i in 0...daNotes.members.length)
		{
			if(daNotes.members[i].ID == selectedKey)
			{
				daNotes.members[i].alpha = 1;
				daNotes.members[i].scale.set(0.8, 0.8);
			} else {
				daNotes.members[i].alpha = 0.6;
				daNotes.members[i].scale.set(0.7, 0.7);
			}
		}

		FlxG.sound.play(Util.getSound('menus/scrollMenu'));
	}

	public function changeColorTypeSelection(?change:Int = 0)
	{
		colorType += change;

		if(colorType < 0)
			colorType = 2;

		if(colorType > 2)
			colorType = 0;
	}

	function changeColorTypeValue(?change:Int = 0, elapsed:Float)
	{
		var comedy:Int = 360;

		switch(colorType)
		{
			case 1 | 2:
				comedy = 100;
		}

		holdTime += elapsed;

		if(holdTime > 0.5 || left || right)
		{
			colors[selectedKey][colorType] += change;

			if(colors[selectedKey][colorType] < (comedy * -1))
				colors[selectedKey][colorType] = (comedy * -1);

			if(colors[selectedKey][colorType] > comedy)
				colors[selectedKey][colorType] = comedy;

			shaderArray[selectedKey].hue = colors[selectedKey][0] / 360;
			shaderArray[selectedKey].saturation = colors[selectedKey][1] / 100;
			shaderArray[selectedKey].brightness = colors[selectedKey][2] / 100;
		}
	}
}