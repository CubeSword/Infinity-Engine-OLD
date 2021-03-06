package menus;

import flixel.math.FlxMath;
import lime.app.Application;
import flixel.system.FlxSound;
import lime.utils.Assets;
import mods.Mods;
import flixel.text.FlxText;
import ui.Icon;
import ui.AlphabetText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import DiscordRPC;

using StringTools;

class FreeplayMenuState extends BasicState
{
    var songs:Array<SongMetadata> = [];
    var swagMods:Array<String> = ["Base Game"];

    static var selectedSong:Int = 0;
    static var selectedMod:Int = 0;

    var selectedDifIndex:Int = 1;

    var bg:FlxSprite;

    var colorTween:FlxTween;
    var selectedColor:Int = 0xFF7F1833;

    var songAlphabets:FlxTypedGroup<AlphabetText> = new FlxTypedGroup<AlphabetText>();
    var songIcons:FlxTypedGroup<Icon> = new FlxTypedGroup<Icon>();

    var selectedDifficulty:String = "normal";

    var box:FlxSprite;
    var box2:FlxSprite;

    var scoreText:FlxText;
    var difText:FlxText;
    var speedText:FlxText;
    var selectedModText:FlxText;

    public static var curSpeed:Float = 1;

    var vocals:FlxSound = new FlxSound();

    var holdTime:Float = 0;
    var elapsedVar:Float = 0;

    var realScore:Float = 0;
    var swagScore:Float = 0;

    var realAcc:Float = 0;
    var swagAcc:Float = 0;

    var up = false;
    var down = false;
    var left = false;
    var leftP = false;
    var right = false;
    var rightP = false;
    var shiftP = false;
    var reset = false;

    var rawSongListData:FreeplayList;
    var songListData:Array<FreeplaySong>;
    
    public function new()
    {
        super();

        Util.clearMemoryStuff();

        Highscores.init();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

        #if sys
        for(mod in Mods.activeMods)
        {
            var real:Dynamic = null;

            if(Mods.activeMods.length > 0)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/freeplaySongs.json'))
                {
                    real = Util.getJsonContents('mods/$mod/data/freeplaySongs.json');
                }
            }

            //trace(real);

            if(real != null && real.songs.length > 0)
                swagMods.push(mod);

            // this checks to see if there are any freeplay songs in the mod, if there are none, skip the mod
        }
        #end

        var daMod = swagMods[selectedMod];
        bg = new FlxSprite().loadGraphic(Util.getImage('menuDesat', true, daMod));
		add(bg);

        loadSongs(true);
 
        box = new FlxSprite();
        box.makeGraphic(1,1,FlxColor.BLACK);
        box.alpha = 0.6;
        add(box);

        box2 = new FlxSprite();
        box2.makeGraphic(1,1,FlxColor.BLACK);
        box2.alpha = 0.6;
        add(box2);

        scoreText = new FlxText(0, 0, 0,"PERSONAL BEST: 0", 32);
        scoreText.setFormat(Util.getFont('vcr'), 32, FlxColor.WHITE, RIGHT);
        add(scoreText);

        difText = new FlxText(0, scoreText.y + scoreText.height + 2, 0, "< Normal >", 24);
		difText.font = scoreText.font;
		difText.alignment = RIGHT;
		add(difText);

        speedText = new FlxText(0, difText.y + difText.height + 2, 0, "1", 24);
		speedText.font = scoreText.font;
		speedText.alignment = RIGHT;
		add(speedText);

        selectedModText = new FlxText(0, box2.y + 6, 0, "Base Game", 24);
		selectedModText.font = scoreText.font;
		selectedModText.alignment = RIGHT;
		add(selectedModText);

        selectedColor = songs[selectedSong].color;
        bg.color = selectedColor;

        add(songAlphabets);
        add(songIcons);

        updateSelection();

