package game;

import flixel.graphics.frames.FlxAtlasFrames;
import mods.Mods;
import openfl.Assets;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class Character extends FlxSprite {
    public var name = "bf";
    public var json:Dynamic;
    public var anims:Array<Dynamic> = [];
    public var offsetMap:Map<String, Array<Int>> = [];
    public var camOffsets:Array<Int> = [0,0];
    public var position:Array<Int> = [0,0];
    public var healthColor:Int = FlxColor.WHITE;
    public var bopLeftRight:Bool = false;
    public var bopDirection:Int = 0;
    public var singDuration:Float = 6.1;
    public var shouldDance:Bool = true;
    public var isPlayer:Bool = false;
    public var holdTimer:Float = 0;
    public var healthIcon:String = "bf";

    var isInCharEditor:Bool = false;

    public function new(x, y, ?name:String = "bf", ?isInCharEditor:Bool = false)
    {
        super(x, y);
        this.isInCharEditor = isInCharEditor;

        loadCharacter(name);
    }

    public function loadCharacter(swagName:String = "bf", ?resetAnims:Bool = false)
    {
        this.name = swagName;
        json = Util.getJsonContents('assets/characters/placeholder.json');

        //trace("!!!!! DOES THE PLACEHOLDER JSON EVEN LOAD??? LET'S SEE BY TRACING IT !!!!!: " + json);

        if(resetAnims)
        {
            for(anim in anims)
            {
                animation.remove(anim.name);
            }
        }

        var balls:Bool = false;

        if(Assets.exists('assets/characters/$swagName.json'))
            balls = true;
        #if sys
        else
        {
            if(Mods.activeMods.length > 0)
            {
                for(mod in Mods.activeMods)
                {
                    if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$swagName.json'))
                    {
                        balls = true;
                    }
                }
            }
        }
        #end

        //trace("!!!!! CHARACTER EXISTS !!!!!: " + balls);

        if(balls)
        {
            #if sys
            if(Assets.exists('assets/characters/$swagName.json'))
            #end
                json = Util.getJsonContents('assets/characters/$swagName.json');
            #if sys
            else
            {
                if(Mods.activeMods.length > 0)
                {
                    for(mod in Mods.activeMods)
                    {
                        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$swagName.json'))
                        {
                            json = Util.getJsonContents('mods/$mod/characters/$swagName.json');
                        }
                    }
                }
            }
            #end
        }
        else
        {
            if(!isInCharEditor)
            {
                swagName = "placeholder";
                this.name = swagName;
                json = Util.getJsonContents('assets/characters/$swagName.json');
            }
        }

        //trace("!!!!! DOES THE SHIT EXIST??? LET'S FIND OUT IN TODAY'S EPISODE OF PAIN AND SUFFERING !!!!!: " + Std.isOfType(Util.getSparrow('characters/images/$swagName/assets', false), FlxAtlasFrames));
        frames = Util.getSparrow('characters/images/$swagName/assets', false);

        if(balls || !isInCharEditor)
        {
            setGraphicSize(Std.int(frameWidth * json.scale));
            updateHitbox();

            flipX = json.flip_x;
            
            antialiasing = !json.no_antialiasing;
            
            if(antialiasing == true)
                antialiasing = Options.getData('anti-aliasing');

            camOffsets = json.camera_position;
            healthColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
            position = json.position;

            anims = json.animations;
            singDuration = json.sing_duration;

            if(json.healthicon != null)
                healthIcon = json.healthicon;
            else
                healthIcon = name;
            
            for (anim in anims) {
                if (anim.indices == null || anim.indices.length < 1) {
                    animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
                } else {
                    animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
                }

                offsetMap.set(anim.anim, anim.offsets);
            }
            
            bopLeftRight = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);

            //playAnim('idle');
            dance();
        }
        else
        {
            healthIcon = "placeholder";
            position = [0, 0];
            offset.set(0, 0);
        }
    }

    override public function update(elapsed) {
        super.update(elapsed);

        if(/*!isInCharEditor &&*/ animation.curAnim != null)
        {
            if(animation.curAnim.name.startsWith('sing'))
                holdTimer += elapsed;
        }
    }

    public function playAnim(AnimName:String, Force:Null<Bool> = false, Reversed:Null<Bool> = false, Frame:Null<Int> = 0, ?offsetX:Null<Float>, ?offsetY:Null<Float>) {
        if(animation.getByName(AnimName) != null)
        {
            animation.play(AnimName, Force, Reversed, Frame);

            if(offsetX != null)
                offset.set(offsetX, offsetY);
            else
                offset.set(offsetMap[AnimName][0], offsetMap[AnimName][1]);
        }
    }
    public function dance() {
        if(shouldDance)
        {
            holdTimer = 0;

            if(animation.curAnim != null)
            {
                if(animation.curAnim.name == 'singLEFT')
                    bopDirection = 0;
                else if(animation.curAnim.name == 'singRIGHT')
                    bopDirection = 1;
            }
            
            if (bopLeftRight == true) {
                if (bopDirection == 0) {
                    playAnim('danceLeft', true);
                } else {
                    playAnim('danceRight', true);
                }

                bopDirection = (bopDirection + 1) % 2;
            }

            if (bopLeftRight == false) {
                playAnim('idle');
            }
        }
    }
}
