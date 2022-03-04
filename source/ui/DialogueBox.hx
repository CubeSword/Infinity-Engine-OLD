package ui;

import flixel.FlxBasic;
import mods.Mods;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import game.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.addons.text.FlxTypeText;
import flixel.tweens.FlxTween;

using StringTools;

class DialogueBox extends FlxGroup
{
	public var dialogueType:String = 'normal';
	public var dialogueBox:FlxSprite;
	public var swagFade:FlxSprite;

	public static var dialogue:String = "coolswag";
	public static var character:String = "bf";

	public var dialogueText:FlxTypeText;

	public var textSpeed:Float = 0.05;

	var alignment:String = "left";

	var characters:Array<Dynamic> = [];
	var characterSwag:Dynamic;

	var leftPort:FlxSprite;
	var middlePort:FlxSprite;
	var rightPort:FlxSprite;

	public function new(swagDialogue:String = "coolswag", ?initCharacter:String = "bf")
	{
		super();

		dialogue = swagDialogue;
		character = initCharacter;
		characters = [];

		refreshCharacterJson(initCharacter);

		trace(character);

		//the fade
		swagFade = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		swagFade.alpha = 0;
		swagFade.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		add(swagFade);

		FlxTween.tween(swagFade, {alpha: 0.25}, 1, {ease: FlxEase.cubeInOut});

		//the box
		dialogueBox = new FlxSprite(60, FlxG.height * 0.45);
		dialogueBox.frames = Util.getSparrow('dialogue/boxes/normal/assets', false);

		dialogueBox.animation.addByPrefix('open', 'Speech Bubble Normal Open', 12, false);
		dialogueBox.animation.addByPrefix('idle', 'speech bubble normal', 24, true);
		dialogueBox.animation.addByPrefix('loud', 'AHH speech bubble', 24, true);

		dialogueBox.animation.addByIndices('close', 'Speech Bubble Normal Open', [4, 3, 2, 1, 0], "", 12, false);

		dialogueBox.antialiasing = Options.getData('anti-aliasing');

		dialogueBox.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		dialogueBox.scrollFactor.set();

		/*//the characters
		leftPort = new FlxSprite(dialogueBox.x + 30, dialogueBox.y + 30);
		leftPort.frames = Util.getSparrow('dialogue/characters/$character/assets', false);

		middlePort = new FlxSprite(0, dialogueBox.y + 30);
		middlePort.screenCenter(X);
		middlePort.frames = Util.getSparrow('dialogue/characters/$character/assets', false);

		rightPort = new FlxSprite(dialogueBox.x + 130, dialogueBox.y + 30);
		rightPort.frames = Util.getSparrow('dialogue/characters/$character/assets', false);
		
		for(i in 0...character.length)
		{
			if(character[i].alignment == 'left')
			{
				leftPort.animation.addByPrefix(character[i].name + '-talk', character[i].name + ' talk', 24, false);
				leftPort.animation.addByPrefix(character[i].name + '-idle', character[i].name + ' idle', 24, true);
			}
			else if(character[i].alignment == 'middle')
			{
				middlePort.animation.addByPrefix(character[i].name + '-talk', character[i].name + ' talk', 24, false);
				middlePort.animation.addByPrefix(character[i].name + '-idle', character[i].name + ' idle', 24, true);
			}
			else
			{
				rightPort.animation.addByPrefix(character[i].name + '-talk', character[i].name + ' talk', 24, false);
				rightPort.animation.addByPrefix(character[i].name + '-idle', character[i].name + ' idle', 24, true);
			}
		}
		
		add(leftPort);
		add(middlePort);
		add(rightPort);*/

		add(dialogueBox);

		//leftPort.animation.play('normal-idle');
		dialogueBox.animation.play('open');

		//the text
		dialogueText = new FlxTypeText(dialogueBox.x + 60, dialogueBox.y + 120, Std.int(dialogueBox.width * 0.85), dialogue + "\n", 48);
		dialogueText.setFormat(Util.getFont('funkin'), 48, FlxColor.BLACK, LEFT);
		dialogueText.sounds = [FlxG.sound.load(Util.getSound('dialogue/sounds/normal/talk', false))];
		dialogueText.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		dialogueText.scrollFactor.set();
		dialogueText.start(textSpeed);
		add(dialogueText);
	}

