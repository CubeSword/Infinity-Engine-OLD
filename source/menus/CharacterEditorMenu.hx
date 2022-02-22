package menus;

import game.Stage.StageFront;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.graphics.FlxGraphic;
import openfl.events.IOErrorEvent;
import haxe.Json;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.ui.FlxBar;
import ui.CustomDropdown;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import game.PlayState;
import lime.system.Clipboard;
import flixel.ui.FlxButton;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.system.FlxSound;
import lime.utils.Assets;
import mods.Mods;
import flixel.text.FlxText;
import ui.Icon;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import game.Character;
import game.Stage;

using StringTools;

class CharacterEditorMenu extends BasicState
{
    var curChar:String = "dad";
    var curAnim:Int = -1;

    var offsetX:Float = 0;
    var offsetY:Float = 0;

    var animList:Array<Dynamic> = [];
    var prefixList:Array<Dynamic> = [];
    var animOffsets:Array<Dynamic> = [];
    var loopList:Array<Dynamic> = [];

    var healthColor:Array<Int> = [175, 102, 206];

    var character:Character;
    var characterGhost:Character;

    var uiGroup:FlxGroup = new FlxGroup();
    var uiBase:FlxUI;

    var gameCam:FlxCamera;
    var hudCam:FlxCamera;
    var camFollow:FlxObject;

    var animListText:FlxText;

    var curAnimText:FlxText;

    var charNamePos:Array<Dynamic> = [];

    var characterList:Array<String> = [];

    var icons:FlxTypedGroup<Icon>;

    var charNameBox:FlxUIInputText;
    var animNameBox:FlxUIInputText;
    var animPrefixBox:FlxUIInputText;
    var customIconTextBox:FlxUIInputText;

    var loopAnimBox:FlxUICheckBox;
    var noAntialiasingBox:FlxUICheckBox;

    var charXBox:FlxUINumericStepper;
    var charYBox:FlxUINumericStepper;
    var scaleBox:FlxUINumericStepper;

    var camXBox:FlxUINumericStepper;
    var camYBox:FlxUINumericStepper;

    var charListMenu:CustomDropdown;

    var stage:Stage;
    var stageFront:StageFront;

    var healthBarBG:FlxSprite;
    var healthBar:FlxBar;

    var charData:Dynamic;

    var playerChar:Bool = false;

    var cameraFollowPointer:FlxSprite;

    #if sys
    var jsonDirs = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/characters/");
    #else
    var jsonDirs:Array<String> = [
        "bf.json", 
        "bf-car.json", 
        "bf-christmas.json", 
        "bf-pixel.json", 
        "bf-pixel-dead.json", 
        "dad.json", 
        "gf.json", 
        "gf-car.json", 
        "gf-christmas.json", 
        "gf-pixel.json",
        "mom.json",
        "mom-car.json",
        "monster.json",
        "monster-christmas.json",
        "parents-christmas.json",
        "pico.json",
        "placeholder.json",
        "senpai.json",
        "senpai-angry.json",
        "spirit.json",
        "spooky.json"
    ];
    #end

    var jsons:Array<String> = [];
    
    override public function create()
    {
        super.create();

        trace("OLD JSON SHIT: " + jsons);

        #if sys
        if(Mods.activeMods.length > 0)
        {
            for(mod in Mods.activeMods)
            {
                if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/characters/'))
                {
                    var funnyArray = sys.FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/characters/');
                    
                    for(jsonThingy in funnyArray)
                    {
                        jsonDirs.push(jsonThingy);
                    }
                }
            }
        }
        #end

        for(dir in jsonDirs)
        {
            if(dir.endsWith(".json"))
                jsons.push(dir.split(".json")[0]);
        }

        trace("NEW JSON SHIT: " + jsons);

        refreshAppTitle();

        persistentUpdate = true;

		hudCam = new FlxCamera();
		gameCam = new FlxCamera();
        hudCam.bgColor.alpha = 0;

		FlxG.cameras.reset();

		FlxG.cameras.add(gameCam, true);
		FlxG.cameras.add(hudCam, false);

		FlxG.cameras.setDefaultDrawTarget(gameCam, true);

		FlxG.camera = gameCam;

		/*var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0, 0);
		add(gridBG);*/

        stage = new Stage('stage');
        add(stage);

        stageFront = new StageFront('stage');
        add(stageFront);

        characterGhost = new Character(0, 0, curChar, true);
        characterGhost.screenCenter();
        characterGhost.alpha = 0.45;
        add(characterGhost);

        character = new Character(0, 0, curChar, true);
        character.screenCenter();
        add(character);

        camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

        FlxG.camera.follow(camFollow);

		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);

