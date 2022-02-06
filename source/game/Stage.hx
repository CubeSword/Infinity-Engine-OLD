package game;

import mods.Mods;
import lime.utils.Assets;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;

class Stage extends FlxTypedGroup<StageSprite>
{
    var rawStageData:Dynamic;
    var stageObjects:Array<Dynamic>;

    var file:Dynamic;

    public var megaCoolPoggersStage:String = "stage";

    #if linc_luajit
    public var stageScript:LuaHandler = null;
    #end

	public function new(swagStage:String = "stage")
    {
        super();

        megaCoolPoggersStage = swagStage;
        getStageJSON(megaCoolPoggersStage);
        //trace("Stage Objects: " + stageObjects);
        //trace("Stage Objects Length: " + stageObjects.length);

        for(i in 0...stageObjects.length)
        {
            var swagSprite:StageSprite = new StageSprite(stageObjects[i].position[0], stageObjects[i].position[1]);

            //trace("x: " + stageObjects[i].position[0] + " y: " + stageObjects[i].position[1]);
            //trace(stageObjects[i].file_Name);

            if(stageObjects[i].is_Animated)
            {
                if(!stageObjects[i].isPackerAtlas)
                    file = Util.getSparrow('stages/$megaCoolPoggersStage/' + stageObjects[i].file_Name, false);
                else
                    file = Util.getPacker('stages/$megaCoolPoggersStage/' + stageObjects[i].file_Name, false);

                //trace("file: " + file);
                swagSprite.frames = file;
                // should be like: 'stages/stage/stageback.png' or smth

                for(i2 in 0...stageObjects[i].animations.length)
                {
                    //trace("anim name: " + stageObjects[i].animations[i2][0]);
                    //trace("xml shit: " + stageObjects[i].animations[i2][1]);

                    if(!stageObjects[i].isPackerAtlas)
                        swagSprite.animation.addByPrefix(stageObjects[i].animations[i2][0], stageObjects[i].animations[i2][1], stageObjects[i].fps, stageObjects[i].looped, stageObjects[i].flipX);
                    else
                        swagSprite.animation.add(stageObjects[i].animations[i2][0], stageObjects[i].animations[i2][1], stageObjects[i].fps, stageObjects[i].looped, stageObjects[i].flipX);
                    // go through each animation and add them
                }

                var firstAnim:String = stageObjects[i].animations[0][0];
                //trace("first anim: " + firstAnim);

                swagSprite.isAnimated = true;

                swagSprite.firstAnim = firstAnim;
                swagSprite.animation.play(firstAnim); // play first animation added, idle should go first so it can play here
            }
            else
            {
                //trace('stages/$megaCoolPoggersStage/' + stageObjects[i].file_Name);
                swagSprite.loadGraphic(Util.getImage('stages/$megaCoolPoggersStage/' + stageObjects[i].file_Name, false));
            }

            if(stageObjects[i].specialScale)
            {
                swagSprite.scale.set(stageObjects[i].scale, stageObjects[i].scale);
            }
            else
            {
                swagSprite.setGraphicSize(Std.int(swagSprite.width * stageObjects[i].scale));
                swagSprite.updateHitbox();
            }

            swagSprite.scrollFactor.set(stageObjects[i].scroll_Factor[0], stageObjects[i].scroll_Factor[1]);

            if(stageObjects[i].antialiasing)
                swagSprite.antialiasing = Options.getData('anti-aliasing');
            else
                swagSprite.antialiasing = false;

            swagSprite.visible = stageObjects[i].visible;

            if(stageObjects[i].alpha != null)
                swagSprite.alpha = stageObjects[i].alpha;
            else
                swagSprite.alpha = 1;

            swagSprite.bopLeftRight = stageObjects[i].danceLeftRight;

            if(!stageObjects[i].isInFront)
                add(swagSprite); // add the sprite to the stage if it is not in front
        }

        if(megaCoolPoggersStage == "school" || megaCoolPoggersStage == "schoolAngry")
        {
            var widShit = Std.int(members[0].width * 6);

            members[0].setGraphicSize(widShit);
            members[1].setGraphicSize(widShit);
            members[2].setGraphicSize(widShit);
            members[3].setGraphicSize(Std.int(widShit * 0.8));
            members[4].setGraphicSize(Std.int(widShit * 1.4));
            members[5].setGraphicSize(widShit);

            members[0].updateHitbox();
            members[1].updateHitbox();
            members[2].updateHitbox();
            members[3].updateHitbox();
            members[4].updateHitbox();
            members[5].updateHitbox();

            members[6].setGraphicSize(Std.int(members[6].width * 6));
            members[6].updateHitbox();
        }

        PlayState.characterPositions = [];
        
        for(i in 0...rawStageData.character_Positions.length)
        {
            PlayState.characterPositions.push([rawStageData.character_Positions[i][0], rawStageData.character_Positions[i][1]]);
        }

        //trace(PlayState.characterPositions);

        PlayState.stageCamZoom = rawStageData.camera_Zoom;
    }

    public function createLuaStuff()
    {
        #if linc_luajit
        #if sys
        if(rawStageData != null)
        {
            if(sys.FileSystem.exists(Sys.getCwd() + Util.getPath('stages/$megaCoolPoggersStage/script.lua')))
                stageScript = LuaHandler.createLuaHandler(Util.getPath('stages/$megaCoolPoggersStage/script.lua'));
        }
        #end
        #end
    }

    override public function destroy() {
        #if linc_luajit
        if(stageScript != null)
        {
            stageScript.die();
            stageScript = null;
        }
        #end

        super.destroy();
    }

    function getStageJSON(?swagStage:String = "stage")
    {
        var stage:String = swagStage;

        if(!stageExists(stage))
        {
            stage = "stage";
            megaCoolPoggersStage = stage;
        }

		#if sys
		if(Assets.exists('assets/stages/$stage/data.json'))
		{
		#end
		    rawStageData = Util.getJsonContents('assets/stages/$stage/data.json');
			stageObjects = rawStageData.objects;
		#if sys
		}
		else
		{
			Mods.updateActiveMods();

			if(Mods.activeMods.length > 0)
			{
				for(mod in Mods.activeMods)
				{
					if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/stages/$stage/data.json'))
					{
						rawStageData = Util.getJsonContents('mods/$mod/stages/$stage/data.json');
						stageObjects = rawStageData.objects;
					}
				}
			}
		}
		#end
    }

    public function beatHit()
    {
        for(stageObject in members)
        {
            stageObject.beatHit();
        }
    }

    function stageExists(?stage:String = "stage"):Bool
    {
        var fard:Bool = false;

		#if sys
		if(Assets.exists('assets/stages/$stage/data.json'))
		{
		#end
            fard = true;
		#if sys
		}
		else
		{
			Mods.updateActiveMods();

			if(Mods.activeMods.length > 0)
			{
				for(mod in Mods.activeMods)
				{
					if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/stages/$stage/data.json'))
					{
                        fard = true;
					}
				}
			}
		}
		#end

        return fard;
    }
}