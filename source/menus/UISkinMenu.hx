package menus;

import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import mods.Mods;
import ui.ComboSprite;
import ui.RatingSprite;
import game.Note;
import game.StrumArrow;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import ui.AlphabetText;

using StringTools;

class UISkinMenu extends BasicSubState
{
	var bg:FlxSprite;

	static var selectedSkin:Int = 0;
	var selectedSkinText:FlxText;

	static var skinList:Array<String> = [];
	
	var ratings:Array<String> = ["marvelous", "sick", "good", "bad", "shit"];

	var strumNotes:FlxTypedGroup<StrumArrow>;
	var normalNotes:FlxTypedGroup<Note>;

	var ratingGroup:FlxTypedGroup<RatingSprite>;
	var comboGroup:FlxTypedGroup<ComboSprite>;

	static var swagged:Bool = false;

	static var isStinkySkin:Bool = false;

	public function new()
	{
		super();

		isStinkySkin = false;
		selectedSkin = Options.getData("ui-skin-num");

		swagged = false;
		skinCheck();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		selectedSkinText = new FlxText(0, 60, 0, "", 32);
		selectedSkinText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		selectedSkinText.borderSize = 2;
		add(selectedSkinText);

		strumNotes = new FlxTypedGroup<StrumArrow>();
		add(strumNotes);

		normalNotes = new FlxTypedGroup<Note>();
		add(normalNotes);

		ratingGroup = new FlxTypedGroup<RatingSprite>();
		add(ratingGroup);

		comboGroup = new FlxTypedGroup<ComboSprite>();
		add(comboGroup);

		var dumbSpacing:Int = 65;

		for (i in 0...4) {
			var note:StrumArrow = new StrumArrow((125 * i) + 395, 0, i, Options.getData('ui-skin'));
			note.centerOffsets();
			note.centerOrigin();
			note.updateHitbox();
			note.screenCenter(Y);

			note.y -= dumbSpacing;
			note.setOrigPos();

			note.ID = i;
			strumNotes.add(note);
		}

		for (i in 0...4) {
			var note:Note = new Note((125 * i) + 395, 0, i, Options.getData('ui-skin'));
			note.centerOffsets();
			note.centerOrigin();
			note.updateHitbox();
			note.screenCenter(Y);

			note.y += dumbSpacing;
			note.setOrigPos();

			note.ID = i;
			normalNotes.add(note);
		}

		for(i in 0...5)
		{
			var rating:RatingSprite = new RatingSprite(60, 120 + (i * 100));
			rating.loadRating(ratings[i], skinList[selectedSkin]);
			ratingGroup.add(rating);
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		reloadShit();
	}

	public static function skinCheck()
	{
		if(!swagged)
		{
			#if sys
			skinList = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/images/noteskins/");
			#else
			skinList = ["default", "default-pixel"];
			#end
			
			#if sys
			for(mod in Mods.activeMods)
			{
				if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/images/noteskins/'))
				{
					var swagCheckArray = sys.FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/images/noteskins/');
					trace(swagCheckArray);
	
					for(dir in swagCheckArray)
					{
						skinList.push(dir);
					}
	
					trace(skinList);
				} // linux
			}
			#end

			swagged = true;
		}
		
		if(!Assets.exists('assets/images/noteskins/' + skinList[selectedSkin] + '/config.json'))
		{
			isStinkySkin = true;
			// if it doesn't exist in assets, we try to load from mods, if that doesn't exist then your selected skin is stinky and will be reset to default
			#if sys
			for(mod in Mods.activeMods)
			{
				if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/images/noteskins/' + skinList[selectedSkin] + '/config.json'))
				{
					isStinkySkin = false;
				}
			}
			#end
		}

		if(isStinkySkin) // reset skin to default if it's stinky and doesn't exist
		{
			selectedSkin = 0;
			Options.saveData("ui-skin", skinList[selectedSkin]);
			Options.saveData("ui-skin-num", selectedSkin);
		}

		trace("DOES YOUR SKIN EXIST? " + (!isStinkySkin ? "YES!" : "lmao no"));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var back = Controls.back;
		var left = Controls.UI_LEFT;
		var right = Controls.UI_RIGHT;

		if(back)
			close();

		if(left)
			changeSkin(-1);

		if(right)
			changeSkin(1);

		selectedSkinText.text = "< " + skinList[selectedSkin] + " >";
		selectedSkinText.screenCenter(X);

		bg.alpha = FlxMath.lerp(bg.alpha, 0.6, Math.max(0, Math.min(1, elapsed * 6)));
	}

	function changeSkin(?change:Int = 0)
	{
		selectedSkin += change;

		if(selectedSkin < 0)
			selectedSkin = skinList.length - 1;

		if(selectedSkin > skinList.length - 1)
			selectedSkin = 0;

		reloadShit();

		Options.saveData("ui-skin", skinList[selectedSkin]);
		Options.saveData("ui-skin-num", selectedSkin);
	}

	function reloadShit()
	{
		for(i in 0...strumNotes.members.length)
		{
			var note = strumNotes.members[i];
			FlxTween.cancelTweensOf(note);
			note.loadNoteShit(skinList[selectedSkin]);
			note.y = note.origPos[1] - 15;
			note.alpha = 0;

			FlxTween.tween(note, {y: note.y + 15, alpha: 1}, 0.6, {
				ease: FlxEase.cubeOut
			});
		}

		for(i in 0...normalNotes.members.length)
		{
			var note = normalNotes.members[i];
			FlxTween.cancelTweensOf(note);
			note.loadNoteShit(skinList[selectedSkin]);
			note.y = note.origPos[1] - 15;
			note.alpha = 0;

			FlxTween.tween(note, {y: note.y + 15, alpha: 1}, 0.6, {
				ease: FlxEase.cubeOut
			});
		}

		for(i in 0...ratingGroup.members.length)
		{
			var rating = ratingGroup.members[i];
			FlxTween.cancelTweensOf(rating);
			rating.loadRating(ratings[i], skinList[selectedSkin]);
			rating.y = rating.origPos[1] - 15;
			rating.alpha = 0;

			FlxTween.tween(rating, {y: rating.y + 15, alpha: 1}, 0.6, {
				ease: FlxEase.cubeOut
			});
		}
	}
}