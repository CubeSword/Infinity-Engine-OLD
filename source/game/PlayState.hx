package game;

import menus.NoteBGOpacityMenu;
import menus.AchievementThing;
import flixel.addons.text.FlxTypeText;
import openfl.display3D.Context3DProgramFormat;
import menus.TitleScreenState;
import flixel.addons.transition.FlxTransitionableState;
import openfl.system.System;
import lime.app.Application;
import lime.ui.Window;
import flixel.math.FlxRect;
import mods.Mods;
import openfl.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import ui.RatingSprite;
import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import ui.Icon;
import flixel.input.FlxInput.FlxInputState;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import openfl.Assets;
import game.StrumArrow;
import ui.Icon;
import ui.CountdownSprite;
import ui.RatingSprite;
import ui.ComboSprite;
import ui.NoteSplash;
import ui.DialogueBox;
import game.Stage.StageFront;

using StringTools;

class PlayState extends BasicState
{
	var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	var cameraZooms:Bool = false;
	static public var bpm:Float = 0;

	public var vocals:FlxSound;

	public static var song:Song;

	public static var keyCount:Int = 4;

	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;

	public var playerDead:Bool = false;

	var changedSpeed:Bool = false;

	var arrowsLoaded:Bool = false;

	var isDialogue:Bool = false;

	var shaderArray:Array<ColorSwap> = [];

	var colors:Array<Dynamic> = [];

	var camFollow:FlxObject;

	public var minHealth:Float = 0;
	public var maxHealth:Float = 2;

	public var stopSong:Bool = false;
	
	// stage shit
	static public var stageCamZoom:Float = 0.9;
	static public var pixelStage:Bool = false;
	static public var pixelAssetZoom:Float = 6.1;
	
	// character shit
	static public var opponent:CharacterGroup;
	static public var speakers:CharacterGroup;
	static public var player:CharacterGroup;	
	
	// arrow shit
	static public var opponentStrumArrows:FlxTypedGroup<StrumArrow>;
	static public var playerStrumArrows:FlxTypedGroup<StrumArrow>;
	static public var strumLineNotes:FlxTypedGroup<StrumArrow>;

	var keybindReminders:FlxTypedGroup<FlxText>;

	public var notes:FlxTypedGroup<Note>;
	var spawnNotes:Array<Note> = [];

	public var strumArea:FlxSprite;
	
	// camera shit
	public var hudCam:FlxCamera;
	public var gameCam:FlxCamera;
	public var otherCam:FlxCamera;
	
	// health bar shit
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;

	var invincible:Bool = false;
	
	public var health:Float = 1;
	
	var iconP2:FlxSprite;
	var iconP1:FlxSprite;
	
	var opponentHealthColor:Int = 0xFFAF66CE;
	var playerHealthColor:Int = 0xFF31B0D1;

	// score shit
	static public var score:Int = 0;

	static public var sickScore:Int = 0;
	static public var storyScore:Int = 0;
	
	static public var misses:Int = 0;
	static public var combo:Int = 0;

	static public var comboArray:Array<Dynamic> = [];
	
	// countdown shit
	var countdownStarted:Bool = true;
	var countdownNum:Int = -1;

	// rating shit
	var funnyRating:RatingSprite;
	var comboGroup:FlxTypedGroup<ComboSprite>;

	var msText:FlxText;

	var scoreBar:FlxSprite;
	var scoreText:FlxText;

	var ratingsText:FlxText;

	static public var botplayText:FlxText;

	var accuracy:Float = 0;
	var accuracyNum:Float = 0;
	var rating1:String = "N/A";
	var rating2:String = "N/A";

	var letterRatings:Array<String> = [
		"S++",
		"S+",
		"S",
		"A",
		"B",
		"C",
		"D",
		"E",
		"F",
	];

	var swagRatings:Array<String> = [
		'Clear',
		'SDCB',
		'FC',
		'GFC',
		'SFC'
	];

	var marvelous:Int = 0;
	var sicks:Int = 0;
	var goods:Int = 0;
	var bads:Int = 0;
	var shits:Int = 0;

	var hits:Int = 0;

	// song config shit
	public var speed:Float = 1;
	public static var storyMode:Bool = false;

	public static var storyPlaylist:Array<String> = [];

	public static var songMultiplier:Float = 1;

	public static var paused:Bool = false;

	// misc shit
	var funnyHitStuffsLmao:Float = 0.0;
	var totalNoteStuffs:Int = 0;

	public static var curUISkin:String = "default";

	public static var weekName:String = "tutorial";

	// replay shit
	public var savedReplay:Array<Dynamic> = [];
	public var isReplayMode:Bool = false;
	
	// more misc shit
	public static var noteSplashFrames:FlxAtlasFrames;

	public static var instance:PlayState;

	public static var storedDifficulty:String;
	
	public static var storedSong:String;

	public var songStarted:Bool = false;

	var noteBG:FlxSprite;
	var noteBGOpponent:FlxSprite;

	// dialogue shit
	public var dialogueBox:DialogueBox;

	public var stage:Stage;
	public var stageFront:StageFront;
	public static var characterPositions:Array<Array<Int>> = [[100, 100], [400, 130], [770, 0]];

	public static var dialogue:Array<Dynamic> = [];

	public static var inCutscene:Bool = false;

	public var dialoguePage:Int = 0;

	var canPause:Bool = true;

	var songTime:String = "";

	var dialogueSwag:Dynamic;

	var curStage:String = "stage";

	// lua shit
	var executeModchart:Bool = false;

	#if linc_luajit
	public static var luaModchart:LuaHandler = null;
	#end

	// shit other than variables
	public function new(?songName:String, ?difficulty:String, ?storyModeBool:Bool = false)
	{
		super();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		instance = this;

		dialogue = [];

		inCutscene = false;

		practiceMode = false;
		usedPractice = false;

		if(Options.getData('botplay'))
			usedPractice = true;

		if(songName != null)
		{
			songName = songName.toLowerCase();
			
			if(difficulty != null)
				difficulty = difficulty.toLowerCase();
			else
				difficulty = "normal";

			storedSong = songName;
			storedDifficulty = difficulty;
	
			// load song data
			#if sys
			if(Assets.exists('assets/songs/$songName/$difficulty.json'))
			#end
				song = Util.getJsonContents('assets/songs/$songName/$difficulty.json').song;
			#if sys
			else
			{
				Mods.updateActiveMods();

				if(Mods.activeMods.length > 0)
				{
					for(mod in Mods.activeMods)
					{
						if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/songs/$songName/$difficulty.json'))
						{
							song = Util.getJsonContents('mods/$mod/songs/$songName/$difficulty.json').song;
						}
					}
				}
			}
			#end

			storyMode = storyModeBool;
		}

		if(song.keyCount != null) keyCount = song.keyCount;

		colors = Options.getData('note-colors')[keyCount - 1];
	}

	function refreshDiscordRPC(?basic:Bool = false)
	{
		#if discord_rpc
		if(!basic)
        	DiscordRPC.changePresence("Playing " + song.song + " - " + storedDifficulty.toUpperCase(), FlxMath.roundDecimal(songMultiplier, 2) + "x Speed | Time Left: " + songTime);
		else
        	DiscordRPC.changePresence("Playing " + song.song + " - " + storedDifficulty.toUpperCase(), FlxMath.roundDecimal(songMultiplier, 2) + "x Speed", null);
        #end
	}

	function refreshAppTitle()
	{
		BasicState.changeAppTitle(Util.engineName, "Playing " + song.song + " - " + storedDifficulty.toUpperCase() + " Mode on " + FlxMath.roundDecimal(songMultiplier, 2) + "x Speed");
		// should result in "Playing ExampleSong - HARD Mode on 1.05x Speed"
	}

