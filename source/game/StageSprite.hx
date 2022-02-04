package game;

import flixel.FlxSprite;
import flixel.FlxG;

class StageSprite extends FlxSprite
{
    var swagBop:Bool = false;
    public var bopLeftRight:Bool = false;
    public var firstAnim:String = "idle";
    public var isAnimated:Bool = false;

    public function new(x:Float, y:Float, ?bopLeftRight:Bool = false)
    {
        super(x, y);

        this.bopLeftRight = bopLeftRight;

        animation.play(firstAnim);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function beatHit()
    {
        if(isAnimated && !animation.curAnim.looped)
        {
            if(bopLeftRight)
            {
                if(!swagBop)
                    animation.play('danceLeft');
                else
                    animation.play('danceRight');

                swagBop = !swagBop;
            }
            else
            {
                animation.play(firstAnim, true);
            }
        }
    }
}