        updateCharacter();

        animListText = new FlxText(8, 8, 0, "coolswag\nmega coolswag\n", 18, true);
        animListText.borderStyle = OUTLINE;
        animListText.borderSize = 2;
        animListText.borderColor = FlxColor.BLACK;
        animListText.color = FlxColor.CYAN;
        animListText.scrollFactor.set();
        animListText.cameras = [hudCam];
        add(animListText);

        curAnimText = new FlxText(0, 8, 0, "super idle", 48);
        curAnimText.setFormat(Util.getFont('vcr'), 48, FlxColor.WHITE, CENTER);
        curAnimText.borderStyle = OUTLINE;
        curAnimText.borderSize = 2;
        curAnimText.borderColor = FlxColor.BLACK;
        curAnimText.screenCenter(X);
        curAnimText.scrollFactor.set();
        curAnimText.cameras = [hudCam];
        add(curAnimText);

        character.x = PlayState.characterPositions[1][0];
        character.y = PlayState.characterPositions[1][1];

        character.x += character.position[0];
        character.y += character.position[1];

        offsetX = character.offset.x;
        offsetY = character.offset.y;

        refreshDiscordRPC();

        uiGroup.cameras = [hudCam];
        add(uiGroup);

        getCharacterList();

        create_UI();

        updateAnimList();

        changeAnim(1);

        var iconSpacingLol:Int = 40;

		healthBarBG = new FlxSprite(iconSpacingLol, FlxG.height * 0.9).loadGraphic(Util.getImage('healthBar'));
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = Options.getData('anti-aliasing');
        healthBarBG.cameras = [hudCam];
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(character.healthColor, character.healthColor);
        healthBar.cameras = [hudCam];
		add(healthBar);

        icons = new FlxTypedGroup<Icon>();
        add(icons);