        BasicState.changeAppTitle(Util.engineName, "Freeplay Menu");
    }

    override public function create()
    {
        super.create();

        #if discord_rpc
        DiscordRPC.changePresence("In Freeplay", null);
        #end
    }

    function loadSongs(?isStupid:Bool = false)
    {
        if(selectedMod < 0)
            selectedMod = swagMods.length - 1;

        if(selectedMod > swagMods.length - 1)
            selectedMod = 0;
        
        songs = [];

        if(!isStupid)
        {
            for(i in 0...songAlphabets.members.length)
            {
                songAlphabets.members[i].kill();
                songAlphabets.members[i].destroy();

                songIcons.members[i].kill();
                songIcons.members[i].destroy();
            }

            songAlphabets.clear();
            songIcons.clear();
        }

        var daMod:String = swagMods[selectedMod];
        
        rawSongListData = null;
        songListData = [];

        if(daMod == "Base Game")
        {
            rawSongListData = Util.getJsonContents(Util.getJsonPath("data/freeplaySongs"));
            songListData = rawSongListData.songs;
        }

        #if sys
        Mods.updateActiveMods();
        
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/freeplaySongs.json') && daMod == mod && daMod != "Base Game")
                {
                    var coolData:FreeplayList = Util.getJsonContents('mods/$mod/data/freeplaySongs.json');

                    for(song in coolData.songs)
                    {
                        songListData.push(song);
                    }
                }
            }
        }
        #end

        for(songData in songListData)
        {
            // Variables I like yes mmmm tasty
            var icon = songData.icon;
            var song = songData.name;
            
            var defDiffs = ["Easy", "Normal", "Hard"];

            var diffs:Array<String>;

            if(songData.difficulties == null)
                diffs = defDiffs;
            else
                diffs = songData.difficulties;

            var color = songData.bgColor;
            var actualColor:Null<FlxColor> = null;

            if(color != null)
                actualColor = FlxColor.fromString(color);

            // Creates new song data accordingly
            songs.push(new SongMetadata(song, icon, diffs, actualColor));
        }

        for(songDataIndex in 0...songs.length)
        {
            var songData = songs[songDataIndex];

            var alphabet = new AlphabetText(0, (70 * songDataIndex) + 30, songData.songName);
            alphabet.targetY = songDataIndex;
            alphabet.isMenuItem = true;

            songAlphabets.add(alphabet);

            var icon = new Icon(Util.getCharacterIcons(songData.songCharacter), alphabet, null, null, null, null, songData.songCharacter);
            songIcons.add(icon);
        }

        if(!isStupid)
        {
            selectedSong = 0;
            updateSelection();
        }

        bg.loadGraphic(Util.getImage('menuDesat', true, swagMods[selectedMod]));
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        elapsedVar = elapsed;

        realScore = Highscores.getSongScore(songs[selectedSong].songName.toLowerCase(), selectedDifficulty.toLowerCase())[0];
        swagScore = FlxMath.lerp(swagScore, realScore, Math.max(0, Math.min(1, elapsed * 20)));

        realAcc = Highscores.getSongScore(songs[selectedSong].songName.toLowerCase(), selectedDifficulty.toLowerCase())[1];
        swagAcc = FlxMath.lerp(swagAcc, realAcc, Math.max(0, Math.min(1, elapsed * 20)));

        if(Controls.back)
        {
            FlxG.sound.play(Util.getSound("menus/cancelMenu", true));
            transitionState(new menus.MainMenuState());
        }

        if(FlxG.keys.justPressed.SPACE) {
            if (FlxG.sound.music != null) {
                FlxG.sound.music.stop();
            }

            if (vocals != null) {
                vocals.stop();
            }

            FlxG.sound.playMusic(Util.getInst(songs[selectedSong].songName.toLowerCase()), 1, false);

            /*if(song.needsVoices)
            {*/
                FlxG.sound.music.pause();

                vocals = FlxG.sound.play(Util.getVoices(songs[selectedSong].songName.toLowerCase()));

                vocals.pause();

                FlxG.sound.music.time = 0;
                vocals.time = 0;

                FlxG.sound.music.play();
                vocals.play();
            /*}
            else 
                vocals = new FlxSound();*/

            FlxG.sound.list.add(vocals);

            refreshSpeed();
        }

        up = Controls.UI_UP;
        down = Controls.UI_DOWN;
        left = Controls.UI_LEFT;
        leftP = Controls.UI_LEFT_P;
        right = Controls.UI_RIGHT;
        rightP = Controls.UI_RIGHT_P;
        shiftP = Controls.shiftP;
        reset = Controls.reset;

        if(up || down)
        {
            if(up)
                selectedSong -= 1;
    
            if(down)
                selectedSong += 1;
            
            updateSelection();
        }

		if (-1 * Math.floor(FlxG.mouse.wheel) != 0 && !shiftP)
        {
            selectedSong += -1 * Math.floor(FlxG.mouse.wheel);
			updateSelection();
        }

		if (-1 * Math.floor(FlxG.mouse.wheel / 10) != 0 && shiftP)
        {
            var daMultiplier:Float = -1 * Math.floor(FlxG.mouse.wheel / 10);
			changeSpeed(daMultiplier);
        }

        if(left && !shiftP || right && !shiftP)
        {
            if(left)
                selectedDifIndex -= 1;

            if(right)
                selectedDifIndex += 1;

            updateSelection();
        }

        if(FlxG.keys.justPressed.Q)
        {
            selectedMod -= 1;
            loadSongs();
        }

        if(FlxG.keys.justPressed.E)
        {
            selectedMod += 1;
            loadSongs();
        }

		if((leftP || rightP) && shiftP) {
			var daMultiplier:Float = leftP ? -0.05 : 0.05;
			changeSpeed(daMultiplier);
		} else {
			holdTime = 0;
		}

        if(reset && shiftP)
            curSpeed = 1;

        if(Controls.accept)
        {
            game.PlayState.songMultiplier = curSpeed;
            if(shiftP)
                LoadingState.loadAndSwitchState(new game.PlayState(songs[selectedSong].songName.toLowerCase(), selectedDifficulty.toLowerCase(), false));
            else
                transitionState(new game.PlayState(songs[selectedSong].songName.toLowerCase(), selectedDifficulty.toLowerCase(), false));
        }

        // might be smart to update the text before updating the x and box lmao
        scoreText.text = "PERSONAL BEST:" + Math.floor(swagScore);
		scoreText.x = FlxG.width - scoreText.width;

        difText.text = "< " + songs[selectedSong].difficulties[selectedDifIndex] + " - " + FlxMath.roundDecimal(swagAcc, 2) + "%" + " >";
		difText.x = FlxG.width - difText.width;

        speedText.text = "Speed: " + FlxMath.roundDecimal(curSpeed, 2) + " (SHIFT+R)";
		speedText.x = FlxG.width - speedText.width;

        var funnyObject:FlxText = scoreText;

		if(speedText.width >= scoreText.width)
			funnyObject = speedText;

		if(difText.width >= scoreText.width)
			funnyObject = difText;

		box.x = funnyObject.x - 6;

		if(Std.int(box.width) != Std.int(funnyObject.width + 6))
			box.makeGraphic(Std.int(funnyObject.width + 6), 90, FlxColor.BLACK);

        // for new thing where you can scroll thru the mods instead all of them displaying at once because yes!!!!!!!!!!

        var funnyObject2:FlxText = selectedModText;

		if(Std.int(box2.width) != Std.int(funnyObject2.width + 6))
			box2.makeGraphic(Std.int(funnyObject2.width + 6), 80, FlxColor.BLACK);

        box2.setPosition(funnyObject2.x - 6, FlxG.height - box2.height);

        selectedModText.text = "Press Q & E to switch mods\nSelected Mod:\n" + swagMods[selectedMod] + "\n";
        selectedModText.setPosition(FlxG.width - selectedModText.width, box2.y + 6);

        refreshSpeed();
    }

    function updateSelection()
    {
        if(selectedSong < 0)
            selectedSong = songs.length - 1;

        if(selectedSong > songs.length - 1)
            selectedSong = 0;

        if(selectedDifIndex > songs[selectedSong].difficulties.length - 1)
            selectedDifIndex = 0;

        if(selectedDifIndex < 0)
            selectedDifIndex = songs[selectedSong].difficulties.length - 1;

        selectedDifficulty = songs[selectedSong].difficulties[selectedDifIndex];

        var newColor:FlxColor = songs[selectedSong].color;

        if(newColor != selectedColor) {
            if(colorTween != null) {
                colorTween.cancel();
            }

            selectedColor = newColor;

            colorTween = FlxTween.color(bg, 0.4, bg.color, selectedColor, {
                onComplete: function(twn:FlxTween) {
                    colorTween = null;
                }
            });
        }

        if(songIcons.members.length > 0)
        {
            for (i in 0...songIcons.members.length)
            {
                songIcons.members[i].alpha = 0.6;
            }
    
            songIcons.members[selectedSong].alpha = 1;
        }

        for(itemIndex in 0...songAlphabets.members.length)
        {
            var item = songAlphabets.members[itemIndex];

            item.targetY = itemIndex - selectedSong;

            item.alpha = 0.6;

            if (item.targetY == 0)
                item.alpha = 1;
        }

        FlxG.sound.play(Util.getSound('menus/scrollMenu'));
    }

    function changeSpeed(?change:Float = 0)
    {
        holdTime += elapsedVar;

        if(holdTime > 0.5 || left || right)
        {
            curSpeed += change;

            if(curSpeed < 0.1)
                curSpeed = 0.1;
        }
    }

    function refreshSpeed()
    {
        #if cpp
        @:privateAccess
        {
            if(FlxG.sound.music.active && FlxG.sound.music.playing)
                lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);

            if (vocals.active && vocals.playing)
                lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, curSpeed);
        }
        #end
    }
}

class SongMetadata
{
    public static var coolColors:Array<Int> = [0xFF7F1833, 0xFF7C689E, -14535868, 0xFFA8E060, 0xFFFF87FF, 0xFF8EE8FF, 0xFFFF8CCD, 0xFFFF9900];

	public var songName:String = "";
	public var songCharacter:String = "";
	public var difficulties:Array<String> = ["easy", "normal", "hard"];
	public var color:FlxColor = FlxColor.GREEN;

	public function new(song:String, songCharacter:String, ?difficulties:Array<String>, ?color:FlxColor)
	{
		this.songName = song;
		this.songCharacter = songCharacter;

		if(difficulties != null)
			this.difficulties = difficulties;

		if(color != null)
			this.color = color;
		else
            this.color = coolColors[0];
	}
}

typedef FreeplayList =
{
    var songs:Array<FreeplaySong>;
}

typedef FreeplaySong =
{
    var name:String;
    var icon:String;
    var bgColor:Null<String>;
    var difficulties:Null<Array<String>>;
}