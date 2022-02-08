package menus;

import game.StrumArrow;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.AlphabetText;

using StringTools;

class KeybindMenu extends BasicSubState
{
	var bg:FlxSprite;
	var keybindWarning:FlxText;
	var daNotes:FlxTypedGroup<StrumArrow>;
	var daKeybinds:FlxTypedGroup<FlxText>;

	var currentKeybinds:Array<String> = [];

	var keyCount:Int = 4;

	var selectedKey:Int = 0;
	var isEditingKey:Bool = false;
	var checkingForKeys:Bool = false;

	public function new()
	{
		super();
			
		currentKeybinds = Options.getData('mainBinds')[keyCount - 1];

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		keybindWarning = new FlxText(0, FlxG.height * 0.8, 0, "Press any key to continue.", 32);
		keybindWarning.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keybindWarning.scrollFactor.set();
		keybindWarning.screenCenter(X);
		keybindWarning.borderSize = 2.4;
		add(keybindWarning);

		daNotes = new FlxTypedGroup<StrumArrow>();
		add(daNotes);

		daKeybinds = new FlxTypedGroup<FlxText>();
		add(daKeybinds);

		for (i in 0...4) {
			var note:StrumArrow = new StrumArrow((125 * i) + 395, 0, i, Options.getData('ui-skin'));
			note.centerOffsets();
			note.centerOrigin();
			note.updateHitbox();
			note.screenCenter(Y);
			note.ID = i;
			daNotes.add(note);
		}

		for (i in 0...daNotes.members.length) {
			var daKeybindText:FlxText = new FlxText(daNotes.members[i].x, 0, 48, "A", 48, true);
			daKeybindText.scrollFactor.set();
			daKeybindText.screenCenter(Y);
			
			daKeybindText.color = FlxColor.WHITE;
			daKeybindText.borderStyle = OUTLINE;
			daKeybindText.borderColor = FlxColor.BLACK;
			//daKeybindText.setFormat("assets/fonts/vcr.ttf", 48, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			daKeybindText.borderSize = 3;
			daKeybinds.add(daKeybindText);
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var up = Controls.UI_UP;
		var down = Controls.UI_DOWN;
		var left = Controls.UI_LEFT;
		var right = Controls.UI_RIGHT;
		var accept = Controls.accept;
		var acceptP = Controls.acceptP;

		if(Controls.back)
			close();

		for(i in 0...daKeybinds.members.length)
		{
			daKeybinds.members[i].text = currentKeybinds[i];
			daKeybinds.members[i].x = (daNotes.members[i].x + (daNotes.members[i].width / 2) - (24 /* text size / 2 */)) + 5;
		}

		if(!isEditingKey)
		{
			if(left) changeSelection(-1);
			if(right) changeSelection(1);
			if(accept) {
				checkingForKeys = false;
				isEditingKey = true;
				FlxG.sound.play(Util.getSound('menus/confirmMenu'));
			}
		} else {
			if(!acceptP)
			{
				checkingForKeys = true;
			}
			if(FlxG.keys.getIsDown().length > 0 && checkingForKeys) {
				currentKeybinds[selectedKey] = FlxG.keys.getIsDown()[0].ID.toString();
				Options.mainBinds = currentKeybinds;

				var fuck = Options.getData('mainBinds');
				fuck[selectedKey] = Options.mainBinds;

				Options.saveData('mainBinds', fuck);
				isEditingKey = false;
				FlxG.sound.play(Util.getSound('menus/scrollMenu'));
			}
		}

		if(isEditingKey) {
			keybindWarning.text = "Press any key to continue.";
		} else {
			keybindWarning.text = "Press LEFT & RIGHT to select an arrow\nPress ACCEPT to change the keybind for the arrow";
		}

		keybindWarning.screenCenter(X);

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
				if(!daNotes.members[i].isPixel)
					daNotes.members[i].scale.set(0.8, 0.8);
			} else {
				daNotes.members[i].alpha = 0.6;
				if(!daNotes.members[i].isPixel)
					daNotes.members[i].scale.set(0.7, 0.7);
			}
		}

		FlxG.sound.play(Util.getSound('menus/scrollMenu'));
	}
}