package menus;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import ui.AchievementIcon;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import mods.Mods;
import menus.AchievementMenu;
import flixel.FlxSprite;

class AchievementThing extends BasicSubState
{
    var dumbTimer:Float = 0.0;
    var isFading:Bool = false;

    var tweenDuration:Float = 0.4;

    var achievementsGotten:Array<String>;

    var icon:AchievementIcon;
    var name:FlxText;
    var box:FlxSprite;

    public function new(ag:Array<String>)
    {
        achievementsGotten = ag;

        super();

        if(achievementsGotten.length > 0)
            FlxG.sound.play(Util.getSound("menus/confirmMenu"));

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

        for(achievementIndex in 0...achievementsGotten.length)
        {
            var achievement = achievementsGotten[achievementIndex];

            box = new FlxSprite(15, 15 + (80 * achievementIndex));
            box.scrollFactor.set();
            box.alpha = 0;
            add(box);

            FlxTween.tween(box, {alpha: 0.6}, tweenDuration, {ease: FlxEase.circOut});

            name = new FlxText(20, 20 + (80 * achievementIndex), 0, "test\nlolz", 18);
            name.font = Util.getFont('vcr');
            name.color = FlxColor.WHITE;
            name.borderColor = FlxColor.BLACK;
            name.borderSize = 1.5;
            name.borderStyle = OUTLINE;
            name.alignment = LEFT;
            name.scrollFactor.set();
            name.alpha = 0.6;
            add(name);

            FlxTween.tween(name, {alpha: 1}, tweenDuration, {ease: FlxEase.circOut});

            var achievementData:Achievement = achievementListData[0];

            for(achievementFun in achievementListData)
            {
                if(achievementFun.file_name == achievement)
                {
                    achievementData = achievementFun;
                    break;
                }
            }

            icon = new AchievementIcon("achievements/images/" + achievementData.file_name + "-achievement", null, null, null, LEFT);
            icon.x = 20;
            icon.y = 20 + (80 * achievementIndex);
            icon.alpha = 0;
            icon.scrollFactor.set();

            icon.setGraphicSize(110, 110);
            icon.updateHitbox();

            name.x = icon.x + icon.width + 2;
            name.y = icon.y;
            name.text = achievementData.name + "\n" + achievementData.description + "\n";

            box.makeGraphic(Std.int((name.x - 15) + name.width + 10), Std.int(icon.height + 30), FlxColor.BLACK);

            add(icon);

            FlxTween.tween(icon, {alpha: 1}, tweenDuration, {ease: FlxEase.circOut});
        }

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        dumbTimer += elapsed;

        if(dumbTimer >= 4)
        {
            if(!isFading)
            {
                FlxTween.tween(box, {alpha: 0}, tweenDuration, {ease: FlxEase.circOut});
                FlxTween.tween(name, {alpha: 0}, tweenDuration, {ease: FlxEase.circOut});
                FlxTween.tween(icon, {alpha: 0}, tweenDuration, {ease: FlxEase.circOut});
            }

            isFading = true;
        }

        if(dumbTimer > 5 || achievementsGotten.length < 1)
            close();
    }
}