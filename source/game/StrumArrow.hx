package game;

import mods.Mods;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumArrow extends FlxSprite {
	var resetAnim:Float = 0;
	var noteskin:String = 'default';
	public var isPixel:Bool = false;
	var noteID:Int = 0;

	public var origPos:Array<Float> = [0, 0];

	public function new(x, y, noteID:Int = 0, ?noteskin:String = 'default')
	{
		super(x, y);
		this.noteskin = noteskin;
		this.noteID = noteID;
		
		loadNoteShit(this.noteskin);
		setOrigPos();
	}

	public function setOrigPos()
	{
		origPos = [this.x, this.y];
	}
	
	public function loadNoteShit(noteskin:String = 'default')
	{
		var json:Dynamic = null;
		
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
		
		isPixel = json.isPixel; // this uses a json for config shit because gaming
		
		if(!isPixel) { // if the note skin is NOT pixel
			frames = Util.getSparrow('noteskins/' + noteskin + '/noteStrums');
			
			antialiasing = Options.getData('anti-aliasing');
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			
			switch(Math.abs(noteID % 4))
			{
				case 0:
					animation.addByPrefix('strum', 'left static0', 24, false);
					animation.addByPrefix('tap', 'left press0', 24, false);
					animation.addByPrefix('confirm', 'left confirm0', 24, false);				
				case 1:
					animation.addByPrefix('strum', 'down static0', 24, false);
					animation.addByPrefix('tap', 'down press0', 24, false);
					animation.addByPrefix('confirm', 'down confirm0', 24, false);
				case 2:
					animation.addByPrefix('strum', 'up static0', 24, false);
					animation.addByPrefix('tap', 'up press0', 24, false);
					animation.addByPrefix('confirm', 'up confirm0', 24, false);					
				case 3:
					animation.addByPrefix('strum', 'right static0', 24, false);
					animation.addByPrefix('tap', 'right press0', 24, false);
					animation.addByPrefix('confirm', 'right confirm0', 24, false);
			}
		} else { // if the note skin is INDEED pixel
			loadGraphic(Util.getImage('noteskins/' + noteskin + '/notes'));
			width = width / 9;
			height = height / 5;
			loadGraphic(Util.getImage('noteskins/' + noteskin + '/notes'), true, Math.floor(width), Math.floor(height));
			
			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.pixelAssetZoom));
			updateHitbox();
			
			switch(Math.abs(noteID % 4))
			{
				case 0:
					animation.add('strum', [0]);
					animation.add('tap', [9, 18], 12, false);
					animation.add('confirm', [27, 36], 24, false);
				case 1:
					animation.add('strum', [1]);
					animation.add('tap', [10, 19], 12, false);
					animation.add('confirm', [28, 37], 24, false);
				case 2:
					animation.add('strum', [2]);
					animation.add('tap', [11, 20], 12, false);
					animation.add('confirm', [29, 38], 12, false);
				case 3:
					animation.add('strum', [3]);
					animation.add('tap', [12, 21], 12, false);
					animation.add('confirm', [30, 39], 24, false);
			}
		}
		
		playAnim('strum', true);

		scrollFactor.set(0,0);
	}
	
	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		
		centerOrigin();

		if(!isPixel)
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;
	
			var scale = 0.7;
	
			offset.x -= 156 * scale / 2;
			offset.y -= 156 * scale / 2;
		}
		else
			centerOffsets();
	}
	
	override public function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('strum');
				resetAnim = 0;
			}
		}
		
		super.update(elapsed);
	}
}