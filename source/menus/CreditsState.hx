package menus;

import ui.Icon;
import ui.TrackerSprite;
import ui.AlphabetText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;

class CreditsState extends BasicState
{
    var menuBG:FlxSprite;
    var description:FlxText;
    var curSelected:Int;
    var credits:Array<Dynamic>;
    var creditGroup:FlxTypedGroup<AlphabetText>;
    var creditIconGroup:FlxTypedGroup<TrackerSprite>;
    var colorTween:FlxTween;

    var selectedColor:Int = 0xFFFFFFFF;

	override public function create()
    {
        super.create();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        FlxTransitionableState.skipNextTransIn = false;
        FlxTransitionableState.skipNextTransOut = false;

        creditGroup = new FlxTypedGroup();
        creditIconGroup = new FlxTypedGroup();
        curSelected = 0;

        menuBG = new FlxSprite(-80).loadGraphic(Util.getImage('menuDesat', true, "Base Game"));
        menuBG.scrollFactor.x = 0;
        menuBG.scrollFactor.y = 0.18;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.175));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;

        curSelected = 0;
        add(menuBG);

        var json:Dynamic = Util.getJsonContents('assets/credits/credits.json');
        credits = json.credTextShit;

        selectedColor = Std.int(credits[curSelected].color);
        menuBG.color = selectedColor;

        for (i in 0...credits.length) {
            var text = new AlphabetText(FlxG.width / 6 + i * 5, 100 + i * 150, credits[i].name);
            text.ID = i;
            add(text);
            creditGroup.add(text);

            var icon = new TrackerSprite(creditGroup.members[i], 10, -30, LEFT);
            icon.ID = i;
            icon.loadGraphic(Util.getImage('credits/icons/' + credits[i].icon, false));
            add(icon);
            creditIconGroup.add(icon);
        }

        add(description);
        updateDesc(0);

        #if discord_rpc
        DiscordRPC.changePresence("In Credits", null);
        #end

        BasicState.changeAppTitle(Util.engineName, "Credits Menu");
    }

    override public function update(elapsed:Float)
    {
        if (Controls.back)
        {
            FlxG.sound.play(Util.getSound("menus/cancelMenu", true));
            FlxG.switchState(new menus.MainMenuState());
        }

        if(Controls.accept)
            Util.openURL(credits[curSelected].link);

        if(Controls.UI_DOWN)
            changeSelection(1);

        if(Controls.UI_UP)
            changeSelection(-1);
    
        updateDesc(elapsed);
        super.update(elapsed);
    }

    function updateDesc(elapsed:Float) {
        var funnyLerpValue = 0.08 / (Main.display.currentFPS / 60);

        for(credit in 0...creditGroup.members.length) {
            if(credit == curSelected)
            {
                creditGroup.members[credit].x = FlxMath.lerp(creditGroup.members[credit].x, FlxG.width / 6 + credit * 5 + 96, funnyLerpValue);
                creditGroup.members[credit].alpha = 1;
                creditIconGroup.members[credit].alpha = 1;
            }
            else
            {
                creditGroup.members[credit].x = FlxMath.lerp(creditGroup.members[credit].x, FlxG.width / 6 + credit * 5, funnyLerpValue);
                creditGroup.members[credit].alpha = 0.6;
                creditIconGroup.members[credit].alpha = 0.6;
            }
        }

        if(credits[curSelected].desc != null)
        { 
            if(description != null) // cleanup stuff
            {
                remove(description);
                description.kill();
                description.destroy();
            }

            description = new FlxText(0,0,FlxG.width,credits[curSelected].desc, 64, true);
            description.setFormat(Util.getFont('funkin'), 64, FlxColor.BLACK, RIGHT);
            description.y = FlxG.height - description.height - 30;
            add(description);
        }
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if(curSelected < 0)
            curSelected = credits.length - 1;

        if(curSelected > credits.length - 1)
            curSelected = 0;

        var newColor:FlxColor = Std.int(credits[curSelected].color);

        if(newColor != selectedColor) {
            if(colorTween != null) {
                colorTween.cancel();
            }

            selectedColor = newColor;

            colorTween = FlxTween.color(menuBG, 0.4, menuBG.color, selectedColor, {
                onComplete: function(twn:FlxTween) {
                    colorTween = null;
                }
            });
        }

        FlxG.sound.play(Util.getSound('menus/scrollMenu'));
    }
}