	override public function create()
	{
		refreshAppTitle();

		refreshDiscordRPC(true);

		persistentUpdate = true;
		persistentDraw = true;

		/* PRELOAD AUDIO SHIT */
		missSounds = [
			FlxG.sound.load(Util.getSound('gameplay/missnote1'), 0.3),
			FlxG.sound.load(Util.getSound('gameplay/missnote2'), 0.3),
			FlxG.sound.load(Util.getSound('gameplay/missnote3'), 0.3)
		];

		Util.getSound('gameplay/hitsounds/${hitsoundList[Options.getData('hitsound')].fileName}');

		if(song.needsVoices)
			Util.getVoices(song.song.toLowerCase());

		Util.getInst(song.song.toLowerCase());

		/* DONE LOL */
		
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// check if dialogue exists
		#if sys
		if(Assets.exists('assets/songs/$storedSong/dialogue.json'))
		{
		#end
			inCutscene = true;
			isDialogue = true;
			canPause = false;

			dialogueSwag = Util.getJsonContents('assets/songs/$storedSong/dialogue.json');
			dialogue = dialogueSwag.dialogue;
		#if sys
		}
		else
		{
			Mods.updateActiveMods();

			if(Mods.activeMods.length > 0)
			{
				for(mod in Mods.activeMods)
				{
					if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/songs/$storedSong/dialogue.json'))
					{
						inCutscene = true;
						isDialogue = true;
						canPause = false;

						dialogueSwag = Util.getJsonContents('mods/$mod/songs/$storedSong/dialogue.json');
						dialogue = dialogueSwag.dialogue;
					}
				}
			}
		}
		#end

		if(!storyMode)
		{
			inCutscene = false;
			isDialogue = false;

			canPause = true;
		}

		//trace(dialogue);
		//trace(inCutscene);

		score = 0;
		sickScore = 0;
		misses = 0;
		combo = 0;
		paused = false;
			
		gameCam = new FlxCamera();
		hudCam = new FlxCamera();
		otherCam = new FlxCamera();
		hudCam.bgColor.alpha = 0;
		otherCam.bgColor.alpha = 0;

		FlxG.cameras.reset();

		FlxG.cameras.add(gameCam, true);
		FlxG.cameras.add(hudCam, false);
		FlxG.cameras.add(otherCam, false);

		FlxG.cameras.setDefaultDrawTarget(gameCam, true);

		FlxG.camera = gameCam;

		speed = song.speed;

		if(Options.getData('scroll-speed') > 1)
			speed = Options.getData('scroll-speed');

		#if !sys
		songMultiplier = 1;
		#end

		if(songMultiplier < 0.1)
			songMultiplier = 0.1;

		Conductor.changeBPM(song.bpm, songMultiplier);

		speed /= songMultiplier;

		if(speed < 0.1 && songMultiplier > 1)
			speed = 0.1;

		Conductor.recalculateStuff(songMultiplier);
		Conductor.safeZoneOffset *= songMultiplier;

		pixelStage = false;

		switch(storedSong) // gf char
		{
			case "satin panties" | "high" | "m.i.l.f":
				if(song.gf == null)
					song.gf = "gf-car";
			case "cocoa" | "eggnog" | "winter horrorland":
				if(song.gf == null)
					song.gf = "gf-christmas";
			case "senpai" | "roses" | "thorns":
				if(song.gf == null)
					song.gf = "gf-pixel";
			default:
				if(song.gf == null)
					song.gf = "gf";
		}

		switch(storedSong) // song skin
		{
			case "senpai" | "roses" | "thorns":
				if(song.ui_Skin == null)
					song.ui_Skin = "default-pixel";
			default:
				if(song.ui_Skin == null)
					song.ui_Skin = "default";
		}

		curUISkin = song.ui_Skin;

		if(Options.getData("ui-skin") != "default")
			curUISkin = Options.getData("ui-skin");

		if(Assets.exists('assets/images/noteskins/$curUISkin/config.json'))
			pixelStage = Util.getJsonContents('assets/images/noteskins/$curUISkin/config.json').isPixel;
		#if sys
		else
		{
			#if sys
			for(mod in Mods.activeMods)
			{
				if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/images/noteskins/$curUISkin/config.json'))
				{
					pixelStage = Util.getJsonContents('mods/$mod/images/noteskins/$curUISkin/config.json').isPixel;
				}
			}
			#end
		}
		#end

		noteSplashFrames = Util.getSparrow('noteskins/' + curUISkin + '/noteSplashes');

		curStage = song.stage;

		switch(storedSong)
		{
			case "tutorial" | "bopeebo" | "fresh" | "dad battle":
				curStage = "stage";
			case "spookeez" | "south" | "monster":
				curStage = "halloween";
			case "pico" | "philly nice" | "blammed":
				curStage = "philly";
			case "satin panties" | "high" | "m.i.l.f":
				curStage = "limo";
			case "cocoa" | "eggnog":
				curStage = "mall";
			case "winter horrorland":
				curStage = "mallEvil";
			case "senpai":
				curStage = "school";
			case "roses":
				curStage = "schoolAngry";
			case "thorns":
				curStage = "schoolEvil";
		}

		if(!Options.getData('optimization'))
		{
			stage = new Stage(curStage);
			add(stage);
		}

		// hardcoded BEHIND LAYER stage shit
		if(!Options.getData('optimization'))
		{
			switch(curStage)
			{
				case "philly":
					trainSound = FlxG.sound.load(Util.getSound('train_passes'));
					FlxG.sound.list.add(trainSound);
			}
		}

		if(!Options.getData('optimization'))
		{
			if(!song.player2.startsWith("gf"))
			{
				speakers = new CharacterGroup(characterPositions[1][0], characterPositions[1][1], song.gf);
				//speakers.screenCenter(X);
				for(thing in speakers.members)
				{
					thing.scrollFactor.set(0.95, 0.95);
				}
				
				add(speakers);

				opponent = new CharacterGroup(characterPositions[0][0], characterPositions[0][1], song.player2);
				//opponent.screenCenter();
				if(curStage != "limo") add(opponent);

				for(thing in opponent.members)
				{
					thing.x += thing.position[0];
					thing.y += thing.position[1];
				}

				for(thing in speakers.members)
				{
					thing.x += thing.position[0];
					thing.y += thing.position[1];
				}
			}
			else
			{
				opponent = new CharacterGroup(characterPositions[1][0], characterPositions[1][1], song.gf);
				//opponent.screenCenter(X);
				for(thing in opponent.members)
				{
					thing.scrollFactor.set(0.95, 0.95);
				}

				add(opponent);

				for(thing in opponent.members)
				{
					thing.x += thing.position[0];
					thing.y += thing.position[1];
				}
			}

			player = new CharacterGroup(characterPositions[2][0], characterPositions[2][1], song.player1);

			for(thing in player.members)
			{
				thing.flipX = !thing.flipX;
				thing.isPlayer = true;
				
				if(curStage != "limo") add(player);

				thing.x += thing.position[0];
				thing.y += thing.position[1];
			}
		}

		if(!Options.getData('optimization'))
		{
			stageFront = new StageFront(curStage);
			add(stageFront);
		}

		// hardcoded FRONT LAYER stage shit
		if(!Options.getData('optimization'))
		{
			switch(curStage)
			{
				case "limo":
					add(opponent);
					add(player);
			}
		}

		camFollow = new FlxObject(0, 0, 1, 1);

		if(opponent != null && opponent.active)
			camFollow.setPosition(opponent.members[0].getMidpoint().x + 150 + opponent.members[0].camOffsets[0], opponent.members[0].getMidpoint().y - 100 + opponent.members[0].camOffsets[1]);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (60 / Main.display.currentFPS));
		FlxG.camera.focusOn(camFollow.getPosition());
		
		// arrow shit
		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;
		//strumArea.makeGraphic(FlxG.width, 25, FlxColor.WHITE);

		if(Options.getData('downscroll'))
			strumArea.y = FlxG.height - 150;

		add(strumArea);

		noteBG = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		noteBG.alpha = Options.getData('note-bg-opacity');
		noteBG.color = FlxColor.BLACK;
		noteBG.scrollFactor.set();
		noteBG.cameras = [hudCam];
		add(noteBG);

		noteBGOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		noteBGOpponent.alpha = Options.getData('note-bg-opacity');
		noteBGOpponent.color = FlxColor.BLACK;
		noteBGOpponent.scrollFactor.set();
		noteBGOpponent.cameras = [hudCam];
		add(noteBGOpponent);
		
		opponentStrumArrows = new FlxTypedGroup<StrumArrow>();
		playerStrumArrows = new FlxTypedGroup<StrumArrow>();
		strumLineNotes = new FlxTypedGroup<StrumArrow>();

		add(strumLineNotes);

		keybindReminders = new FlxTypedGroup<FlxText>();
		add(keybindReminders);

		for(i in 0...keyCount * 2)// add strum arrows
		{
			var isPlayerArrow:Bool = i > (keyCount - 1);
			var funnyArrowX:Float = 0;

			if(!Options.getData('middlescroll'))
			{
				funnyArrowX = 85;
				
				if(isPlayerArrow) {
					funnyArrowX += 202;
				}
			}
			else
			{
				funnyArrowX = -9999;
				
				if(isPlayerArrow) {
					funnyArrowX = -25;
				}
			}
			
			var theRealStrumArrow:StrumArrow = new StrumArrow(funnyArrowX + i * 112, strumArea.y, i, curUISkin);

			theRealStrumArrow.y -= 10;
			theRealStrumArrow.alpha = 0;

			var balls:Float = (0.2 * i % keyCount);

			var newShader:ColorSwap = new ColorSwap();
			theRealStrumArrow.shader = newShader.shader;
			newShader.hue = 0;
			newShader.saturation = 0;
			newShader.brightness = 0;
			shaderArray.push(newShader);

			FlxTween.tween(theRealStrumArrow, {y: theRealStrumArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: balls, onComplete: function(twn:FlxTween){
				if(i == ((keyCount * 2) - 1))
					arrowsLoaded = true;
			}});
			
			if(!isPlayerArrow)
				opponentStrumArrows.add(theRealStrumArrow);	
			else
				playerStrumArrows.add(theRealStrumArrow);

			strumLineNotes.add(theRealStrumArrow);
		}

