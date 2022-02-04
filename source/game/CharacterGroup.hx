package game;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import mods.Mods;
import openfl.Assets;
import flixel.FlxSprite;

using StringTools;

// i was gonna do this in Character.hx but that's actually dumb as all hell so what if n o

class CharacterGroup extends FlxTypedGroup<Character> {
    var charArray:Array<String> = [];
    var json:Dynamic;

    public var char:Character;

    public function new(?x:Float = 0, ?y:Float = 0, character:String = "bf")
    {
        super();
        loadCharacter(x, y, character);
    }

    public function loadCharacter(?x:Float = 0, ?y:Float = 0, character:String = "bf")
    {
        for(char in members)
        {
            char.kill();
            char.destroy();
        }
        
        clear();
        // remove existing chars so they don't stack lol

        char = new Character(0, 0, character);
        
        json = Util.getJsonContents('assets/characters/placeholder.json');

        var balls:Bool = false;

        if(Assets.exists('assets/characters/$character.json'))
            balls = true;
        #if sys
        else
        {
            if(Mods.activeMods.length > 0)
            {
                for(mod in Mods.activeMods)
                {
                    if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$character.json'))
                    {
                        balls = true;
                    }
                }
            }
        }
        #end

        if(balls)
        {
            #if sys
            if(Assets.exists('assets/characters/$character.json'))
            #end
                json = Util.getJsonContents('assets/characters/$character.json');
            #if sys
            else
            {
                if(Mods.activeMods.length > 0)
                {
                    for(mod in Mods.activeMods)
                    {
                        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$character.json'))
                        {
                            json = Util.getJsonContents('mods/$mod/characters/$character.json');
                        }
                    }
                }
            }
            #end
        }
        // get character json to load multiple characters

        var characters:Array<String> = []; 
        if(json.characters != null)
            characters = json.characters;
        else
            characters = [character];
        // grab characters from characters array if it exists, if it doesn't exist it will load one character instead

        for(char in characters)
        {
            var swagChar:Character = new Character(x, y, char);
            add(swagChar);
        }
        // load each character
    }
}