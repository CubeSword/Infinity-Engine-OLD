package game;

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
    public var isPlayer:Bool = false;
    public var holdTimer:Float = 0;
    public var healthIcon:String = "bf";

    public function new(x, y, name)
    {
        super(x, y);
        loadCharacter(name);
    }

    public function loadCharacter(name:String = "bf", ?resetAnims:Bool = false)
    {
        this.name = name;
        json = null;

        if(resetAnims)
        {
            for(anim in anims)
            {
                animation.remove(anim.name);
            }
        }

        var balls:Bool = false;

        if(Assets.exists('assets/characters/$name.json'))
            balls = true;
        #if sys
        else
        {
            if(Mods.activeMods.length > 0)
            {
                for(mod in Mods.activeMods)
                {
                    if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$name.json'))
                    {
                        balls = true;
                    }
                }
            }
        }
        #end

        trace("!!!!! CHARACTER EXISTS !!!!!: " + balls);

        if(balls)
        {
            #if sys
            if(Assets.exists('assets/characters/$name.json'))
            #end
                json = Util.getJsonContents('assets/characters/$name.json');
            #if sys
            else
            {
                if(Mods.activeMods.length > 0)
                {
                    for(mod in Mods.activeMods)
                    {
                        if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/$name.json'))
                        {
                            json = Util.getJsonContents('mods/$mod/characters/$name.json');
                        }
                    }
                }
            }
            #end
        }

        #if sys
        if(Assets.exists('assets/characters/images/$name/assets.png', IMAGE))
        #end
            frames = Util.getSparrow('assets/characters/images/$name/assets', false);
        #if sys
        else
            frames = Util.getSparrow('characters/images/$name/assets', false);
        #end

        if(json != null)
        {
            setGraphicSize(Std.int(width * json.scale));
            updateHitbox();

            flipX = json.flip_x;
            
            antialiasing = !json.no_antialiasing;
            
            if(antialiasing == true)
                antialiasing = Options.getData('anti-aliasing');

            camOffsets = json.camera_position;
            healthColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
            position = json.position;

            anims = json.animations;

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

        if(animation.curAnim.name.startsWith('sing'))
            holdTimer += elapsed;
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
        holdTimer = 0;
        
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