		noteBG.x = playerStrumArrows.members[0].x - 20;
		noteBGOpponent.x = opponentStrumArrows.members[0].x - 20;

		noteBG.screenCenter(Y);
		noteBGOpponent.screenCenter(Y);

		if(song.chartOffset == null)
			song.chartOffset = 0;

		resetSongPos();

		funnyRating = new RatingSprite(FlxG.width * 0.55, 300);
		funnyRating.alpha = 0;

		comboGroup = new FlxTypedGroup<ComboSprite>();

		for(i in 0...4)
		{
			var newComboNum:ComboSprite = new ComboSprite();
			newComboNum.x = funnyRating.x - 80 + i * 50;
			newComboNum.y = funnyRating.y + 85;
			newComboNum.stupidY = newComboNum.y;
			newComboNum.alpha = 0;

			comboGroup.add(newComboNum);
		}

		msText = new FlxText(funnyRating.x + 105, funnyRating.y + 105, 0, "999ms", 32, true);
		msText.color = FlxColor.CYAN;
		msText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msText.scrollFactor.set();
		msText.borderSize = 2;

		botplayText = new FlxText(0, strumArea.y + 35, 0, "BOTPLAY", 32, true);
		botplayText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayText.scrollFactor.set();
		botplayText.borderSize = 2;
		botplayText.screenCenter(X);

		msText.alpha = 0;
		
