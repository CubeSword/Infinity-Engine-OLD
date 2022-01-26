package menus;

import flixel.util.FlxColor;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import game.Song.Song;
import game.PlayState;

class ChartEditorMenu extends BasicState
{
    var desatBG:FlxSprite;
    var grid:FlxSprite;

    var gridSize:Int = 40;
    var beatSnap:Int = 16;

    var song:Song;
    var dummyArrow:FlxSprite;

    public function new(songArg:String = "test")
    {
        super();

        if(PlayState.song != null)
        {
            song = PlayState.song;
            song.speed = PlayState.instance.speed;
        }
        else
            song = Util.getJsonContents('assets/songs/$songArg/normal.json').song;
        
        if(song.keyCount == null)
            song.keyCount = 4;

        if(song.timescale == null)
            song.timescale = [4, 4];

        trace(song.keyCount);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

        FlxG.mouse.visible = true;

        desatBG = new FlxSprite().loadGraphic(Util.getImage('menuDesat'));
        desatBG.alpha = 0.2;
        add(desatBG);

        grid = FlxGridOverlay.create(gridSize, gridSize, gridSize * (song.keyCount * 2), gridSize * 16);
        grid.screenCenter();
        add(grid);

		dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize);
		add(dummyArrow);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var back = Controls.back;

        if(back)
            transitionState(new OptionsState());

		if (FlxG.mouse.x > grid.x
			&& FlxG.mouse.x < grid.x + grid.width
			&& FlxG.mouse.y > grid.y
			&& FlxG.mouse.y < grid.y + (gridSize * ((16 / song.timescale[1]) * 4)))
		{
			var snappedGridSize = (gridSize / (beatSnap / 16));

			dummyArrow.x = Math.floor(FlxG.mouse.x / gridSize) * gridSize;

			if(FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / snappedGridSize) * snappedGridSize;
		}
    }
}