package ui;

import game.PlayState;
import mods.Mods;
import lime.utils.Assets;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	var directions:Array<String> = ['left', 'down', 'up', 'right'];
	var splashTexturePath:String = "";
	var noteID:Int = 0;
	var doingThe:Bool = false;

	public function new(x, y, noteID:Int = 0)
	{
		super(x, y);
		antialiasing = Options.getData('anti-aliasing');
		this.noteID = noteID;
		alpha = 0.6;
		doSplash();
	}

	public function doSplash()
	{
		var json:Dynamic = null;
		var noteskin:String = PlayState.curUISkin;

		if(Assets.exists('assets/images/noteskins/' + noteskin + '/config.json'))
			json = Util.getJsonContents('assets/images/noteskins/' + noteskin + '/config.json');
		#if sys
		else
		{
			#if sys
			for(mod in Mods.activeMods)
			{
				if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/images/noteskins/' + noteskin))
				{
					json = Util.getJsonContents('mods/$mod/images/noteskins/' + noteskin + '/config.json');
				}
			}
			#end
		}
		#end

		var theFunny:String = 'note splash ' + directions[noteID % 4];
		frames = game.PlayState.noteSplashFrames;
		animation.addByPrefix('splash', theFunny + "0", 35, false);
		animation.play('splash');
		doingThe = true;

		setGraphicSize(Std.int(this.width * 0.8));

		updateHitbox();
		centerOrigin();
		centerOffsets();
		offset.set(json.splashOffsets[0], json.splashOffsets[1]);
	}

	override function update(elapsed:Float)
	{
		if(animation.curAnim.finished && doingThe)
			kill();

		super.update(elapsed);
	}
}
