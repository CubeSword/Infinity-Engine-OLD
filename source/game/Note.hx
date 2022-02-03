package game;

import mods.Mods;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Note extends FlxSprite {
	var resetAnim:Float = 0;
	public var noteskin:String = 'default';
	public var isPixel:Bool = false;
	public var noteID:Int = 0;

	public var strum:Float = 0.0;
	public var mustPress:Bool = false;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;
	public var shouldHit:Bool = true;
	public var sustainLength:Float = 0;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public static var swagWidth:Float = 160 * 0.7;

	public var scaleX:Float = 0;
	public var scaleY:Float = 0;

	public var lastNote:Note;

	public var origPos:Array<Float> = [0, 0];

	public function new(x, y, noteID:Int = 0, ?strum:Float, ?mustPress:Bool, ?noteskin:String = 'default', ?isSustainNote:Bool = false, ?isEndNote:Bool = false)
	{
		super(x, y);

		this.noteskin = noteskin;
		this.noteID = noteID;
		this.strum = strum;
		this.mustPress = mustPress;
		this.isSustainNote = isSustainNote;
		this.isEndNote = isEndNote;
		
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
			frames = Util.getSparrow('noteskins/' + noteskin + '/notes');
			
			antialiasing = Options.getData('anti-aliasing');
			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			
			if(!isSustainNote)
			{
				switch(Math.abs(noteID % 4))
				{
					case 0:
						animation.addByPrefix('strum', 'left0', 24, false);				
					case 1:
						animation.addByPrefix('strum', 'down0', 24, false);
					case 2:
						animation.addByPrefix('strum', 'up0', 24, false);					
					case 3:
						animation.addByPrefix('strum', 'right0', 24, false);
				}
			}
			else
			{
				if(!isEndNote)
				{
					switch(Math.abs(noteID % 4))
					{
						case 0:
							animation.addByPrefix('strum', 'left hold0', 24, false);				
						case 1:
							animation.addByPrefix('strum', 'down hold0', 24, false);
						case 2:
							animation.addByPrefix('strum', 'up hold0', 24, false);					
						case 3:
							animation.addByPrefix('strum', 'right hold0', 24, false);
					}

					@:privateAccess
					scale.y *= (Conductor.stepCrochet / 100) * 1.52 * PlayState.instance.speed;
					updateHitbox();
				}
				else
				{
					switch(Math.abs(noteID % 4))
					{
						case 0:
							animation.addByPrefix('strum', 'left hold end0', 24, false);				
						case 1:
							animation.addByPrefix('strum', 'down hold end0', 24, false);
						case 2:
							animation.addByPrefix('strum', 'up hold end0', 24, false);					
						case 3:
							animation.addByPrefix('strum', 'right hold end0', 24, false);
					}
				}

				@:privateAccess
				if(Options.getData('downscroll'))
					flipY = true;

				alpha = 0.6;
			}
		} else { // if the note skin is INDEED pixel
			loadGraphic(Util.getImage('noteskins/' + noteskin + '/notes'));
			width = width / 9;
			height = height / 5;
			loadGraphic(Util.getImage('noteskins/' + noteskin + '/notes'), true, Math.floor(width), Math.floor(height));
			
			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.pixelAssetZoom));
			updateHitbox();
			
			if(!isSustainNote)
			{
				switch(Math.abs(noteID % 4))
				{
					case 0:
						animation.add('strum', [9]);
					case 1:
						animation.add('strum', [10]);
					case 2:
						animation.add('strum', [11]);
					case 3:
						animation.add('strum', [12]);
				}
			}
			else
			{
				loadGraphic(Util.getImage('noteskins/' + noteskin + '/notesENDS'));
				width = width / 9;
				height = height / 2;
				loadGraphic(Util.getImage('noteskins/' + noteskin + '/notesENDS'), true, Math.floor(width), Math.floor(height));
				
				antialiasing = false;
				setGraphicSize(Std.int(width * PlayState.pixelAssetZoom));
				updateHitbox();

				if(!isEndNote)
				{
					switch(Math.abs(noteID % 4))
					{
						case 0:
							animation.add('strum', [0]);
						case 1:
							animation.add('strum', [1]);
						case 2:
							animation.add('strum', [2]);
						case 3:
							animation.add('strum', [3]);
					}

					@:privateAccess
					scale.y *= (Conductor.stepCrochet / 100) * 1.5 * PlayState.instance.speed;
					updateHitbox();
				}
				else
				{
					switch(Math.abs(noteID % 4))
					{
						case 0:
							animation.add('strum', [9]);
						case 1:
							animation.add('strum', [10]);
						case 2:
							animation.add('strum', [11]);
						case 3:
							animation.add('strum', [12]);
					}
				}

				@:privateAccess
				if(Options.getData('downscroll'))
					flipY = true;

				alpha = 0.6;
			}
		}
		
		playAnim('strum', true);
	}
	
	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		
		//centerOrigin();
		//centerOffsets();
	}
	
	override public function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('strum');
				resetAnim = 0;
			}
		}

		if(animation.curAnim.name == 'confirm' && !isPixel) {
			centerOrigin();
		}

		scaleX = scale.x;
		scaleY = scale.y;

		super.update(elapsed);
	}

	public function calculateCanBeHit()
	{
		if(this != null)
		{
			if(mustPress)
			{
				if (isSustainNote)
				{
					if(shouldHit)
					{
						if (strum > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
							&& strum < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
							canBeHit = true;
						else
							canBeHit = false;
					}
					else
					{
						if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
							&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
							canBeHit = true;
						else
							canBeHit = false;
					}
				}
				else
				{
					if(shouldHit)
					{
						if (strum > Conductor.songPosition - Conductor.safeZoneOffset
							&& strum < Conductor.songPosition + Conductor.safeZoneOffset)
							canBeHit = true;
						else
							canBeHit = false;
					}
					else
					{
						if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
							&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
							canBeHit = true;
						else
							canBeHit = false;
					}
				}
	
				if (strum < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
					tooLate = true;
			}
			else
			{
				canBeHit = false;
	
				if (strum <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}
	}
}
