package game;

import mods.Mods;

#if achievements_allowed
typedef Achievement =
{
    var fileName:String;
    var title:String;
    var description:String;

    // add more shit here for custom stuff in future
}

typedef AchievementList =
{
    var achievements:Array<Achievement>;
}

class Achievements
{
    static public var achievements:Array<Achievement> = [];

    static public function getAchievements():Array<Achievement>
    {
        achievements = [];

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
        return achievements;
    }
}
#end