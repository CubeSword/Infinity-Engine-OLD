package game;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import game.Conductor;
import game.PlayState;

using StringTools;

class GameOverSubstate extends BasicSubState
{
    var player:Character;
    var camFollow:FlxObject;

    var isEnding:Bool = false;
    var playingMusic:Bool = false;

    var swagDeathChar:String = "bf";

	public function new(x:Float, y:Float, deathCharacter:String = "bf")
	{
		super();

        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.screenCenter(X);
        bg.scrollFactor.set();
        add(bg);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

        if(deathCharacter.contains('bf'))
            swagDeathChar = "bf";

        // the only spritesheet that has bf qwith blue balls is regular bf, so we
        // switch to regular bf if the character name contains "bf"

        if(deathCharacter == "bf-pixel")
            swagDeathChar = "bf-pixel-dead";

        // don't wanna re-export pixel bf's xml to include death anim so i'm doin this

		player = new Character(x, y, swagDeathChar);
        player.flipX = !player.flipX;
        player.isPlayer = true;
		add(player);

		camFollow = new FlxObject(player.getGraphicMidpoint().x, player.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if(FlxG.sound.music.active)
			FlxG.sound.music.stop();

        var soundPath:String = 'gameplay/blueBalled';
        if(swagDeathChar == "bf-pixel-dead")
            soundPath += '-pixel';

		FlxG.sound.play(Util.getSound(soundPath));

		Conductor.changeBPM(100);

		player.playAnim('firstDeath');
    }

	override function update(elapsed:Float)
    {
        super.update(elapsed);

        FlxG.camera.followLerp = 0.01 * (60 / Main.display.currentFPS);

        var accept = Controls.accept;
        var back = Controls.back;

        if (accept)
        {
            retrySong();
        }

        if (back)
        {
            FlxG.sound.music.stop();
            FlxG.sound.playMusic(Util.getSound("menus/freakyMenu", false));

            if (PlayState.storyMode)
                FlxG.switchState(new menus.StoryModeState());
            else
                FlxG.switchState(new menus.FreeplayMenuState());
        }

        if (player.animation.curAnim.name == 'firstDeath' && player.animation.curAnim.curFrame == 12)
        {
            FlxG.camera.follow(camFollow, LOCKON, 0.01 * (60 / Main.display.currentFPS));
        }

        if (player.animation.curAnim.name == 'firstDeath' && player.animation.curAnim.finished && !playingMusic)
        {
            playingMusic = true;

            var soundPath:String = 'gameOver';
            if(swagDeathChar == "bf-pixel-dead")
                soundPath += '-pixel';
    
            FlxG.sound.playMusic(Util.getSound(soundPath, false));

            player.playAnim('deathLoop');
        }

        if (FlxG.sound.music.playing)
        {
            Conductor.songPosition = FlxG.sound.music.time;
        }
    }

    function retrySong()
    {
        if(!isEnding)
        {
            isEnding = true;
            player.playAnim('deathConfirm', true);
            FlxG.sound.music.stop();

            var soundPath:String = 'gameplay/gameOverEnd';
            if(swagDeathChar == "bf-pixel-dead")
                soundPath += '-pixel';
    
            FlxG.sound.play(Util.getSound(soundPath));

            new FlxTimer().start(0.7, function(tmr:FlxTimer)
            {
                FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
                {
                    FlxG.resetState();
                });
            });
        }
    }
}