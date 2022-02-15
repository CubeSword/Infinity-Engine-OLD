package;

import flixel.FlxG;

class Options
{
    static var defaultData:DefaultOptionsData;

    public static var altBinds:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    public static var mainBinds:Array<String> = ["A", "S", "W", "D"];

    public static function init()
    {
        FlxG.save.bind("infinity-engine", "infinity-team");

        defaultData = Util.getJsonContents('assets/data/defaultData.json');

        for(data in defaultData.dataObjects)
        {
            if(getData(data.name) == null)
                saveData(data.name, data.value);
        }
    }

    public static function saveData(save:String, value:Dynamic)
    {
        Reflect.setProperty(FlxG.save.data, save, value);
        FlxG.save.flush();
    }

    public static function getData(save:String):Dynamic
    {
        return Reflect.getProperty(FlxG.save.data, save);
    }

    public static function resetData()
    {
        FlxG.save.erase();

        init();
    }
}

typedef DefaultOptionsData = {
    var dataObjects:Array<DefaultOptionData>;
} 

typedef DefaultOptionData = {
    var name:String;
    var value:Dynamic;
}