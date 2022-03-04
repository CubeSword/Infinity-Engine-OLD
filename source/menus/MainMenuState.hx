package menus;

import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class MainMenuState extends BasicState
{
	var mouseOverlapped = false;
	var mouseOverlappedBefore = false;

	var hasSelected:Bool = false;

	var menuBG:FlxSprite;
	var menuBGMagenta:FlxSprite;
	
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var selectedMenu:Int = 0;
	var menuButtons:FlxTypedGroup<FlxSprite>;
	
	var swagMenuButtons:Array<String> = ['StoryMode', 'Freeplay', 'Credits', 'Options', 'Mods', 'Achievements', 'Replays'];

	var menuWatermarks:Array<String> = []; // because you can't access variables in variable initialization
	var menuWatermarksText:FlxTypedGroup<FlxText>;

	var engineVersion:String;

	override public function create()
	{
		menuWatermarks = [
			'Press SHIFT+C to see the changelog for this version!',
			#if debug
			Util.engineName + ' v' + Util.engineVersion + ' (DEBUG)',
			#else
			Util.engineName + ' Release v' + Util.engineVersion,
			#end
		];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		persistentUpdate = persistentDraw = true;

		TitleScreenState.hasAlreadyAccepted = true;
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		menuBG = new FlxSprite(-80).loadGraphic(Util.getImage('menuBG', true, "Base Game"));
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.18;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.375));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = Options.getData('anti-aliasing');
		add(menuBG);

		menuBGMagenta = new FlxSprite(-80).loadGraphic(Util.getImage('menuDesat', true, "Base Game"));
		menuBGMagenta.scrollFactor.x = 0;
		menuBGMagenta.scrollFactor.y = 0.18;
		menuBGMagenta.setGraphicSize(Std.int(menuBGMagenta.width * 1.375));
		menuBGMagenta.updateHitbox();
		menuBGMagenta.screenCenter();
		menuBGMagenta.visible = false;
		menuBGMagenta.antialiasing = Options.getData('anti-aliasing');
		menuBGMagenta.color = 0xFFfd719b;
		add(menuBGMagenta);

		menuButtons = new FlxTypedGroup<FlxSprite>();
		add(menuButtons);

		menuWatermarksText = new FlxTypedGroup<FlxText>();
		add(menuWatermarksText);

		for (i in 0...swagMenuButtons.length)
		{
			var coolLength = swagMenuButtons.length;
			var menuButton:FlxSprite = new FlxSprite(0, (i * 160) + 80);
			menuButton.frames = Util.getSparrow('mainmenu/' + swagMenuButtons[i]);
			menuButton.animation.addByPrefix('super idle', "basic", 24);
			menuButton.animation.addByPrefix('selected', "white", 24);
			menuButton.animation.play('super idle');
			menuButton.ID = i;
			menuButton.screenCenter(X);
			menuButton.scrollFactor.set(0, swagMenuButtons.length / coolLength);
			menuButton.antialiasing = Options.getData('anti-aliasing');
			menuButtons.add(menuButton);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		
		FlxG.camera.follow(camFollowPos, null, 1);

		for(i in 0...menuWatermarks.length)
		{
			if(Options.getData('engine-watermarks'))
			{
				var watermark:FlxText = new FlxText(8, FlxG.height - (30 + i * 20), 0, menuWatermarks[i], 16);
				watermark.setFormat(Util.getFont('vcr'), 16, FlxColor.WHITE, LEFT);
				watermark.borderStyle = OUTLINE;
				watermark.borderSize = 1.5;
				watermark.borderColor = FlxColor.BLACK;
				watermark.scrollFactor.set();
				menuWatermarksText.add(watermark);	
			}
		}

		changeSelection();

		BasicState.changeAppTitle(Util.engineName, "Main Menu");
	
		super.create();

        #if discord_rpc
        DiscordRPC.changePresence("In Main Menu", null);
        #end

		engineVersion = Util.engineVersion.trim().replace('.', '');
		trace("ENGINE VERSION: " + engineVersion);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		
		for (i in 0...swagMenuButtons.length)
		{
			var btn:FlxSprite = menuButtons.members[i];
			btn.screenCenter(X);
		}

		if (Controls.UI_UP && !hasSelected)
			changeSelection(-1);
		
		if (Controls.UI_DOWN && !hasSelected)
			changeSelection(1);

		if (Controls.shiftP && FlxG.keys.justPressed.C)
			Util.openURL('https://github.com/CubeSword/Infinity-Engine/blob/main/changelogs/$engineVersion.md');

		if (FlxG.keys.justPressed.SEVEN)
		{
			transitionState(new OptionsState());
			OptionsState.optionsList = OptionsState.defaultOptionsList["tools"];
		}

		if (Controls.accept)
		{
			if(!hasSelected)
			{
				FlxG.sound.play(Util.getSound('menus/confirmMenu'));
				
				FlxFlicker.flicker(menuBGMagenta, 1.1, 0.15, false);

				menuButtons.forEach(function(spr:FlxSprite)
					{
						if (selectedMenu != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = swagMenuButtons[selectedMenu];

								switch (daChoice)
								{
									case 'StoryMode':
										transitionState(new menus.StoryModeState());
										trace("entered story mode menu");
										
									case 'Freeplay':
										transitionState(new menus.FreeplayMenuState());
										trace("entered freeplay menu");
										
									case 'Credits':
										transitionState(new menus.CreditsState());
										trace("entered credits menu");

									case 'Options':
										transitionState(new menus.OptionsState());
										trace("entered options menu");

									case 'Mods':
										transitionState(new mods.ModsState());
										trace("entered mods menu");

									case 'Replays':
										transitionState(new menus.ReplayMenuState());
										trace("entered replays menu");

									case 'Achievements':
										transitionState(new menus.AchievementMenu());
										trace("entered replays menu");
								}
							});
						}
					});
			}

			hasSelected = true;
		}
		
		if (Controls.back)
		{
			FlxG.sound.play(Util.getSound("menus/cancelMenu", true));
			transitionState(new TitleScreenState());
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0, ?playsound = true)
	{
		selectedMenu += change;

		if (selectedMenu < 0)
			selectedMenu = swagMenuButtons.length - 1;

		if (selectedMenu > swagMenuButtons.length - 1)
			selectedMenu = 0;

		for (i in 0...menuButtons.length)
		{
			var btn:FlxSprite = menuButtons.members[i];
			btn.animation.play('super idle');
			btn.offset.y = 0;
			btn.updateHitbox();

			if (btn.ID == selectedMenu)
			{
				btn.animation.play('selected');
				btn.offset.x = 0.15 * (btn.frameWidth / 2 + 180);
				btn.offset.y = 0.15 * btn.frameHeight;
				camFollow.setPosition(btn.getGraphicMidpoint().x, btn.getGraphicMidpoint().y);
			}
		}
		
		if (playsound)
			FlxG.sound.play('assets/sounds/menus/scrollMenu' + Util.soundExt);
	}
}
