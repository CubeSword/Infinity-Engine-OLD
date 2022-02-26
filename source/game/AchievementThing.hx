package game;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import game.Achievements;
import game.PlayState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import ui.AchievementIcon;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import mods.Mods;
import flixel.FlxSprite;

class AchievementThing extends FlxSpriteGroup
{
    public var achievementsGotten:Array<Achievement> = [];

    var box:FlxSprite;
    var icon:FlxSprite;

    var title:FlxText;
    var desc:FlxText;

    override public function new(ag:Array<Achievement>, camera:FlxCamera)
    {
        super();
        this.achievementsGotten = ag;

        if(achievementsGotten.length > 0)
        {
            FlxG.sound.play(Util.getSound('menus/confirmMenu'));

            this.cameras = [camera];

            box = new FlxSprite(10, 10).makeGraphic(1000, 100, FlxColor.BLACK);
            add(box);

            var realIcon = achievementsGotten[0].fileName;
            var achievementPath = 'achievements/images/$realIcon-achievement';
            
            if(!Std.isOfType(Util.getImage(achievementPath, false), FlxGraphic))
            {
                trace("Oops! Looks like the icon you tried to load: " + achievementPath + " doesn't exist.");
                achievementPath = "achievements/images/placeholder-bg";
            }

            icon = new FlxSprite(box.x, box.y).loadGraphic(Util.getImage(achievementPath, false));
            icon.setGraphicSize(Std.int(box.height), Std.int(box.height));
            icon.updateHitbox();
            add(icon);

            title = new FlxText(icon.x + (box.height + 20), box.y + 10, 0, achievementsGotten[0].title, 24);
            title.setFormat(Util.getFont('vcr'), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
            title.borderSize = 2;
            add(title);

            desc = new FlxText(title.x, title.y + 25, 0, achievementsGotten[0].description, 18);
            desc.setFormat(Util.getFont('vcr'), 18, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
            desc.borderSize = 2;
            add(desc);

            doTimer();
        }
        else
        {
            die();
        }
    }

    public function refresh()
    {
        achievementsGotten.remove(achievementsGotten[0]);

        if(achievementsGotten.length > 0)
        {
            FlxG.sound.play(Util.getSound('menus/confirmMenu'));
            this.alpha = 1;
            title.text = achievementsGotten[0].title;
            desc.text = achievementsGotten[0].description;

            var realIcon = achievementsGotten[0].fileName;
            icon.loadGraphic(Util.getImage('achievments/images/$realIcon-achievement'));
            icon.setGraphicSize(Std.int(box.height), Std.int(box.height));
            icon.updateHitbox();
        }
    }

    public function die()
    {
        PlayState.instance.achievementActive = false;
        PlayState.instance.canEndSong = true;

        FlxG.state.remove(this);
        this.kill();
        this.destroy();
    }

    function doTimer()
    {
        if(achievementsGotten.length < 1)
            die();
        else
        {
            FlxTween.tween(this, {alpha: 0}, 1, {
                ease: FlxEase.cubeInOut,
                startDelay: 3,
                onComplete: function(twn:FlxTween)
                {
                    refresh();
                    doTimer();
                }
            });
        }
    }
}