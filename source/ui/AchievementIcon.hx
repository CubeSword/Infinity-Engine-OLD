package ui;

import flixel.graphics.FlxGraphic;
import ui.TrackerSprite;
import flixel.FlxSprite;

class AchievementIcon extends TrackerSprite
{
    public function new(?achievementPath:String = "tutorial", ?tracker:FlxSprite, ?xOff:Float = 10, ?yOff:Float = -30, ?direction:TrackerDirection = RIGHT)
    {
        super(tracker, xOff, yOff, direction);

        if(!Std.isOfType(Util.getImage(achievementPath, false), FlxGraphic))
        {
            trace("Oops! Looks like the icon you tried to load: " + achievementPath + " doesn't exist.");
            achievementPath = "achievements/images/placeholder-bg";
        }

        loadGraphic(Util.getImage(achievementPath, false));
        setGraphicSize(120, 120);
    }
}