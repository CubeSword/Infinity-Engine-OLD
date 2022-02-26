package mods;

import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import menus.MainMenuState;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import mods.Mods.ModInfo;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class ModsState extends BasicState
{
    var menuBG:FlxSprite;
    var menuColor:Int = 0xFF4359A8;

    var modGroup:FlxTypedGroup<ModGroup> = new FlxTypedGroup<ModGroup>();

    var curSelected:Int = 0;

    var camFollow:FlxObject;

    override public function create()
    {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;
        
        FlxG.camera.scroll.set();
		FlxG.camera.target = null;

        menuBG = new FlxSprite().loadGraphic(Util.getImage("menuDesat", true, "Base Game"));
		menuBG.color = menuColor;
        menuBG.scrollFactor.set();
		add(menuBG);

        add(modGroup);

        Mods.getAllMods();
        
        if(Mods.mods.length < 1) // lmao get outta there
            transitionState(new MainMenuState());
        
        for(modIndex in 0...Mods.mods.length)
        {
            var mod = Mods.mods[modIndex];

            var funnyGroup = new ModGroup(0, 100 + (250 * modIndex), mod);
            funnyGroup.screenCenter(X);

            modGroup.add(funnyGroup);
        }

        camFollow = new FlxObject(0, 100, 1, 1);
        camFollow.screenCenter(X);
        add(camFollow);

        FlxG.camera.follow(camFollow, LOCKON, 0.1 * (60 / Main.display.currentFPS));

        updateMods();

        BasicState.changeAppTitle(Util.engineName, "Mods Menu");

        super.create();

        #if discord_rpc
        DiscordRPC.changePresence("In Mods Menu", null);
        #end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        FlxG.camera.followLerp = 0.1 * (60 / Main.display.currentFPS);

        var up = Controls.UI_UP;
        var down = Controls.UI_DOWN;
        var accept = Controls.accept;

        if(up || down)
        {
            if(up)
                curSelected -= 1;

            if(down)
                curSelected += 1;

            if(curSelected < 0)
                curSelected = Mods.mods.length - 1;

            if(curSelected > Mods.mods.length - 1)
                curSelected = 0;

            updateMods();

            FlxG.sound.play('assets/sounds/menus/scrollMenu' + Util.soundExt);
        }

        if(accept)
        {
            var modName = Mods.mods[curSelected][0];
            Mods.setModActive(modName, !Mods.getModActive(modName));

            updateMods();
        }

        if(Controls.back)
        {
            FlxG.sound.play(Util.getSound("menus/cancelMenu", true));
            transitionState(new MainMenuState());
        }
    }

    function updateMods()
    {
        for(modIndex in 0...modGroup.members.length)
        {
            var mod = modGroup.members[modIndex];

            if(modIndex == curSelected)
            {
                mod.alpha = 1;
                camFollow.setPosition(camFollow.x, mod.getGraphicMidpoint().y + 200);
            }
            else
                mod.alpha = 0.6;
        }

        for(selected in 0...Mods.mods.length)
        {
            var modName = Mods.mods[selected][0];

            modGroup.members[selected].funnyIndicator.text = Mods.getModActive(modName) == false ? "[ OFF ]" : "[ ON  ]";
            modGroup.members[selected].funnyIndicator.color = Mods.getModActive(modName) == false ? FlxColor.RED : FlxColor.LIME;
        }
    }
}

class ModGroup extends FlxSpriteGroup
{
    public var tracker:FlxObject;
    public var funnyIndicator:FlxText;

    public function new(x:Float = 0, y:Float = 0, mod:Array<Dynamic>)
    {
        super(x, y);

        tracker = new FlxObject(x,y,1,1);

        var bg:FlxSprite = new FlxSprite(0,0);
        bg.makeGraphic(615, 200, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        var funnyData:ModInfo = Util.getJsonContents("mods/" + mod[0] + "/_mod_info.json");

        var modName:FlxText = new FlxText(5, 5, 450, funnyData.name, 24);
        modName.font = "assets/fonts/vcr.ttf";
        modName.borderStyle = OUTLINE;
        modName.borderSize = 3;
        modName.borderColor = FlxColor.BLACK;
        modName.wordWrap = false;
        add(modName);

        var modDescription:FlxText = new FlxText(modName.x, 33, 450, funnyData.description, 24);
        modDescription.font = "assets/fonts/vcr.ttf";
        modDescription.borderStyle = OUTLINE;
        modDescription.borderSize = 2;
        modDescription.borderColor = FlxColor.BLACK;
        add(modDescription);

        var modAuthor:FlxText = new FlxText(610, 195, 0, "By: " + funnyData.author, 16);
        modAuthor.font = "assets/fonts/vcr.ttf";
        modAuthor.borderStyle = OUTLINE;
        modAuthor.borderSize = 1.5;
        modAuthor.borderColor = FlxColor.BLACK;
        modAuthor.x -= modAuthor.width;
        modAuthor.y -= modAuthor.height;
        add(modAuthor);

        var funnySprite:FlxSprite = new FlxSprite(460, 5);
        
        #if sys
        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/${mod[0]}/_mod_icon.png'))
        {
            var bitmapData:BitmapData = BitmapData.fromFile(Sys.getCwd() + 'mods/${mod[0]}/_mod_icon.png');

            funnySprite.loadGraphic(bitmapData, false, 0, 0, false, 'mods/${mod[0]}/_mod_icon.png');
            funnySprite.setGraphicSize(150, 150);
        }
        else
        {
        #end
        funnySprite.makeGraphic(150, 150, FlxColor.GRAY);
        #if sys
        }
        #end

        funnySprite.updateHitbox();

        add(funnySprite);

        funnyIndicator = new FlxText(5, 195, 0, Mods.getModActive(mod[0]) == false ? "[ OFF ]" : "[ ON  ]", 16);
        funnyIndicator.font = "assets/fonts/vcr.ttf";
        funnyIndicator.borderStyle = OUTLINE;
        funnyIndicator.borderSize = 1.5;
        funnyIndicator.borderColor = FlxColor.BLACK;
        funnyIndicator.y -= funnyIndicator.height;
        funnyIndicator.color = Mods.getModActive(mod[0]) == false ? FlxColor.RED : FlxColor.LIME;
        add(funnyIndicator);
    }
}