package menus;

import lime.app.Application;
import flixel.FlxBasic;
import flixel.FlxSubState;
import flixel.text.FlxText;
import ui.AlphabetText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

class ReplayMenuState extends BasicState
{
	var menuBG:FlxSprite;
	var menuColor:Int = 0xFFf542d7;
	var noReplaysText:FlxText;

    override public function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

        menuBG = new FlxSprite().loadGraphic(Util.getImage("menuDesat"));
		menuBG.color = menuColor;
		add(menuBG);

		noReplaysText = new FlxText(0, 0, 0, "You have no replays!", 48);
		noReplaysText.setFormat(Util.getFont('vcr'), 48, FlxColor.WHITE);
		noReplaysText.borderStyle = OUTLINE;
		noReplaysText.borderColor = FlxColor.BLACK;
		noReplaysText.borderSize = 3;
		noReplaysText.screenCenter();
		add(noReplaysText);

		BasicState.changeAppTitle(Util.engineName, "Replays Menu");
		
		super.create();

        #if discord_rpc
        DiscordRPC.changePresence("In Replays Menu", null);
        #end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var up = Controls.UI_UP;
		var down = Controls.UI_DOWN;
		var accept = Controls.accept;

		if(Controls.back)
		{
			FlxG.sound.play(Util.getSound("menus/cancelMenu", true));
			transitionState(new MainMenuState());
		}
	}
}
