package menus;

import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup;
import ui.AlphabetText;
import game.Conductor;
import openfl.system.System;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import mods.Mods;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import DiscordRPC;

class TitleScreenState extends BasicState
{
	// regular vars
	var logo:FlxSprite;
	var gf:FlxSprite;
	var pressAccept:FlxSprite;
	
	// static vars
	static public var hasAlreadyAccepted:Bool = false; // controls music
	static public var optionsInitialized:Bool = false;
	
	static public var startedTitle:Bool = false;

	var accepted:Bool = false; // controls the ability to spam enter lol

	var boppedLeft:Bool = false;

	var alreadyDidFunnies:Bool = false;

	var stupidFuck:Bool = false;

	var swagIntroText:FlxGroup;
	var ngLogo:FlxSprite;

	var curText:Array<String>;

	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	override public function create()
	{
		super.create();

		funkyBpm(102);

		alreadyDidFunnies = false;

		optionsInitialized = false;

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
		new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
		{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		Options.init();
		Mods.init();
		optionsInitialized = true;

		UISkinMenu.skinCheck();

		curText = FlxG.random.getObject(getIntroText());

		swagIntroText = new FlxGroup();
		add(swagIntroText);
		
		persistentUpdate = true;
		persistentDraw = true;

		FlxG.fixedTimestep = false;

		ngLogo = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Util.getImage('newgroundsLogo'));
		ngLogo.visible = false;
		ngLogo.setGraphicSize(Std.int(ngLogo.width * 0.8));
		ngLogo.updateHitbox();
		ngLogo.screenCenter(X);
		ngLogo.antialiasing = Options.getData('anti-aliasing');
		add(ngLogo);

		gf = new FlxSprite(FlxG.width * 0.4, 2000);
		gf.frames = Util.getSparrow('titlescreen/titleGF');
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gf.animation.play('danceLeft');
		gf.antialiasing = Options.getData('anti-aliasing');
		add(gf);

		if(Options.getData('engine-watermarks'))
		{
			logo = new FlxSprite(-100, 1000);
			logo.frames = Util.getSparrow('titlescreen/logoBumpinInfinity');
		}
		else
		{
			logo = new FlxSprite(-100, 1000);
			logo.frames = Util.getSparrow('titlescreen/logoBumpin');
		}
		
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, false);
		logo.animation.play('idle');
		logo.antialiasing = Options.getData('anti-aliasing');
		add(logo);

		pressAccept = new FlxSprite();
		pressAccept.frames = Util.getSparrow('titlescreen/titleEnter');
		pressAccept.animation.addByPrefix('idle', 'Press Enter to Begin', 24, true);
		pressAccept.animation.addByPrefix('pressed', 'ENTER PRESSED', 24, true);
		pressAccept.animation.play('idle');
		pressAccept.screenCenter(X);
		pressAccept.y = FlxG.height - 145;
		pressAccept.antialiasing = Options.getData('anti-aliasing');
		add(pressAccept);

		gf.visible = false;
		logo.visible = false;
		pressAccept.visible = false;

		Conductor.songPosition = 0;
		curBeat = 0;

		if(startedTitle)
			startIntro();
		
		if(!hasAlreadyAccepted) {
			FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		#if discord_rpc
		if(!DiscordRPC.started && Options.getData("discord-rpc"))
			DiscordRPC.initialize();

		Application.current.onExit.add(function (exitCode) {
			DiscordRPC.shutdown();
		}, false, 100);
		#end

		if(Options.getData('volume') != null)
			FlxG.sound.volume = Options.getData('volume');

		BasicState.changeAppTitle(Util.engineName, "Title Screen");
	}

	function startIntro()
	{
		if (!startedTitle)
		{
			remove(ngLogo);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(swagIntroText);
			startedTitle = true;
		}

		alreadyDidFunnies = true;

		gf.visible = true;
		logo.visible = true;
		pressAccept.visible = true;

		gf.y = 2000;
		logo.y = 1000;
	}

	function getIntroText():Array<Dynamic>
	{
		var rawText:String = Util.getText('data/introText.txt');

		var array1:Array<String> = rawText.split("\n");
		var swagArray:Array<Dynamic> = [];

		for(i in array1)
		{
			swagArray.push(i.split('--'));
		}

		return swagArray;
	}

	override public function update(elapsed:Float):Void
	{
		Conductor.songPosition += (FlxG.elapsed * 1000);

		if (Controls.accept && !accepted)
		{
			if(!startedTitle)
				startIntro();
			
			FlxG.sound.play(Util.getSound("menus/confirmMenu", true));

			hasAlreadyAccepted = true; // prevents title music from restarting if it's already playing
			accepted = true; // prevents spamming enter
			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;

			if(pressAccept != null && pressAccept.active)
				pressAccept.animation.play('pressed');

			FlxG.camera.flash(FlxColor.WHITE, 2);

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				transitionState(new MainMenuState());
			});
		}

		if(startedTitle)
		{
			if(logo != null && logo.active)
				logo.y = FlxMath.lerp(logo.y, -100, Math.max(0, Math.min(1, elapsed * 3)));

			if(gf != null && gf.active)
				gf.y = FlxMath.lerp(gf.y, FlxG.height * 0.07, Math.max(0, Math.min(1, elapsed * 3)));
		}

		super.update(elapsed);
	}

	override public function beatHit()
	{
		super.beatHit();

		if(startedTitle)
		{
			logo.animation.play('idle');

			if(!boppedLeft)
				gf.animation.play('danceLeft');
			else
				gf.animation.play('danceRight');

			boppedLeft = !boppedLeft;
		}

		if(!startedTitle)
		{
			switch(curBeat)
			{
				case 1:
					createText(['swordcube', 'Raf', 'ZonianDX', 'Leather128']);
				case 3:
					addMoreText('present');
				case 4:
					deleteText();
				case 5:
					createText(['In association', 'with']);
				case 7:
					addMoreText('Newgrounds');
					ngLogo.visible = true;
				case 8:
					deleteText();
					ngLogo.visible = false;
				case 9:
					createText([curText[0]]);
				case 11:
					addMoreText(curText[1]);
				case 12:
					deleteText();
				case 13:
					addMoreText("Friday");
				case 14:
					addMoreText("Night");
				case 15:
					addMoreText("Funkin");
			}
		}

		if(curBeat >= 16 && !alreadyDidFunnies)
			startIntro();
	}

	function createText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var text:AlphabetText = new AlphabetText(0, 0, textArray[i]);
			text.screenCenter(X);
			text.y += (i * 60) + 200;
			swagIntroText.add(text);
		}
	}

	function addMoreText(text:String)
	{
		var text:AlphabetText = new AlphabetText(0, 0, text);
		text.screenCenter(X);
		text.y += (swagIntroText.length * 60) + 200;
		swagIntroText.add(text);
	}

	function deleteText()
	{
		while (swagIntroText.members.length > 0)
		{
			swagIntroText.remove(swagIntroText.members[0], true);
		}
	}
}