        for(i in 0...3)
        {
            var icon:Icon = new Icon(Util.getCharacterIcons(curChar), null, null, null, null, null, curChar);
            icon.setPosition(iconSpacingLol + (i * 130), healthBarBG.y - (icon.height / 2));
            icon.scrollFactor.set();
            icon.cameras = [hudCam];

            icons.add(icon);
        }
    }

	function updatePointerPos()
    {
		var x:Float = character.getMidpoint().x;
		var y:Float = character.getMidpoint().y;
		if(!character.isPlayer) {
			x += 150 + character.camOffsets[0];
		} else {
			x -= 100 + character.camOffsets[0];
		}
		y -= 100 - character.camOffsets[1];

		x -= cameraFollowPointer.width / 2;
		y -= cameraFollowPointer.height / 2;
		cameraFollowPointer.setPosition(x, y);
	}

    function getCharacterList()
    {
        characterList = [];

        for(json in jsons)
        {
            characterList.push(json);
        }

        trace(characterList);
    }

    function create_UI()
    {
        uiBase = new FlxUI(null, null);
        var uiBox = new FlxUITabMenu(null, [], false);

        uiBox.resize(300, 540);
        uiBox.x = (FlxG.width - uiBox.width) - 20;
        uiBox.y = 10;
        uiBox.scrollFactor.set();
        uiBox.cameras = [hudCam];

        var charName:FlxText = new FlxText(uiBox.x + 10, 20, 0, "Character Name");
        var animationGhost:FlxText = new FlxText(charName.x + 60, 20, 0, "Animation Ghost");

        charNamePos = [];
        charNamePos.push(charName.x);
        charNamePos.push(charName.y);

        trace(charNamePos);

        var swagCharXBox:FlxUINumericStepper;
        var swagCharYBox:FlxUINumericStepper;
        var swagScaleBox:FlxUINumericStepper;

        var swagCamXBox:FlxUINumericStepper;
        var swagCamYBox:FlxUINumericStepper;

        var swagCustomIconTextBox:FlxUIInputText;

        var charNameTextBox:FlxUIInputText = new FlxUIInputText(charName.x, charName.y + 20, 100, curChar, 8);
        charNameBox = charNameTextBox;

        var loadCharBTN:FlxButton = new FlxButton(charName.x + (charNameTextBox.width + 10), charNameTextBox.y, "Load Character", function(){
            var charToLoad:String = charNameTextBox.text;

            character.loadCharacter(charToLoad, true);
            characterGhost.loadCharacter(charToLoad, true);

            character.x = PlayState.characterPositions[1][0];
            character.y = PlayState.characterPositions[1][1];
    
            character.x += character.position[0];
            character.y += character.position[1];

            if(swagCharXBox != null)
            {
                swagCharXBox.value = character.position[0];
                swagCharYBox.value = character.position[1];
            }

            if(swagCamXBox != null)
            {
                swagCamXBox.value = character.camOffsets[0];
                swagCamYBox.value = character.camOffsets[1];
            }

            if(swagScaleBox != null)
                swagScaleBox.value = character.json.scale;

            updateCharacter();

            updateAnimList();

            changeAnim();

            //reloadCharListMenu();

            curChar = character.name;

            refreshDiscordRPC();
            refreshAppTitle();

            swagCustomIconTextBox.text = curChar;
            
            healthBar.createFilledBar(character.healthColor, character.healthColor);

            healthColor[0] = character.json.healthbar_colors[0];
            healthColor[1] = character.json.healthbar_colors[1];
            healthColor[2] = character.json.healthbar_colors[2];

            noAntialiasingBox.checked = character.antialiasing;
        });

        charListMenu = new CustomDropdown(charName.x, charName.y + 20, CustomDropdown.makeStrIdLabelArray(characterList, true), function(id:String){
            var charToLoad:String = characterList[Std.parseInt(id)];
            character.loadCharacter(charToLoad);
            characterGhost.loadCharacter(charToLoad);

            character.x = PlayState.characterPositions[1][0];
            character.y = PlayState.characterPositions[1][1];
    
            character.x += character.position[0];
            character.y += character.position[1];

            if(swagCharXBox != null)
            {
                swagCharXBox.value = character.position[0];
                swagCharYBox.value = character.position[1];
            }

            if(swagCamXBox != null)
            {
                swagCamXBox.value = character.camOffsets[0];
                swagCamYBox.value = character.camOffsets[1];
            }

            if(swagScaleBox != null)
                swagScaleBox.value = character.json.scale;

            updateCharacter();

            updateAnimList();

            changeAnim();

            //reloadCharListMenu();

            curChar = charToLoad;

            refreshDiscordRPC();
            refreshAppTitle();

            swagCustomIconTextBox.text = curChar;
            
            healthBar.createFilledBar(character.healthColor, character.healthColor);

            healthColor[0] = character.json.healthbar_colors[0];
            healthColor[1] = character.json.healthbar_colors[1];
            healthColor[2] = character.json.healthbar_colors[2];

            noAntialiasingBox.checked = character.antialiasing;
        });

        var charNameWarn:FlxText = new FlxText(charName.x, charName.y + 40, 0, "Click \"Save Character\" to save your current character.");

        var charFlipBox:FlxUICheckBox = new FlxUICheckBox(charName.x, charNameWarn.y + 20, null, null, "Flip Character Horizontally", 250);
        charFlipBox.checked = character.flipX;

        charFlipBox.callback = function()
        {
            character.flipX = charFlipBox.checked;
            characterGhost.flipX = charFlipBox.checked;

            if(playerChar)
            {
                character.flipX = !character.flipX;
                characterGhost.flipX = !characterGhost.flipX;
            }
        };

        var charLoopAnimBox:FlxUICheckBox = new FlxUICheckBox(charName.x, charFlipBox.y + 20, null, null, "Loop Animation", 250);
        charLoopAnimBox.checked = character.animation.curAnim.looped;

        charLoopAnimBox.callback = function()
        {
            var animationName:String = animList[curAnim];
            var animationName2:String = prefixList[curAnim];

            loopList[curAnim] = charLoopAnimBox.checked;

            character.animation.addByPrefix(animationName, animationName2, Std.int(character.animation.curAnim.frameRate), charLoopAnimBox.checked);
            character.playAnim(animationName);

            character.anims[curAnim].loop = charLoopAnimBox.checked;

            updateAnimList();
        };

        loopAnimBox = charLoopAnimBox;

        var animNameText:FlxText = new FlxText(charName.x, charLoopAnimBox.y + 20, 0, "Animation Name");

        var animNameTextBox:FlxUIInputText = new FlxUIInputText(charName.x, animNameText.y + 20, 100, "idle", 8);
        animNameBox = animNameTextBox;

        var prefixNameText:FlxText = new FlxText(charName.x, animNameTextBox.y + 20, 0, "Animation Name in .XML file");

        var animPrefixTextBox:FlxUIInputText = new FlxUIInputText(charName.x, prefixNameText.y + 20, 100, "placeholder idle", 8);
        animPrefixBox = animPrefixTextBox;

        var animNameTextWarn:FlxText = new FlxText(charName.x, animPrefixTextBox.y + 20, 0, "Type an animation name in the text field above and\npress \"Add/Update\" to add the anim.\n\nPress \"Remove\" to remove the animation typed in\nthe \"Animation Name\" text field.");

        var addAnimBTN:FlxButton = new FlxButton(charName.x, animNameTextWarn.y + 60, "Add/Update", function(){
            if(!animList.contains(animNameTextBox.text))
            {
                character.animation.addByPrefix(animNameTextBox.text, animPrefixTextBox.text, 24, charLoopAnimBox.checked);

                character.anims.push(
                    {
                        "loop": charLoopAnimBox.checked,
                        "offsets": [
                            0,
                            0
                        ],
                        "anim": animNameTextBox.text,
                        "fps": 24,
                        "name": animPrefixTextBox.text,
                        "indices": []
                    }
                );

                character.offsetMap.set(animNameTextBox.text, [0, 0]);

                trace(character.anims);
                trace("!!!!! OFFSET MAP !!!!!: " + character.offsetMap);

                updateCharacter();

                curAnim = animList.length - 1;

                updateAnimList();

                character.playAnim(animNameTextBox.text, true);
            }
            else
            {
                character.animation.addByPrefix(animNameTextBox.text, animPrefixTextBox.text, 24, charLoopAnimBox.checked);

                var funny:Int = character.anims.indexOf(animNameTextBox.text);
                trace("!!!!! INDEX OF [" + animNameTextBox.text + "]: " + funny);
                character.anims[curAnim].name = animPrefixTextBox.text;

                curAnim = animList.indexOf(animNameTextBox.text);

                updateCharacter();
                updateAnimList();

                character.playAnim(animNameTextBox.text, true);
            }
        });

        var removeAnimBTN:FlxButton = new FlxButton(charName.x + (addAnimBTN.width + 10), addAnimBTN.y, "Remove", function(){
            if(animList.length > 1)
            {
                var balls:Int = animList.indexOf(animNameTextBox.text);

                if(animList.contains(animNameTextBox.text))
                {
                    character.animation.remove(animNameTextBox.text);
                    character.anims.remove(character.anims[balls]);

                    animList.remove(animList[balls]);
                    prefixList.remove(prefixList[balls]);
                    animOffsets.remove(animOffsets[balls]);
                    loopList.remove(loopList[balls]);

                    curAnim = 0;
                    changeAnim();

                    character.playAnim(animList[0]);

                    updateAnimList();
                }

                trace(animList);
            }
        });

        var charXYText:FlxText = new FlxText(charName.x, removeAnimBTN.y + 20, 0, "Character X & Y");

        swagCharXBox = new FlxUINumericStepper(charName.x, charXYText.y + 20, 10, 0, -9999, 9999);
        swagCharXBox.value = character.position[0];
        swagCharXBox.name = "Character_X";
        charXBox = swagCharXBox;

        swagCharYBox = new FlxUINumericStepper(charName.x + (swagCharXBox.width + 20), swagCharXBox.y, 10, 0, -9999, 9999);
        swagCharYBox.value = character.position[1];
        swagCharYBox.name = "Character_Y";
        charYBox = swagCharYBox;

        var scaleText:FlxText = new FlxText(charName.x, swagCharYBox.y + 20, 0, "Character Size");
        
        swagScaleBox = new FlxUINumericStepper(charName.x, scaleText.y + 20, 0.1, 1, 0.05, 10, 1);
        swagScaleBox.value = character.json.scale;
        swagScaleBox.name = "Character_Scale";
        scaleBox = swagScaleBox;

        var customIconText:FlxText = new FlxText(charName.x, swagScaleBox.y + 20, 0, "Custom Icon (Add a file in \"mods/ur mod/characters/\nimages/ur icon name\"called \"icons.png\" for this to work)\n");

        swagCustomIconTextBox = new FlxUIInputText(charName.x, customIconText.y + 30, 100, curChar, 8);
        customIconTextBox = swagCustomIconTextBox;

        var healthBarColorText:FlxText = new FlxText(charName.x, swagCustomIconTextBox.y + 20, 0, "Health Bar Color");

        var healthBarColorStepper1 = new FlxUINumericStepper(charName.x, healthBarColorText.y + 20, 10, 0, 0, 255);
        healthBarColorStepper1.value = healthColor[0];
        healthBarColorStepper1.name = "Health1";

        var healthBarColorStepper2 = new FlxUINumericStepper(charName.x + (healthBarColorStepper1.width + 20), healthBarColorStepper1.y, 10, 0, 0, 255);
        healthBarColorStepper2.value = healthColor[1];
        healthBarColorStepper2.name = "Health2";

        var healthBarColorStepper3 = new FlxUINumericStepper(healthBarColorStepper2.x + (healthBarColorStepper2.width + 20), healthBarColorStepper1.y, 10, 0, 0, 255);
        healthBarColorStepper3.value = healthColor[2];
        healthBarColorStepper3.name = "Health3";

		var iconColorBTN:FlxButton = new FlxButton(charName.x, healthBarColorStepper3.y + 20, "Grab Icon Color", function()
        {
            var swagColor:FlxColor = FlxColor.fromInt(Util.dominantColor(icons.members[1]));
            healthBarColorStepper1.value = swagColor.red;
            healthBarColorStepper2.value = swagColor.green;
            healthBarColorStepper3.value = swagColor.blue;
            getEvent(FlxUINumericStepper.CHANGE_EVENT, healthBarColorStepper1, null);
            getEvent(FlxUINumericStepper.CHANGE_EVENT, healthBarColorStepper2, null);
            getEvent(FlxUINumericStepper.CHANGE_EVENT, healthBarColorStepper3, null); 
        });

        var cameraPosText:FlxText = new FlxText(charName.x, iconColorBTN.y + 20, 0, "Camera Pos");

        swagCamXBox = new FlxUINumericStepper(charName.x, cameraPosText.y + 20, 10, 0, -9999, 9999);
        swagCamXBox.value = character.camOffsets[0];
        swagCamXBox.name = "Cam_X";
        camXBox = swagCamXBox;

        swagCamYBox = new FlxUINumericStepper(charName.x + (swagCharXBox.width + 20), swagCamXBox.y, 10, 0, -9999, 9999);
        swagCamYBox.value = character.camOffsets[1];
        swagCamYBox.name = "Cam_Y";
        camYBox = swagCamYBox;

        var swagNoAntialiasingBox:FlxUICheckBox = new FlxUICheckBox(charName.x, swagCamXBox.y + 20, null, null, "No Anti-Aliasing", 250);
        swagNoAntialiasingBox.checked = !character.antialiasing;

        swagNoAntialiasingBox.callback = function()
        {
            character.antialiasing = !swagNoAntialiasingBox.checked;
        };

        noAntialiasingBox = swagNoAntialiasingBox;

        var playerCharBox:FlxUICheckBox = new FlxUICheckBox(charName.x, swagNoAntialiasingBox.y + 20, null, null, "Is Player Character", 250);
        playerCharBox.checked = playerChar;

        playerCharBox.callback = function()
        {
            playerChar = playerCharBox.checked;
            character.flipX = !character.flipX;
        };

        var saveCharBTN:FlxButton = new FlxButton(loadCharBTN.x + (loadCharBTN.width + 10), loadCharBTN.y, "Save Character", function(){
            // will do soon ok
            setCharData();
            saveCharJSON();
        });

        // adding the shit
        uiBase.add(uiBox);
        
        // setting scroll factor
        charName.scrollFactor.set();
        charName.cameras = [hudCam];

        charNameTextBox.scrollFactor.set();
        charNameTextBox.cameras = [hudCam];

        charNameWarn.scrollFactor.set();
        charNameWarn.cameras = [hudCam];

        animNameText.scrollFactor.set();
        animNameTextBox.cameras = [hudCam];

        prefixNameText.scrollFactor.set();
        prefixNameText.cameras = [hudCam];

        animPrefixTextBox.scrollFactor.set();
        animPrefixTextBox.cameras = [hudCam];

        animNameTextWarn.scrollFactor.set();
        animNameTextWarn.cameras = [hudCam];

        customIconText.scrollFactor.set();
        customIconText.cameras = [hudCam];

        swagCustomIconTextBox.scrollFactor.set();
        swagCustomIconTextBox.cameras = [hudCam];

        charXYText.scrollFactor.set();
        charXYText.cameras = [hudCam];

        scaleText.scrollFactor.set();
        scaleText.cameras = [hudCam];

        healthBarColorText.scrollFactor.set();
        healthBarColorText.cameras = [hudCam];

        cameraPosText.scrollFactor.set();
        cameraPosText.cameras = [hudCam];

        saveCharBTN.scrollFactor.set();
        saveCharBTN.cameras = [hudCam];

        loadCharBTN.scrollFactor.set();
        loadCharBTN.cameras = [hudCam];

        addAnimBTN.scrollFactor.set();
        addAnimBTN.cameras = [hudCam];

        removeAnimBTN.scrollFactor.set();
        removeAnimBTN.cameras = [hudCam];

        iconColorBTN.scrollFactor.set();
        iconColorBTN.cameras = [hudCam];

        charFlipBox.scrollFactor.set();
        charFlipBox.cameras = [hudCam];

        charLoopAnimBox.scrollFactor.set();
        charLoopAnimBox.cameras = [hudCam];

        swagNoAntialiasingBox.scrollFactor.set();
        swagNoAntialiasingBox.cameras = [hudCam];

        playerCharBox.scrollFactor.set();
        playerCharBox.cameras = [hudCam];

        swagCharXBox.scrollFactor.set();
        swagCharXBox.cameras = [hudCam];

        swagCharYBox.scrollFactor.set();
        swagCharYBox.cameras = [hudCam];

        swagCamXBox.scrollFactor.set();
        swagCamXBox.cameras = [hudCam];

        swagCamYBox.scrollFactor.set();
        swagCamYBox.cameras = [hudCam];

        healthBarColorStepper1.scrollFactor.set();
        healthBarColorStepper1.cameras = [hudCam];

        healthBarColorStepper2.scrollFactor.set();
        healthBarColorStepper2.cameras = [hudCam];

        healthBarColorStepper3.scrollFactor.set();
        healthBarColorStepper3.cameras = [hudCam];

        // TEXT/TEXTBOXES
        uiBase.add(charName);
        uiBase.add(charNameTextBox);
        uiBase.add(charNameWarn);

        uiBase.add(animNameText);
        uiBase.add(animNameTextBox);

        uiBase.add(prefixNameText);
        uiBase.add(animPrefixTextBox);

        uiBase.add(animNameTextWarn);
        uiBase.add(customIconText);
        
        uiBase.add(swagCustomIconTextBox);

        uiBase.add(charXYText);
        uiBase.add(scaleText);
        uiBase.add(healthBarColorText);
        uiBase.add(cameraPosText);

        // BUTTONS
        uiBase.add(saveCharBTN);
        uiBase.add(loadCharBTN);

        uiBase.add(addAnimBTN);
        uiBase.add(removeAnimBTN);

        uiBase.add(iconColorBTN);

        // CHECKBOXES
        uiBase.add(charFlipBox);
        uiBase.add(charLoopAnimBox);
        uiBase.add(swagNoAntialiasingBox);
        uiBase.add(playerCharBox);

        // STEPPERS
        uiBase.add(swagCharXBox);
        uiBase.add(swagCharYBox);

        uiBase.add(swagCamXBox);
        uiBase.add(swagCamYBox);
        uiBase.add(swagScaleBox);

        uiBase.add(healthBarColorStepper1);
        uiBase.add(healthBarColorStepper2);
        uiBase.add(healthBarColorStepper3);

        // DROPDOWNS
        //uiBase.add(charListMenu);

        // add the shit
        uiGroup.add(uiBase);
    }

    function reloadCharListMenu()
    {
        charListMenu.setData(CustomDropdown.makeStrIdLabelArray(characterList, true));
    }

    function loadChar(?char:String = "bf")
    {
        var curCharX:Float = character.x;
        var curCharY:Float = character.y;
        
        character = new Character(curCharX, curCharY, char, true);
        characterGhost = new Character(curCharX, curCharY, char, true);
    }

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
    {
        if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
        {
            var nums:FlxUINumericStepper = cast sender;
            var wname = nums.name;
            FlxG.log.add(wname);

            switch(wname)
            {
                case 'Character_X':
                    character.position[0] = Std.int(nums.value);
                case 'Character_Y':
                    character.position[1] = Std.int(nums.value);
                case 'Character_Scale':
                    character.setGraphicSize(Std.int(character.frameWidth * nums.value));
                    character.updateHitbox();

                    if(character.animation.curAnim != null) {
                        character.playAnim(character.animation.curAnim.name, true);
                    }

                    characterGhost.setGraphicSize(Std.int(characterGhost.frameWidth * nums.value));
                    characterGhost.updateHitbox();

                    if(characterGhost.animation.curAnim != null) {
                        characterGhost.playAnim(characterGhost.animation.curAnim.name, true);
                    }
                case 'Health1':
                    healthColor[0] = Std.int(nums.value);

                    var healthColorLol = FlxColor.fromRGB(healthColor[0], healthColor[1], healthColor[2]);
                    healthBar.createFilledBar(healthColorLol, healthColorLol);
                case 'Health2':
                    healthColor[1] = Std.int(nums.value);

                    var healthColorLol = FlxColor.fromRGB(healthColor[0], healthColor[1], healthColor[2]);
                    healthBar.createFilledBar(healthColorLol, healthColorLol);
                case 'Health3':
                    healthColor[2] = Std.int(nums.value);

                    var healthColorLol = FlxColor.fromRGB(healthColor[0], healthColor[1], healthColor[2]);
                    healthBar.createFilledBar(healthColorLol, healthColorLol);
                case 'Cam_X':
                    character.camOffsets[0] = Std.int(nums.value);
                    updatePointerPos();
                case 'Cam_Y':
                    character.camOffsets[1] = Std.int(nums.value);
                    updatePointerPos();
            }
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        curAnimText.text = animList[curAnim];
        curAnimText.screenCenter(X);

        character.x = PlayState.characterPositions[1][0];
        character.y = PlayState.characterPositions[1][1];

        character.x += character.position[0];
        character.y += character.position[1];

        characterGhost.setPosition(character.x, character.y);

        characterGhost.offset.set(0, 0);

        if(animList.contains("danceLeft"))
            characterGhost.offset.set(animOffsets[animList.indexOf("danceLeft")][0], animOffsets[animList.indexOf("danceLeft")][1]);
        else if(animList.contains("idle"))
            characterGhost.offset.set(animOffsets[animList.indexOf("idle")][0], animOffsets[animList.indexOf("idle")][1]);

        for(i in 0...icons.members.length)
        {
            icons.members[i].loadIcon(Util.getCharacterIcons(customIconTextBox.text), icons.members[i].isPlayer);

            switch(i)
            {
                case 0:
                    icons.members[i].animation.play("dead");
                case 1:
                    icons.members[i].animation.play("default");
                case 2:
                    icons.members[i].animation.play("winning");
            }
        }

		var inputTexts:Array<FlxUIInputText> = [charNameBox, animNameBox, animPrefixBox, customIconTextBox];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = TitleScreenState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleScreenState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleScreenState.volumeUpKeys;

        if(FlxG.keys.justPressed.ESCAPE)
            transitionState(new OptionsState());

        var leftP = FlxG.keys.pressed.J;
        var downP = FlxG.keys.pressed.K;
        var upP = FlxG.keys.pressed.I;
        var rightP = FlxG.keys.pressed.L;

        var left = FlxG.keys.justPressed.LEFT;
        var down = FlxG.keys.justPressed.DOWN;
        var up = FlxG.keys.justPressed.UP;
        var right = FlxG.keys.justPressed.RIGHT;
        var shiftP = FlxG.keys.pressed.SHIFT;

        var offsetMultiplier:Float = 0;

        var camVelocity:Float = 190;

        if (FlxG.keys.justPressed.E)
        {
            FlxG.camera.zoom += 0.1;

            if(FlxG.camera.zoom > 10)
                FlxG.camera.zoom = 10;
        }

        if (FlxG.keys.justPressed.Q)
        {
            FlxG.camera.zoom -= 0.1;

            if(FlxG.camera.zoom < 0.1)
                FlxG.camera.zoom = 0.1;
        }

        if(upP || leftP || downP || rightP)
        {
            if(upP)
                camFollow.velocity.y = camVelocity * -1;
            else if (downP)
                camFollow.velocity.y = camVelocity;
            else
                camFollow.velocity.y = 0;

            if(leftP)
                camFollow.velocity.x = camVelocity * -1;
            else if(rightP)
                camFollow.velocity.x = camVelocity;
            else
                camFollow.velocity.x = 0;
        }
        else
            camFollow.velocity.set();

        if(FlxG.keys.justPressed.W)
            changeAnim(-1);

        if(FlxG.keys.justPressed.S)
            changeAnim(1);

        if(FlxG.keys.justPressed.SPACE)
            character.playAnim(animList[curAnim], true, null, null, animOffsets[curAnim][0], animOffsets[curAnim][1]);

        if(up || left || down || right)
        {
            if(shiftP)
                offsetMultiplier = 18;
            else
                offsetMultiplier = 1;

            if(up)
                offsetY += offsetMultiplier;
            else if(down)
                offsetY -= offsetMultiplier;
            else if(left)
                offsetX += offsetMultiplier;
            else if(right)
                offsetX -= offsetMultiplier;

            character.offset.set(offsetX, offsetY);

            trace("Before Offset Change: [" + animOffsets[curAnim][0] + ", " + animOffsets[curAnim][1] + "]");

            animOffsets[curAnim][0] = offsetX;
            animOffsets[curAnim][1] = offsetY;

            trace("After Offset Change: [" + animOffsets[curAnim][0] + ", " + animOffsets[curAnim][1] + "]");

            updateAnimList();
        }
    }

    function refreshDiscordRPC()
    {
        #if discord_rpc
        DiscordRPC.changePresence("In Character Editor - Editing " + curChar, null);
        #end
    }

    function changeAnim(?change:Int = 0)
    {
        curAnim += change;

        if(curAnim < 0)
            curAnim = animList.length - 1;

        if(curAnim > animList.length - 1)
            curAnim = 0;

        updateAnimList();
        
        loopAnimBox.checked = loopList[curAnim];

        character.playAnim(animList[curAnim], true, null, null, animOffsets[curAnim][0], animOffsets[curAnim][1]);

        offsetX = character.offset.x;
        offsetY = character.offset.y;
    }

    function refreshAppTitle()
    {
        BasicState.changeAppTitle(Util.engineName, "Character Editor - Editing Character: " + curChar);
    }

    function updateCharacter()
    {
        curChar = character.name;

        refreshDiscordRPC();
        refreshAppTitle();

        animList = [];
        prefixList = [];
        loopList = [];
        animOffsets = [];

        for(i in 0...character.anims.length)
        {
            animList.push(character.anims[i].anim);
            prefixList.push(character.anims[i].name);
            loopList.push(character.anims[i].loop);
            trace([character.offsetMap[character.anims[i].anim][0], character.offsetMap[character.anims[i].anim][1]]);
            animOffsets.push([character.offsetMap[character.anims[i].anim][0], character.offsetMap[character.anims[i].anim][1]]);
        }

        trace(animList);
        trace(prefixList);
        trace(loopList);
        trace(animOffsets);

        updatePointerPos();
    }

    function setCharData()
    {
        charData = [{
            "animations": [],
            "no_antialiasing": character.antialiasing,
            "position": [
                character.position[0],
                character.position[1]
            ],
            "healthicon": customIconTextBox.text,
            "flip_x": character.flipX,
            "healthbar_colors": [
                healthColor[0],
                healthColor[1],
                healthColor[2],
            ],
            "camera_position": [
                character.camOffsets[0],
                character.camOffsets[1]
            ],
            "sing_duration": 6.1, // unused but kept just in case someone wants to add this
            "scale": scaleBox.value
        }];

        for(i in 0...character.anims.length)
        {
            character.anims[i].offsets = [animOffsets[i][0], animOffsets[i][1]];
            charData[0].animations.push(character.anims[i]);
        }

        trace("!!!!! CHAR DATA !!!!!: " + charData);
        trace("!!!!! CHAR DATA ANIMATIONS !!!!!: " + charData[0].animations);
    }

    function updateAnimList()
    {
        var fuckYou:String = "";
        var fuckYou2:String = "";

        for(i in 0...animList.length)
        {
            if(animList[curAnim] == animList[i])
                fuckYou2 = "> ";
            else
                fuckYou2 = "";
            
            fuckYou += fuckYou2 + animList[i] + " [" + animOffsets[i][0] + ", " + animOffsets[i][1] + "]\n";
        }

        animListText.text = fuckYou;

        updatePointerPos();
    }

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}

    var _file:FileReference;

    private function saveCharJSON()
    {
        var data:String = Json.stringify(charData[0], null, "\t");

        if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

            _file.save(data.trim(), '$curChar.json');
        }
    }

    function onSaveComplete(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        trace("Successfully saved character data.");
    }

    function onSaveCancel(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    function onSaveError(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        trace("Problem saving character data");
    }
}