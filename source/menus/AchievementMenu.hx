package menus;

import ui.AchievementIcon;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.system.FlxSound;
import lime.utils.Assets;
import mods.Mods;
import flixel.text.FlxText;
import ui.Icon;
import ui.AlphabetText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import DiscordRPC;

using StringTools;

class AchievementMenu extends BasicState
{
    var achievements:Array<Achievement> = [];

    static var selectedSong:Int = 0;

    var bg:FlxSprite;

    var songAlphabets:FlxTypedGroup<AlphabetText> = new FlxTypedGroup<AlphabetText>();
    var songIcons:FlxTypedGroup<AchievementIcon> = new FlxTypedGroup<AchievementIcon>();
    var descriptions:Array<String> = [];

    var up = false;
    var down = false;
    var left = false;
    var leftP = false;
    var right = false;
    var rightP = false;
    var shiftP = false;
    var reset = false;

    var descriptionText:FlxText;
    
    public function new()
    {
        super();

        Util.clearMemoryStuff();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

        //curSpeed = 1;

        var rawSongListData:AchievementList = Util.getJsonContents(Util.getJsonPath("data/achievementList"));
        var achievementListData:Array<Achievement> = rawSongListData.achievements;

        #if sys
        Mods.updateActiveMods();
        
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/achievementList.json'))
                {
                    var coolData:AchievementList = Util.getJsonContents('mods/$mod/data/achievementList.json');

                    for(achievement in coolData.achievements)
                    {
                        achievementListData.push(achievement);
                    }
                }
            }
        }
        #end

        achievements = achievementListData;

        bg = new FlxSprite().loadGraphic(Util.getImage("menuDesat"));
		
		add(bg);

        add(songAlphabets);
        add(songIcons);

        for(achievementDataIndex in 0...achievements.length)
        {
            var achievementData = achievements[achievementDataIndex];

            var alphabet = new AlphabetText(0, (70 * achievementDataIndex) + 30, achievementData.name);
            alphabet.targetY = achievementDataIndex;
            alphabet.isMenuItem = true;
            alphabet.x += 200;
            alphabet.xAdd = 150;
            //alphabet.yMult = 140;

            songAlphabets.add(alphabet);

            var icon = new AchievementIcon("achievements/images/" + achievementData.file_name + "-achievement", alphabet, null, null, LEFT);
            songIcons.add(icon);

            descriptions.push(achievementData.description);
        }

        var stupidBox = new FlxSprite(0, FlxG.height * 0.85).makeGraphic(FlxG.width, 300, FlxColor.BLACK);
		stupidBox.alpha = 0.6;
		add(stupidBox);

        descriptionText = new FlxText(0, FlxG.height * 0.9, 0, "Haha funny test", 24);
        descriptionText.font = Util.getFont('vcr');
		descriptionText.color = FlxColor.WHITE;
		descriptionText.borderColor = FlxColor.BLACK;
		descriptionText.borderSize = 2;
		descriptionText.borderStyle = OUTLINE;
		descriptionText.alignment = CENTER;
        descriptionText.y = (stupidBox.y + 75) - descriptionText.height;
        descriptionText.screenCenter(X);
		add(descriptionText);

        updateSelection();

        BasicState.changeAppTitle(Util.engineName, "Achievement Menu");
    }

    override public function create()
    {
        super.create();

        #if discord_rpc
        DiscordRPC.changePresence("In Freeplay", null);
        #end
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.back)
        {
            FlxG.sound.play(Util.getSound("menus/cancelMenu", true));
            transitionState(new menus.MainMenuState());
        }

        up = Controls.UI_UP;
        down = Controls.UI_DOWN;
        left = Controls.UI_LEFT;
        leftP = Controls.UI_LEFT_P;
        right = Controls.UI_RIGHT;
        rightP = Controls.UI_RIGHT_P;
        shiftP = Controls.shiftP;
        reset = Controls.reset;

        if(FlxG.keys.justPressed.SPACE)
        {
            var funnyList:Array<String> = Options.getData("achievements");

            if(funnyList.contains(achievements[selectedSong].file_name))
                funnyList.remove(achievements[selectedSong].file_name);
            else
                funnyList.push(achievements[selectedSong].file_name);

            Options.saveData("achievements", funnyList);

            updateSelection();
        }

        if(up || down)
        {
            if(up)
                selectedSong -= 1;
    
            if(down)
                selectedSong += 1;
            
            updateSelection();
        }

		if (-1 * Math.floor(FlxG.mouse.wheel) != 0)
        {
            selectedSong += -1 * Math.floor(FlxG.mouse.wheel);
			updateSelection();
        }
    }

    function updateSelection()
    {
        if(selectedSong < 0)
            selectedSong = achievements.length - 1;

        if(selectedSong > achievements.length - 1)
            selectedSong = 0;

        if(songIcons.members.length > 0)
        {
            for (i in 0...songIcons.members.length)
            {
                songIcons.members[i].alpha = 0.6;
            }
    
            songIcons.members[selectedSong].alpha = 1;
        }

        for(itemIndex in 0...songAlphabets.members.length)
        {
            var item = songAlphabets.members[itemIndex];

            item.targetY = itemIndex - selectedSong;

            item.alpha = 0.6;

            if (item.targetY == 0)
                item.alpha = 1;
        }

        var funnyList:Array<String> = Options.getData("achievements");

        if(funnyList.contains(achievements[selectedSong].file_name))
            bg.color = 0xFF60CCFF;
        else
            bg.color = 0xFF545454;

        descriptionText.text = descriptions[selectedSong];
        descriptionText.screenCenter(X);

        FlxG.sound.play(Util.getSound('menus/scrollMenu'));
    }
}

typedef AchievementList =
{
    var achievements:Array<Achievement>;
}

typedef Achievement =
{
    var file_name:String;
    var name:String;
    var description:String;

    // add more shit here for custom stuff in future
}