	override function update(elapsed:Float)
	{
		if(dialogueBox.animation.curAnim.name == 'open' && dialogueBox.animation.curAnim.finished)
			dialogueBox.animation.play('idle', true);

		if(dialogueBox.animation.curAnim.name == 'close' && dialogueBox.animation.curAnim.finished)
			dialogueBox.kill();

		super.update(elapsed);
	}

	public function stopDialogue()
	{
		dialogueText.kill();
		dialogueBox.animation.play('close');
		
		FlxTween.tween(swagFade, {alpha: 0}, 0.4, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
			swagFade.kill();
		}});
	}

	public function changeDialogueText(text:String = "", char:String = "bf")
	{
		FlxG.sound.play(Util.getSound('dialogue/sounds/normal/click', false));
		dialogueText.resetText(text);
		dialogueText.start(textSpeed, true);
	}

	function refreshCharacterJson(char:String = "bf")
	{
		// check if char json exists
		#if sys
		if(Assets.exists('assets/dialogue/$char.json'))
		{
		#end
			characterSwag = Util.getJsonContents('assets/dialogue/$char.json');
			character = characterSwag.emotions;
		#if sys
		}
		else
		{
			Mods.updateActiveMods();

			if(Mods.activeMods.length > 0)
			{
				for(mod in Mods.activeMods)
				{
					if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/dialogue/$char.json'))
					{
						characterSwag = Util.getJsonContents('mods/$mod/dialogue/$char.json');
						character = characterSwag.emotions;
					}
				}
			}
		}
		#end
	}
}

class DialogueCharacter extends FlxSprite
{
	public var ogPos:Array<Float> = [0, 0];
	public var json:DialogueCharacterFile;
	public var box:FlxSprite;

	public var offsets:Array<Dynamic> = [];

	override public function new(?char:String = "bf", box:FlxSprite)
	{
		this.box = box;

		super();
		loadChar(char);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(animation.curAnim.name.contains("-talk") && animation.curAnim.finished)
		{
			playAnim(animation.curAnim.name.replace("-talk", "-idle"), true);
		}
	}

	public function loadChar(?char:String = "bf")
	{
		json = Util.getJsonContents(Util.getPath('dialogue/characters/$char/config.json'));

		frames = Util.getSparrow('dialogue/characters/$char/assets', false);

		for(i in 0...json.animations.length)
		{
			//trace(json.animations[i][0] + " - " + json.animations[i][1] + " - " + json.animations[i][2] + " - " + json.animations[i][3]);
			animation.addByPrefix(json.animations[i][0], json.animations[i][1], json.animations[i][2], json.animations[i][3]);
			offsets.push([json.animations[i][0], json.animations[i][4][0], json.animations[i][4][1]]);
		}
		
		playAnim('normal-talk', true);

		setupPosition();
	}

	public function setupPosition()
	{
		var alignment:String = json.alignment;
		
		switch(alignment)
		{
			case 'left':
				setPosition(box.x + 180, box.y - 330);
			case 'middle' | 'center':
				y = box.y - 330;
				screenCenter(X);
			case 'right':
				setPosition(box.x + 700, box.y - 330);
			default:
				setPosition(box.x + 700, box.y - 330);
		}

		ogPos = [x, y];
		setPosition(ogPos[0] + json.position[0], ogPos[1] + json.position[1]);
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reverse:Bool = false, ?frame:Int = 0)
	{
		if(animation.getByName(anim) != null)
		{
			animation.play(anim, force, reverse, frame);

			for(array in offsets)
			{
				if(array[0] == anim)
					offset.set(array[1], array[2]);
			}
		}
	}
}

typedef DialogueCharacterFile =
{
	var scale:Float;
	var alignment:String;
	var antialiasing:Bool;
	var position:Array<Float>;
	var animations:Array<Dynamic>;
	/*  [
			["name", "prefix", 24, false]
		]
	*/
}