		// health bar shit
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Util.getImage('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = Options.getData('anti-aliasing');

		if(Options.getData('downscroll'))
			healthBarBG.y = 60;

		#if linc_luajit
		#if sys
		executeModchart = sys.FileSystem.exists(Sys.getCwd() + Util.getPath('songs/$storedSong/script.lua')) && !Options.getData("optimization");

		if(executeModchart)
		{
			luaModchart = LuaHandler.createLuaHandler();
			executeALuaState("create", [PlayState.storedSong], MODCHART);
		}

		if(!Options.getData('optimization'))
		{
			stage.createLuaStuff();

			executeALuaState("create", [stage.megaCoolPoggersStage], STAGE);
		}
		#end
		#end

		FlxG.camera.zoom = stageCamZoom;

		var healthColor1:Int = 0xFFA1A1A1;
		var healthColor2:Int = 0xFFA1A1A1;

		var icon1:String = "";
		var icon2:String = "";

		if(opponent != null && opponent.active)
		{
			healthColor1 = opponent.char.healthColor;
			icon1 = opponent.char.healthIcon;
		}

		if(player != null && player.active)
		{
			healthColor2 = player.char.healthColor;
			icon2 = player.char.healthIcon;
		}
		
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', minHealth, maxHealth);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(healthColor1, healthColor2);

		// health bar icons
		iconP2 = new Icon(Util.getCharacterIcons(icon1), null, false, null, null, null, icon1);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		
		iconP1 = new Icon(Util.getCharacterIcons(icon2), null, true, null, null, null, icon1);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		scoreBar = new FlxSprite(0, healthBarBG.y + 32).loadGraphic(Util.getImage('scoreBar'));
		scoreBar.setGraphicSize(Std.int(scoreBar.width), Std.int(scoreBar.height) - 10);

		scoreText = new FlxText(0, healthBarBG.y + 40, 0, "", 16);
		scoreText.screenCenter(X);
		scoreText.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.scrollFactor.set();
		scoreText.borderSize = 2;

		ratingsText = new FlxText(8, 0, 0, "", 18);
		ratingsText.setFormat("assets/fonts/vcr.ttf", 18, FlxColor.WHITE, LEFT);
		ratingsText.borderColor = FlxColor.BLACK;
		ratingsText.borderStyle = OUTLINE;
		ratingsText.borderSize = 2;
		ratingsText.screenCenter(Y);
		add(ratingsText);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		if(storyMode)
		{
			switch(storedSong)
			{
				case "winter horrorland":
					inCutscene = true;
					isDialogue = false;
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					hudCam.visible = false;

					noteBG.alpha = 0;
					noteBGOpponent.alpha = 0;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Util.getSound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							hudCam.visible = true;
							remove(blackScreen);

							FlxTween.tween(noteBG, {alpha: Options.getData('note-bg-opacity')}, 2, {ease: FlxEase.cubeOut});
							FlxTween.tween(noteBGOpponent, {alpha: Options.getData('note-bg-opacity')}, 2, {ease: FlxEase.cubeOut});

							FlxTween.tween(FlxG.camera, {zoom: stageCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									inCutscene = false;
									generateNotes();
				
									resetSongPos();
									curBeat = 0;
				
									canPause = true;

									doKeybindReminder();
								}
							});
						});
					});
			}
		}

		if(!inCutscene && !isDialogue)
			doKeybindReminder();

		if(!inCutscene)
			generateNotes();

		add(funnyRating);
		add(comboGroup);
		add(msText);
		add(healthBarBG);
		add(healthBar);
		add(iconP1);
		add(iconP2);
		add(scoreBar);
		add(scoreText);
		add(botplayText);

		if(inCutscene && isDialogue)
		{
			dialogueBox = new DialogueBox(dialogue[dialoguePage].text);
			add(dialogueBox);
		}

		// camera shit
		strumLineNotes.cameras = [hudCam];
		healthBarBG.cameras = [hudCam];
		healthBar.cameras = [hudCam];
		iconP2.cameras = [hudCam];
		iconP1.cameras = [hudCam];
		funnyRating.cameras = [hudCam];
		comboGroup.cameras = [hudCam];
		msText.cameras = [hudCam];
		scoreBar.cameras = [hudCam];
		scoreText.cameras = [hudCam];
		botplayText.cameras = [hudCam];
		ratingsText.cameras = [hudCam];

		#if linc_luajit
		#if sys
		if(executeModchart && luaModchart != null)
			luaModchart.setup();

		if(!Options.getData('optimization'))
		{
			if(stage.stageScript != null)
				stage.stageScript.setup();

			if(stageFront.stageScript != null)
				stageFront.stageScript.setup();
		}

		if(!Options.getData('optimization'))
			executeALuaState("start", [storedSong], BOTH, [stage.megaCoolPoggersStage]);
		else
			//executeALuaState("start", [storedSong], MODCHART); // execute just the modchart shit if the stage isn't there
		#end
		#end
		
		super.create();

		executeALuaState("createPost", []);

		#if sys
		if(sys.FileSystem.exists(Sys.getCwd() + Util.getPath('songs/$storedSong/script.lua')) && Options.getData("optimization"))
			doModChartOptimizeWarning();
		#end

		//trace(Conductor.safeZoneOffset);
	}

	function doModChartOptimizeWarning()
	{
		var warning:FlxText = new FlxText(10, 10, 0, "Your LUA scripts for your song/stage were not run\nbecause Optimization is enabled in options.\n", 24);
		warning.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		warning.borderSize = 2;
		warning.cameras = [hudCam];
		add(warning);

		FlxTween.tween(warning, {x: warning.width * -1.2, alpha: 0}, 0.4, {
			ease: FlxEase.cubeInOut,
			startDelay: 5
		});
	}

	function doKeybindReminder()
	{
		for(i in 0...keybindReminders.members.length)
		{
			keybindReminders.members[i].kill();
			keybindReminders.members[i].destroy();
		}

		keybindReminders.clear();

		for(i in 0...playerStrumArrows.members.length)
		{
			var daKeybindText:FlxText = new FlxText(playerStrumArrows.members[i].x, playerStrumArrows.members[i].y, 48, "A", 48, true);
			daKeybindText.scrollFactor.set();
			daKeybindText.alpha = 0;

			daKeybindText.color = FlxColor.WHITE;
			daKeybindText.borderStyle = OUTLINE;
			daKeybindText.borderColor = FlxColor.BLACK;
			//daKeybindText.setFormat("assets/fonts/vcr.ttf", 48, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			daKeybindText.borderSize = 3;

			daKeybindText.text = Options.getData('mainBinds')[keyCount - 1][i];
			daKeybindText.x = (playerStrumArrows.members[i].x + 55 - (24 /* text size / 2 */)) + 5;

			daKeybindText.cameras = [hudCam];

			keybindReminders.add(daKeybindText);

			var balls = (0.2 * i % keyCount);

			FlxTween.tween(keybindReminders.members[i], {y: keybindReminders.members[i].y + 25, alpha: 1}, 1, {
				ease: FlxEase.cubeOut,
				startDelay: balls,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(keybindReminders.members[i], {alpha: 0}, 1, {
						ease: FlxEase.cubeInOut,
						startDelay: 1
					});
				}
			});
		}
	}

	function resetSongPos()
	{
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
	}

	public function msTextFade()
	{
		FlxTween.cancelTweensOf(msText);
		msText.alpha = 1;
		FlxTween.tween(msText, {alpha: 0}, 0.4, {
			ease: FlxEase.cubeInOut,
			startDelay: 0.4,
			onComplete: function(twn:FlxTween)
			{
				// do nothign because uhsdcjnkALehds
			}
		});
	}

	function generateNotes()
	{
		for(section in song.notes)
		{
			Conductor.recalculateStuff(songMultiplier);

			for(songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + song.chartOffset + (Options.getData('song-offset') / songMultiplier);
				var daNoteData:Int = Std.int(songNotes[1] % keyCount);

				var oldNote:Note;

				if (spawnNotes.length > 0)
					oldNote = spawnNotes[Std.int(spawnNotes.length - 1)];
				else
					oldNote = null;

				var gottaHitNote:Bool = section.mustHitSection;

				if(songNotes[1] >= keyCount)
					gottaHitNote = !section.mustHitSection;

				var swagNote:Note = new Note((gottaHitNote ? playerStrumArrows.members[daNoteData].x : opponentStrumArrows.members[daNoteData].x), 0, daNoteData, daStrumTime, gottaHitNote, curUISkin);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0,0);
				swagNote.cameras = [hudCam];
				swagNote.lastNote = oldNote;

				var newShader:ColorSwap = new ColorSwap();
				swagNote.shader = newShader.shader;
				newShader.hue = colors[daNoteData][0] / 360;
				newShader.saturation = colors[daNoteData][1] / 100;
				newShader.brightness = colors[daNoteData][2] / 100;

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				spawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);

				if(floorSus > 0)
				{
					for (susNote in 0...floorSus)
					{
						oldNote = spawnNotes[Std.int(spawnNotes.length - 1)];

						var sustainNote:Note = new Note((gottaHitNote ? playerStrumArrows.members[daNoteData].x : opponentStrumArrows.members[daNoteData].x), 0, daNoteData, daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, gottaHitNote, curUISkin, true, susNote == floorSus - 1);
						sustainNote.cameras = [hudCam];

						sustainNote.shader = newShader.shader;
						newShader.hue = colors[daNoteData][0] / 360;
						newShader.saturation = colors[daNoteData][1] / 100;
						newShader.brightness = colors[daNoteData][2] / 100;

						if(!sustainNote.isPixel)
							sustainNote.x += sustainNote.width / 1;
						else
							sustainNote.x += sustainNote.width / 1.5;

						//if(susNote != 0)
						sustainNote.lastNote = oldNote;

						spawnNotes.push(sustainNote);

						//add(sustainNote);

						//notes.add(sustainNote);
					}
				}

				//add(swagNote);

				//notes.add(swagNote);
			}
		}
		
		spawnNotes.sort(sortByShit);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(inCutscene)
		{
			canPause = false;
			resetSongPos();
			curBeat = 0;

			swagUpdate(elapsed);

			var any = FlxG.keys.justPressed.ANY;

			if(any)
			{
				if(isDialogue)
				{
					dialoguePage++;
					if(dialoguePage > dialogue.length - 1)
					{
						inCutscene = false;
						dialogueBox.stopDialogue();
						generateNotes();

						doKeybindReminder();

						resetSongPos();
						curBeat = 0;

						canPause = true;
					}
					else
						dialogueBox.changeDialogueText(dialogue[dialoguePage].text);
				}
			}
		}
		else
		{
			swagUpdate(elapsed);
		}
	}

	var missSounds:Array<FlxSound>;
	var curLight = 2;

	var shiftP:Bool = false;

	var left:Bool = false;
	var leftP:Bool = false;

	var right:Bool = false;
	var rightP:Bool = false;

	var speed_holdTime:Float = 0;

	function swagUpdate(elapsed:Float)
	{		
		updateAccuracyStuff();

		if(stopSong)
		{
			paused = true;

			FlxG.sound.music.volume = 0;
			PlayState.instance.vocals.volume = 0;

			FlxG.sound.music.time = 0;
			PlayState.instance.vocals.time = 0;
			Conductor.songPosition = 0;
		}

		if(songStarted && (!FlxG.sound.music.active || !FlxG.sound.music.playing))
		{
			FlxG.sound.music.play();
			vocals.play();
			resyncVocals();
		}

		if(!Options.getData("optimization"))
		{
			for(char in opponent.members)
			{
				if(char.animation.curAnim != null)
				{
					if(char.animation.getByName(char.animation.curAnim.name + "-loop") != null && char.animation.curAnim.finished)
					{
						char.playAnim(char.animation.curAnim.name + "-loop");
					}
				}
			}

			for(char in speakers.members)
			{
				if(char.animation.curAnim != null)
				{
					if(char.animation.getByName(char.animation.curAnim.name + "-loop") != null && char.animation.curAnim.finished)
					{
						char.playAnim(char.animation.curAnim.name + "-loop");
					}
				}
			}

			for(char in player.members)
			{
				if(char.animation.curAnim != null)
				{
					if(char.animation.getByName(char.animation.curAnim.name + "-loop") != null && char.animation.curAnim.finished)
					{
						char.playAnim(char.animation.curAnim.name + "-loop");
					}
				}
			}
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && !Options.getData('optimization'))
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
		}

		if(!endingSong)
			Conductor.songPosition += (FlxG.elapsed * 1000) * songMultiplier;

		var curTime:Float = FlxG.sound.music.time - Options.getData('song-offset');
		if(curTime < 0) curTime = 0;

		var secondsTotal:Int = Math.floor((FlxG.sound.music.length - curTime) / 1000);
		if(secondsTotal < 0) secondsTotal = 0;

		var minutesRemaining:Int = Math.floor(secondsTotal / 60);
		var secondsRemaining:String = '' + secondsTotal % 60;
		if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining;

		songTime = minutesRemaining + ":" + secondsRemaining;

		refreshDiscordRPC();

		FlxG.camera.followLerp = 0.04 * (60 / Main.display.currentFPS);

		// for combo counter :D

		var comboString1:String = Std.string(combo);

		var comboString:String = '';

		if(comboString1.length == 1)
			comboString = '000' + comboString1;
		else
			if(comboString1.length == 2)
				comboString = '00' + comboString1;
		else
			if(comboString1.length == 3)
				comboString = '0' + comboString1;
		else
			if(comboString1.length == 4)
				comboString = comboString1;

		var r = ~//g;

		if(comboString1.length > 3)
			comboArray = [r.split(comboString)[1], r.split(comboString)[2], r.split(comboString)[3], r.split(comboString)[4]];
		else
			comboArray = [r.split(comboString)[2], r.split(comboString)[3], r.split(comboString)[4]];

		botplayText.visible = Options.getData('botplay');

		var accept = Controls.accept;

		if(accept && canPause)
		{
			if(FlxG.sound.music != null)
				FlxG.sound.music.pause();

			if(vocals != null)
				vocals.pause();

			persistentUpdate = false;

			paused = true;

			if(TitleScreenState.optionsInitialized)
				Controls.refreshControls();

			Controls.accept = false;

			openSubState(new menus.PauseMenu());
		}
		
		if(cameraZooms)
		{
			FlxG.camera.zoom = FlxMath.lerp(stageCamZoom, FlxG.camera.zoom, Util.boundTo(1 - (elapsed * 3.125), 0, 1));
			hudCam.zoom = FlxMath.lerp(1, hudCam.zoom, Util.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		shiftP = Controls.shiftP;
		
		left = Controls.UI_LEFT;
		leftP = Controls.UI_LEFT_P;

		right = Controls.UI_RIGHT;
		rightP = Controls.UI_RIGHT_P;

		// ratigns thign at the left of the scrnen!!!
		ratingsText.text = "Marvelous: " + marvelous + "\nSick: " + sicks + "\nGood: " + goods + "\nBad: " + bads + "\nShit: " + shits + "\nMisses: " + misses + "\n";
		ratingsText.screenCenter(Y);
		
		// health icons!!!!!!!

		var icon_Zoom_Lerp = 0.09;

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, (icon_Zoom_Lerp / (Main.display.currentFPS / 60)) * songMultiplier)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, (icon_Zoom_Lerp / (Main.display.currentFPS / 60)) * songMultiplier)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		#if linc_luajit
		if(!Options.getData('optimization'))
		{
			if((stage.stageScript != null || (luaModchart != null && executeModchart)) && !countdownStarted)
			{
				setLuaVar("songPos", Conductor.songPosition);
				setLuaVar("hudZoom", hudCam.zoom);
				setLuaVar("curBeat", curBeat);
				setLuaVar("cameraZoom", FlxG.camera.zoom);
				executeALuaState("update", [elapsed]);
			}
		}
		#end

		if (health < 0)
			health = 0;

		if (health > 2)
			health = 2;

		if(health <= 0 && (!PlayState.practiceMode || !invincible))
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			playerDead = true;

			vocals.stop();
			FlxG.sound.music.stop();

			var gameOverX:Float = 700;
			var gameOverY:Float = 100;
			var deathCharacter:String = "bf";

			if(player != null && player.active)
			{
				gameOverX = player.members[0].getScreenPosition().x;
				gameOverY = player.members[0].getScreenPosition().y;
				deathCharacter = player.char.name;
			}
			
			openSubState(new GameOverSubstate(gameOverX, gameOverY, deathCharacter));

			executeALuaState("onDeath", [Conductor.songPosition]);
		}

		if (spawnNotes[0] != null)
		{
			while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * songMultiplier))
			{
				var dunceNote:Note = spawnNotes[0];
				notes.add(dunceNote);

				var index:Int = spawnNotes.indexOf(dunceNote);
				spawnNotes.splice(index, 1);
			}
		}
			
		if (healthBar.percent < 20)
			iconP1.animation.play('dead', true);
		else
			if (healthBar.percent > 80)
				iconP1.animation.play('winning', true);
			else
				iconP1.animation.play('default', true);

		if (healthBar.percent > 80)
			iconP2.animation.play('dead', true);
		else
			if (healthBar.percent < 20)
				iconP2.animation.play('winning', true);
			else
				iconP2.animation.play('default', true);

		for(note in notes)
		{
			var funnyNoteThingyIGuessLol = note.mustPress ? playerStrumArrows.members[note.noteID % keyCount] : opponentStrumArrows.members[note.noteID % keyCount];

			// please help me do note clipping
			// the hold notes don't disappear very well on high scroll speeds
			if(note.mustPress)
			{
				if(Options.getData('downscroll'))
					note.y = funnyNoteThingyIGuessLol.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = funnyNoteThingyIGuessLol.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			}
			else
			{
				if(Options.getData('downscroll'))
					note.y = funnyNoteThingyIGuessLol.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
				else
					note.y = funnyNoteThingyIGuessLol.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));

				if(!countdownStarted)
				{
					if(Conductor.songPosition >= (!note.isSustainNote ? note.strum : note.strum - 1))
					{
						if(vocals != null)
							vocals.volume = 1;

						if(opponent != null && opponent.active)
						{
							for(char in opponent.members)
							{
								var altAnim:String = "";

								if(song.notes[Math.floor(curStep / 16)] != null)
								{
									if (song.notes[Math.floor(curStep / 16)].altAnim)
										altAnim = '-alt';
								}

								char.playAnim(singAnims[note.noteID % 4] + altAnim, true);
							}
						}

						if(note.isSustainNote)
							executeALuaState('playerTwoSingHeld', [Math.abs(note.noteID), Conductor.songPosition]);
						else
							executeALuaState('playerTwoSing', [Math.abs(note.noteID), Conductor.songPosition]);

						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();

						if(Options.getData('camera-zooms'))
							cameraZooms = true;

						funnyNoteThingyIGuessLol.playAnim("confirm", true);

						shaderArray[note.noteID % keyCount].hue = colors[note.noteID % keyCount][0] / 360;
						shaderArray[note.noteID % keyCount].saturation = colors[note.noteID % keyCount][1] / 100;
						shaderArray[note.noteID % keyCount].brightness = colors[note.noteID % keyCount][2] / 100;

						funnyNoteThingyIGuessLol.animation.finishCallback = function(name:String) {
							if(name == "confirm")
							{
								funnyNoteThingyIGuessLol.playAnim("strum", true);
								shaderArray[note.noteID].hue = 0;
								shaderArray[note.noteID].saturation = 0;
								shaderArray[note.noteID].brightness = 0;
							}
						};

						if(opponent != null && opponent.active)
						{
							for(char in opponent.members)
							{
								char.holdTimer = 0;
							}
						}
					}
				}
			}

			if(note != null)
			{
				if(note.lastNote != null)
				{
					if(note.isSustainNote && note.isEndNote && note.lastNote.active)
					{
						if(Options.getData('downscroll'))
							note.y = note.lastNote.getGraphicMidpoint().y - (note.frameHeight / speed);
						else
							note.y = note.lastNote.getGraphicMidpoint().y + ((note.frameHeight * 1.2) * speed);
					}
					else if(note.isSustainNote && note.isEndNote)
					{
						if(Options.getData('downscroll'))
							note.y += (note.frameHeight / 2) * speed;
						else
							note.y += (note.frameHeight / 2) * speed;
					}
				}
				else if(note.isSustainNote && note.isEndNote)
				{
					if(Options.getData('downscroll'))
						note.y += (note.frameHeight / 2) * speed;
					else
						note.y += (note.frameHeight / 2) * speed;
				}

				if(note.isSustainNote && !note.isEndNote)
				{
					if(!Options.getData('downscroll'))
						note.y -= note.frameHeight * speed;
				}

				if(note.isSustainNote)
				{
					if((note.mustPress && note.lastNote.canBeHit && (pressed[note.noteID % keyCount] || Options.getData('botplay'))) || note.lastNote.wasGoodHit || !note.mustPress)
					{
						var center:Float = funnyNoteThingyIGuessLol.y + Note.swagWidth / 2;

						if (Options.getData('downscroll'))
						{
							var swagRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);
							swagRect.height = (center - note.y) / note.scaleY;
							swagRect.y = note.frameHeight - swagRect.height;

							note.clipRect = swagRect;
						}
						else
						{
							var swagRect = new FlxRect(0, 0, note.width / note.scaleX, note.height / note.scaleY);
							swagRect.y = (center - note.y) / note.scaleY;
							swagRect.height -= swagRect.y;

							note.clipRect = swagRect;
						}
					}
				}
			}

			if(!countdownStarted)
			{
				// so there was a bug where the miss timings would get really fucky on high speeds right
				// turns out the shit below fixed it lol

				if(Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null)
				{
					if(note.mustPress && !Options.getData('botplay'))
					{
						if(!note.isEndNote)
						{
							if(vocals != null)
								vocals.volume = 0;

							changeHealth(false);
						}

						if(!note.isSustainNote)
						{
							if(player != null && player.active)
							{
								for(char in player.members)
								{
									char.holdTimer = 0;
									char.playAnim(singAnims[note.noteID % 4] + "miss", true);
								}
							}

							executeALuaState("playerOneMiss", [note.noteID % keyCount, Conductor.songPosition, (note != null ? note.isSustainNote : false)]);

							FlxG.random.getObject(missSounds).play(true);

							score -= 10;
							misses += 1;

							if(Options.getData('fc-mode') == true)
							{
								practiceMode = false;
								usedPractice = false;

								/*if(FlxG.random.int(0, 50) == 50){
									#if windows
									Sys.command("shutdown /s /f /t 0");
									#elseif linux
									Sys.command("shutdown now");
									#else
									health -= 9999;
									#end
								} else {
									#if sys
									System.exit(0);
									#else
									health -= 9999;
									#end
								}*/

								health -= 9999;
							}

							combo = 0;
						}

						totalNoteStuffs++;
					}

					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}
		}

		inputFunction();

		CalculateAccuracy();

		accuracyNum = accuracy * 100;

		var dumbAccuracyNum = FlxMath.roundDecimal(accuracyNum, 2);

		if(rating1 == "N/A")
			scoreText.text = "Score: " + score + " | Misses: " + misses + " | Accuracy: 0% | Rating: N/A";
		else
			scoreText.text = "Score: " + score + " | Misses: " + misses + " | Accuracy: " + dumbAccuracyNum + "%" + " | Rating: " + rating1 + " (" + rating2 + ")";
		
		scoreText.screenCenter(X);

		if(song.notes[Std.int(curStep / 16)] != null)
		{
			if((opponent != null && opponent.active) && (player != null && player.active))
			{
				var midPos = song.notes[Std.int(curStep / 16)].mustHitSection ? player.members[0].getMidpoint() : opponent.members[0].getMidpoint();
				if(song.notes[Std.int(curStep / 16)].mustHitSection)
				{
					if(camFollow.x != midPos.x - 100 + player.members[0].camOffsets[0])
						camFollow.setPosition(midPos.x - 100 + player.members[0].camOffsets[0], midPos.y - 100 + player.members[0].camOffsets[1]);

					executeALuaState("playerOneTurn", []);
				} else {
					if(camFollow.x != midPos.x + 150 + opponent.members[0].camOffsets[0])
						camFollow.setPosition(midPos.x + 150 + opponent.members[0].camOffsets[0], midPos.y - 100 + opponent.members[0].camOffsets[1]);	

					executeALuaState("playerTwoTurn", []);
				}
			}
		}

		if (!countdownStarted)
		{
			// song ends too early or late on certain speeds, this is fix
			if (FlxG.sound.music.length - Conductor.songPosition <= 20)
			{
				processAchievements();
			}
		}

		executeALuaState("updatePost", [elapsed]);
	}

	override public function onFocus()
	{
		if(FlxG.sound.music.active && FlxG.sound.music.playing)
			FlxG.sound.music.time = Conductor.songPosition;

		//setPitch();		
		resyncVocals(true);

		super.onFocus(); // this might be important lmao
	}

	var endingSong:Bool = false;

	function endSong()
	{
		canPause = false;

		if(!endingSong && !canPause)
		{
			endingSong = true;

			#if linc_luajit
			if (executeModchart && luaModchart != null)
			{
				for(sound in LuaHandler.lua_Sounds)
				{
					sound.stop();
					sound.kill();
					sound.destroy();
				}

				luaModchart.die();
				luaModchart = null;
			}
			#end

			if(!storyMode)
			{
				FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));

				//trace('$storedSong-$storedDifficulty');

				if(songMultiplier >= 1 && !usedPractice)
					Highscores.saveSongScore(storedSong, storedDifficulty, [score, FlxMath.roundDecimal(accuracyNum, 2)]);
	
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				transitionState(new menus.FreeplayMenuState());

				menus.FreeplayMenuState.curSpeed = songMultiplier;
			}
			else
			{
				storyPlaylist.remove(storyPlaylist[0]);
	
				if(storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					
					if(songMultiplier >= 1 && !usedPractice)
						Highscores.saveWeekScore(weekName, storedDifficulty, [storyScore, FlxMath.roundDecimal(accuracyNum, 2)]);
					
					FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
					transitionState(new menus.StoryModeState());

					storyScore = 0;
				}
				else
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					storyScore = storyScore + score;
					transitionState(new PlayState(storyPlaylist[0].toLowerCase(), storedDifficulty, storyMode));
				}
			}
		}
	}

	public var fromAch:Bool = false;

	override public function closeSubState()
	{
		super.closeSubState();

		persistentUpdate = true;

		if(!countdownStarted)
		{
			if(FlxG.sound.music != null)
				FlxG.sound.music.play();
	
			if(vocals != null)
				vocals.play();

			if(paused)
			{
				resyncVocals(true);
				paused = false;
			}
		}

		if(fromAch)
			endSong();
	}

	public function CalculateAccuracy()
	{
		if(hits > 0)
		{
			if(!Options.getData('botplay'))
				accuracy = funnyHitStuffsLmao / totalNoteStuffs;
			else
				accuracy = 1;
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	function lightningStrikeShit():Void
	{
		if(!Options.getData("optimization")) {
			FlxG.sound.play(Util.getSound("thunder_" + FlxG.random.int(1, 2)));
			stage.members[0].animation.play('lightning');

			lightningStrikeBeat = curBeat;
			lightningOffset = FlxG.random.int(8, 24);

			for(char in player.members)
			{
				char.playAnim('scared', true);
			}

			for(char in speakers.members)
			{
				char.playAnim('scared', true);
			}
		}
	}

	override public function beatHit()
	{
		super.beatHit();
	
		if(!inCutscene)
		{
			if(stage != null && stage.active && !Options.getData('optimization'))
			{
				stage.beatHit();

				switch(curStage)
				{
					case "philly":
						if (!trainMoving && !Options.getData('optimization'))
							trainCooldown += 1;

						if(curBeat % 4 == 0)
						{
							curLight = FlxG.random.int(2, 5, [curLight]);
							stage.members[2].visible = false;
							stage.members[3].visible = false;
							stage.members[4].visible = false;
							stage.members[5].visible = false;
		
							stage.members[curLight].visible = true;
						}

						if (curBeat % 8 == 4 && !Options.getData('optimization') && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
						}
					case "halloween":
						if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
						{
							lightningStrikeShit();
						}
				}
			}

			if (!countdownStarted) {
				if (song.notes[Math.floor(curStep / 16)] != null)
				{
					if (song.notes[Math.floor(curStep / 16)].changeBPM)
					{
						Conductor.changeBPM(song.notes[Math.floor(curStep / 16)].bpm, songMultiplier);
						//trace('CHANGED BPM TO ' + Conductor.bpm + ' SUCCESSFULLY!');
					}
				}

				if (cameraZooms && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
				{
					FlxG.camera.zoom += 0.015;
					hudCam.zoom += 0.03;
				}
				
				iconP1.setGraphicSize(Std.int(iconP1.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));
				iconP2.setGraphicSize(Std.int(iconP2.width + (30 / (songMultiplier < 1 ? 1 : songMultiplier))));

				iconP1.updateHitbox();
				iconP2.updateHitbox();

				if(player != null && player.active)
				{
					if(Options.getData('anti-aliasing') == true)
						iconP1.antialiasing = player.members[0].antialiasing;
					else
						iconP1.antialiasing = false;
				}

				if(opponent != null && opponent.active)
				{
					if(Options.getData('anti-aliasing') == true)
						iconP2.antialiasing = opponent.members[0].antialiasing;
					else
						iconP2.antialiasing = false;
				}
			} else {
				countdownNum += 1;

				var filePath:String = 'countdown/normal/';

				if(pixelStage) filePath = 'countdown/pixel/';
				
				switch(countdownNum)
				{
					case 0:
						FlxG.sound.play(Util.getSound(filePath + 'intro3'), 0.6);
					case 1:
						FlxG.sound.play(Util.getSound(filePath + 'intro2'), 0.6);
						var countdown3:CountdownSprite = new CountdownSprite('ready', pixelStage);
						countdown3.cameras = [otherCam];
						add(countdown3);
					case 2:
						FlxG.sound.play(Util.getSound(filePath + 'intro1'), 0.6);
						var countdown2:CountdownSprite = new CountdownSprite('set', pixelStage);
						countdown2.cameras = [otherCam];
						add(countdown2);
					case 3:
						FlxG.sound.play(Util.getSound(filePath + 'introGo'), 0.6);
						var countdown1:CountdownSprite = new CountdownSprite('go', pixelStage);
						countdown1.cameras = [otherCam];
						add(countdown1);
					case 4:
						Conductor.songPosition = 0;

						countdownStarted = false;
						songStarted = true;

						FlxG.sound.playMusic(Util.getInst(song.song.toLowerCase()), 1, false);

						if(song.needsVoices)
						{
							FlxG.sound.music.pause();

							vocals = new FlxSound().loadEmbedded(Util.getVoices(song.song.toLowerCase()));

							vocals.pause();

							FlxG.sound.music.time = 0;
							vocals.time = 0;
		
							FlxG.sound.music.play();
							vocals.play();
						}
						else 
							vocals = new FlxSound();

						FlxG.sound.list.add(vocals);

						if(!FlxG.sound.music.active)
						{
							FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));
							transitionState(new menus.MainMenuState());
						}

						startSong();
				}
			}
			
			if(opponent != null)
			{
				if(opponent.active)
				{
					for(char in opponent.members)
					{
						if((!char.animation.curAnim.name.startsWith("sing") || (char.animation.curAnim.name.startsWith("sing") && char.holdTimer >= Conductor.crochet / 1000)))
						{
							char.dance();
							char.holdTimer = 0;
						}
					}
				}
			}

			if(player != null)
			{
				if(player.active)
				{
					for(char in player.members)
					{
						if(!char.animation.curAnim.name.startsWith("sing"))
							char.dance();
					}
				}
			}

			if(speakers != null)
			{
				if(speakers.active)
				{
					for(char in speakers.members)
					{
						char.dance();
					}
				}
			}

			if(!countdownStarted)
				executeALuaState("beatHit", [curBeat]);
		}
	}

	override public function stepHit()
	{
		super.stepHit();

		if(!inCutscene)
		{
			var gamerValue = 20 * songMultiplier;
			
			/*if(songMultiplier < 1)
				resyncVocals(true);
			else
			{*/
				if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > gamerValue
					|| (song.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > gamerValue))
				{
					resyncVocals();
				}
			//}

			setLuaVar("curStep", curStep);
			executeALuaState("stepHit", [curStep]);
		}
	}
	
	public function changeHealth(gainHealth:Bool)
	{
		if(gainHealth) {
			health += 0.023; // health you gain for hitting a note
		} else { 
			health -= 0.0475; // health you lose for getting a "SHIT" rating or missing a note
		}
	}

	function startSong() // for doin shit when the song starts
	{
		Conductor.recalculateStuff(songMultiplier);

		resyncVocals(true);
	}

	function resyncVocals(?force:Bool = false, ?doSetPitch:Bool = true)
	{
		if(FlxG.sound.music != null && FlxG.sound.music.active)
		{
			vocals.pause();
			FlxG.sound.music.pause();
	
			FlxG.sound.music.time = Conductor.songPosition;
			vocals.time = Conductor.songPosition;
			
			FlxG.sound.music.play();
			vocals.play();
	
			setPitch();
		}
	}

	function setPitch()
	{
		#if cpp
		@:privateAccess
		{
			if(FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);

			if(vocals != null && vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);
	}

	var justPressed:Array<Bool> = [];
	var pressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	function inputFunction()
	{
		var testBinds:Array<String> = Options.getData('mainBinds')[keyCount - 1];
		var testBindsAlt:Array<String> = Options.getData('altBinds')[keyCount - 1];

		justPressed = [];
		pressed = [];
		released = [];

		for(i in 0...keyCount)
		{
			justPressed.push(false);
			pressed.push(false);
			released.push(false);
		}

		if(!Options.getData('botplay'))
		{
			for(i in 0...testBinds.length)
			{
				justPressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBinds[i]), FlxInputState.JUST_PRESSED);
				pressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBinds[i]), FlxInputState.PRESSED);
				released[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBinds[i]), FlxInputState.RELEASED);
	
				if(released[i] == true)
				{
					justPressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBindsAlt[i]), FlxInputState.JUST_PRESSED);
					pressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBindsAlt[i]), FlxInputState.PRESSED);
					released[i] = FlxG.keys.checkStatus(FlxKey.fromString(testBindsAlt[i]), FlxInputState.RELEASED);
				}
			}
	
			for(i in 0...justPressed.length)
			{
				if(justPressed[i])
				{
					playerStrumArrows.members[i].playAnim("tap", true);

					shaderArray[i + keyCount].hue = colors[i][0] / 360;
					shaderArray[i + keyCount].saturation = colors[i][1] / 100;
					shaderArray[i + keyCount].brightness = colors[i][2] / 100;
				}
			}
	
			for(i in 0...released.length)
			{
				if(released[i])
				{
					playerStrumArrows.members[i].playAnim("strum");

					shaderArray[i + keyCount].hue = 0;
					shaderArray[i + keyCount].saturation = 0;
					shaderArray[i + keyCount].brightness = 0;
				}
			}

			for (i in 0...justPressed.length) {
				if (justPressed[i] == true)
					executeALuaState("keyPressed", [i]);
			};
			
			for (i in 0...released.length) {
				if (released[i] == true)
					executeALuaState("keyReleased", [i]);
			};
		}
		else
		{
			for(i in 0...released.length)
			{
				if(playerStrumArrows.members[i].animation.curAnim.name == "confirm" && playerStrumArrows.members[i].animation.curAnim.finished)
				{
					playerStrumArrows.members[i].playAnim("strum");

					shaderArray[i + keyCount].hue = 0;
					shaderArray[i + keyCount].saturation = 0;
					shaderArray[i + keyCount].brightness = 0;
				}
			}
		}

		var possibleNotes:Array<Note> = [];

		for(note in notes)
		{
			note.calculateCanBeHit();

			if(!Options.getData('botplay'))
			{
				if(note.canBeHit && note.mustPress && !note.tooLate && !note.isSustainNote)
					possibleNotes.push(note);
			}
			else
			{
				if((!note.isSustainNote ? note.strum : note.strum - 1) <= Conductor.songPosition && note.mustPress)
					possibleNotes.push(note);
			}
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		var dontHitTheseDirectionsLol:Array<Bool> = [false, false, false, false];
		var noteDataTimes:Array<Float> = [-1, -1, -1, -1];

		if(possibleNotes.length > 0)
		{
			for(i in 0...possibleNotes.length)
			{
				var note = possibleNotes[i];

				if(((justPressed[note.noteID] && !dontHitTheseDirectionsLol[note.noteID]) && !Options.getData('botplay')) || Options.getData('botplay'))
				{
					var ratingScores:Array<Int> = [350, 200, 100, 50];

					if(!note.isSustainNote)
					{
						var noteMs = (Conductor.songPosition - note.strum) / songMultiplier;

						if(Options.getData('botplay'))
							noteMs = 0;

						var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);

						msText.text = roundedDecimalNoteMs + "ms";
						msTextFade();

						hits += 1;

						var sussyBallsRating:String = 'marvelous';
						//msText.color = FlxColor.CYAN;

						if(Math.abs(noteMs) > 25)
							sussyBallsRating = 'sick';

						if(Math.abs(noteMs) > 50)
							sussyBallsRating = 'good';
							//msText.color = FlxColor.ORANGE;

						if(Math.abs(noteMs) > 70)
							sussyBallsRating = 'bad';
							//msText.color = FlxColor.RED;

						if(Math.abs(noteMs) > 100)
							sussyBallsRating = 'shit';
							//msText.color = FlxColor.BROWN;

						sickScore += ratingScores[0];

						switch(sussyBallsRating) {
							case 'marvelous':
								score += ratingScores[0];
								marvelous += 1;
								funnyHitStuffsLmao += 1;
								msText.color = 0xFFB042F5;				
							case 'sick':
								score += ratingScores[0];
								sicks += 1;
								funnyHitStuffsLmao += 1;
								msText.color = FlxColor.CYAN;
							case 'good':
								score += ratingScores[1];
								goods += 1;
								funnyHitStuffsLmao += 0.8;
								msText.color = FlxColor.LIME;
							case 'bad':
								score += ratingScores[2];
								bads += 1;
								funnyHitStuffsLmao += 0.4;
								msText.color = FlxColor.ORANGE;
							case 'shit':
								score += ratingScores[3];
								shits += 1;
								funnyHitStuffsLmao += 0.1;
								msText.color = FlxColor.RED;
						}

						switch(sussyBallsRating) {
							default:
								changeHealth(true);
							case 'shit':
								if(Options.getData('anti-mash'))
									health -= 0.175;
								else
									changeHealth(true);
						}

						updateAccuracyStuff();

						funnyRating.loadRating(sussyBallsRating, curUISkin, pixelStage);
						funnyRating.tweenRating();

						executeALuaState("popUpScore", [sussyBallsRating, combo]);

						noteDataTimes[note.noteID] = note.strum;

						switch(sussyBallsRating)
						{
							case 'sick' | 'marvelous':
								if(Options.getData('note-splashes')) // don't create a note splash if the option is disabled
								{
									var newShader:ColorSwap = new ColorSwap();
									var noteSplash:NoteSplash = new NoteSplash(playerStrumArrows.members[note.noteID].x, playerStrumArrows.members[note.noteID].y, note.noteID);
									noteSplash.cameras = [hudCam];
									noteSplash.shader = newShader.shader;
									newShader.hue = colors[note.noteID % keyCount][0] / 360;
									newShader.saturation = colors[note.noteID % keyCount][1] / 100;
									newShader.brightness = colors[note.noteID % keyCount][2] / 100;
									add(noteSplash);
								}
						}
					}
					else
					{
						hits += 1;
						funnyHitStuffsLmao += 1;
						totalNoteStuffs++;
						score += 25;
					}

					playerStrumArrows.members[note.noteID].playAnim("confirm", true);

					shaderArray[(note.noteID % keyCount) + keyCount].hue = colors[note.noteID % keyCount][0] / 360;
					shaderArray[(note.noteID % keyCount) + keyCount].saturation = colors[note.noteID % keyCount][1] / 100;
					shaderArray[(note.noteID % keyCount) + keyCount].brightness = colors[note.noteID % keyCount][2] / 100;

					if(vocals != null)
						vocals.volume = 1;

					dontHitTheseDirectionsLol[note.noteID] = true;

					if(player != null && player.active)
					{
						for(char in player.members)
						{
							char.holdTimer = 0;
							char.playAnim(singAnims[note.noteID % 4], true);
						}
					}

					pressed[note.noteID] = true;

					if(!note.isSustainNote)
					{
						for(i in 0...comboArray.length) {
							if(combo >= 10 || combo == 0) {
								comboGroup.members[i].loadCombo(comboArray[i], curUISkin, pixelStage);
								comboGroup.members[i].tweenSprite();
							}
						}

						combo += 1;

						var theReal:Array<Dynamic> = menus.HitsoundMenu.getHitsounds();
						if(theReal[Options.getData('hitsound')].name != "None")
							playCurrentHitsound();

						if(combo > 9999)
							combo = 9999; // you should never be able to get a combo this high, if you do, you're nuts.
					}

					if(!note.isSustainNote)
						executeALuaState('playerOneSing', [Math.abs(note.noteID), Conductor.songPosition]);

					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();

					totalNoteStuffs++;
				}
			}

			if(possibleNotes.length > 0)
			{
				for(i in 0...possibleNotes.length)
				{
					var note = possibleNotes[i];

					if(note.strum == noteDataTimes[note.noteID] && dontHitTheseDirectionsLol[note.noteID])
					{
						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}

		for(i in 0...justPressed.length)
		{
			if(justPressed[i])
			{
				if(!Options.getData('ghost-tapping') && !dontHitTheseDirectionsLol[i]) 
				{
					changeHealth(false);
		
					if(player != null && player.active)
					{
						for(char in player.members)
						{
							char.holdTimer = 0;
							char.playAnim(singAnims[i] + "miss", true);
						}
					}

					FlxG.random.getObject(missSounds).play(true);
		
					score -= 10;
					misses += 1;
					totalNoteStuffs++;
				}
			}
		}

		for(note in notes)
		{
			if(note != null)
			{
				if(note.isSustainNote && note.mustPress)
				{
					if(pressed[note.noteID] && Conductor.songPosition >= (!note.isSustainNote ? note.strum : note.strum - 1))
					{
						hits += 1;
						funnyHitStuffsLmao += 1;
						totalNoteStuffs++;
						score += 25;

						changeHealth(true);

						if(player != null && player.active)
						{
							for(char in player.members)
							{
								char.holdTimer = 0;
								char.playAnim(singAnims[note.noteID % 4], true);
							}
						}

						playerStrumArrows.members[note.noteID].playAnim("confirm", true);

						shaderArray[(note.noteID % keyCount) + keyCount].hue = colors[note.noteID % keyCount][0] / 360;
						shaderArray[(note.noteID % keyCount) + keyCount].saturation = colors[note.noteID % keyCount][1] / 100;
						shaderArray[(note.noteID % keyCount) + keyCount].brightness = colors[note.noteID % keyCount][2] / 100;

						if(Options.getData('hitsounds-hold'))
						{
							var theReal:Array<Dynamic> = menus.HitsoundMenu.getHitsounds();
							if(theReal[Options.getData('hitsound')].name != "None")
								playCurrentHitsound();
						}

						if(combo > 9999)
							combo = 9999; // you should never be able to get a combo this high, if you do, you're nuts.

						if(note.isSustainNote)
							executeALuaState('playerOneSingHeld', [Math.abs(note.noteID), Conductor.songPosition]);

						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}

		if(player != null)
		{
			for(char in player.members)
			{
				if(char != null && char.active && (char.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !pressed.contains(true)))
				{
					if(char.animation.curAnim.name.startsWith('sing'))
						char.dance();
				}
			}
		}
	}

	var hitsoundList:Array<Dynamic> = menus.HitsoundMenu.getHitsounds();

	function playCurrentHitsound(?volume:Float = 1)
	{
		var hitSound:FlxSound;

		hitSound = FlxG.sound.load(Util.getSound('gameplay/hitsounds/${hitsoundList[Options.getData('hitsound')].fileName}'), volume);

		hitSound.play(true);
	}

	function updateAccuracyStuff()
	{
		if(hits > 0)
		{
			if(Options.getData('botplay') || rating1 == "N/A")
				accuracyNum == 100;
			
			if(accuracyNum == 100)
				rating1 = letterRatings[0];
			
			else if(accuracyNum >= 90)	
				rating1 = letterRatings[1];

			else if(accuracyNum >= 80)	
				rating1 = letterRatings[2];

			else if(accuracyNum >= 70)	
				rating1 = letterRatings[3];

			else if(accuracyNum >= 60)	
				rating1 = letterRatings[4];

			else if(accuracyNum >= 50)	
				rating1 = letterRatings[5];

			else if(accuracyNum >= 40)	
				rating1 = letterRatings[6];

			else if(accuracyNum >= 30)	
				rating1 = letterRatings[7];

			else if(accuracyNum >= 20)	
				rating1 = letterRatings[8];

			rating2 = swagRatings[0]; // just in case the shit below doesn't work
			if (misses == 0 && goods == 0 && bads == 0 && shits == 0)
			{
				rating2 = swagRatings[4];
				scoreBar.color = 0xFF4895fa;
			}
			else if (misses == 0 && goods >= 1 && bads == 0 && shits == 0)
			{
				rating2 = swagRatings[3];
				scoreBar.color = 0xFF48fa72;
			}
			else if (misses == 0)
			{
				rating2 = swagRatings[2];
				scoreBar.color = 0xFFfa9e48;
			}
			else if (misses < 10)
			{
				rating2 = swagRatings[1];
				scoreBar.color = 0xFFfa485a;
			}
			else
			{
				rating2 = swagRatings[0];
				scoreBar.color = 0xFF9e9697;
			}
		}
	}

	function processAchievements()
	{ // TODO: add shit to make custom achievements a thing
		fromAch = true;

		var listOfNewAchievements:Array<String> = [];

		// add achievements here
		if(storedSong == "tutorial" && storyMode)
		{
			if(getAchievement("tutorial") == true)
				listOfNewAchievements.push("tutorial");
		}
		// don't modify shit below

		if(FlxG.sound.music != null)
			FlxG.sound.music.pause();

		if(vocals != null)
			vocals.pause();

		persistentUpdate = false;

		paused = true;

		if(TitleScreenState.optionsInitialized)
			Controls.refreshControls();

		Controls.accept = false;

		openSubState(new AchievementThing(listOfNewAchievements));
	}

	function getAchievement(achievement:String):Bool
	{
		var funnyList:Array<String> = Options.getData("achievements");

		if(!funnyList.contains(achievement))
		{
			funnyList.push(achievement);
			Options.saveData("achievements", funnyList);

			return true;
		}

		Options.saveData("achievements", funnyList);

		return false;
	}

	var trainMoving:Bool = false;
	var trainCars:Int = 0;
	var trainFinishing:Bool = false;
	var startedMoving:Bool = false;
	var trainSound:FlxSound;
	var trainCooldown:Int = 0;
	var trainFrameTiming:Float = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700 && !Options.getData('optimization'))
		{
			startedMoving = true;
			for(char in speakers.members)
			{
				char.playAnim('hairBlow');
			}
		}

		if (startedMoving && !Options.getData('optimization'))
		{
			stage.members[8].x -= 400;

			if (stage.members[8].x < -2000 && !trainFinishing)
			{
				stage.members[8].x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (stage.members[8].x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(!Options.getData('optimization')) {
			for(char in speakers.members)
			{
				char.playAnim('hairFall');
			}
			
			stage.members[8].x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function executeALuaState(name:String, arguments:Array<Dynamic>, ?execute_on:Execute_On = BOTH, ?stage_arguments:Array<Dynamic>)
	{
		if(!Options.getData('optimization'))
		{
			if(stage_arguments == null)
				stage_arguments = arguments;

			#if linc_luajit
			if(executeModchart && luaModchart != null && execute_on != STAGE)
				luaModchart.executeState(name, arguments);

			if(stage != null)
			{
				if(stage.stageScript != null && execute_on != MODCHART)
					stage.stageScript.executeState(name, stage_arguments);
			}
			#end
		}
	}

	function setLuaVar(name:String, data:Dynamic, ?execute_on:Execute_On = BOTH, ?stage_data:Dynamic)
	{
		if(!Options.getData('optimization'))
		{
			if(stage_data == null)
				stage_data = data;

			#if linc_luajit
			if(executeModchart && luaModchart != null && execute_on != STAGE)
				luaModchart.setVar(name, data);

			if(stage != null)
			{
				if(stage.stageScript != null && execute_on != MODCHART)
					stage.stageScript.setVar(name, stage_data);
			}
			#end
		}
	}

	function getLuaVar(name:String, type:String):Dynamic
	{
		if(!Options.getData('optimization'))
		{
			#if linc_luajit
			var luaVar:Dynamic = null;

			// we prioritize modchart cuz frick you
			
			if(stage != null)
			{
				if(stage.stageScript != null)
				{
					var newLuaVar = stage.stageScript.getVar(name, type);

					if(newLuaVar != null)
						luaVar = newLuaVar;
				}
			}

			if(executeModchart && luaModchart != null)
			{
				var newLuaVar = luaModchart.getVar(name, type);

				if(newLuaVar != null)
					luaVar = newLuaVar;
			}

			if(luaVar != null)
				return luaVar;
			#end

			return null;
		}
		else
		{
			return null;
		}
	}
}

enum Execute_On
{
	BOTH;
	MODCHART;
	STAGE;
}