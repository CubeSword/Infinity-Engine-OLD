package game;

import flixel.text.FlxText;
import ui.Icon;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
#if lua_allowed
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import flixel.FlxSprite;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import llua.Lua.Lua_helper;
import flixel.FlxG;
import game.Conductor;
import lime.app.Application;

using StringTools;

class LuaHandler
{
    var genericTitle:String = "Infinity Engine Modcharts";

    public var variables:Map<String, Dynamic> = [];
    public var lua:State = null;

    public static var lua_Sprites:Map<String, Dynamic> = [
        'player' => PlayState.player,
        'speakers' => PlayState.speakers,
        'opponent' => PlayState.opponent,
    ];

    public static var lua_Characters:Map<String, CharacterGroup> = [
        'player' => PlayState.player,
        'speakers' => PlayState.speakers,
        'opponent' => PlayState.opponent,
    ];

    public static var lua_Sounds:Map<String, FlxSound> = [];

    function getObjectByName(id:String):Dynamic
    {
        // lua objects or what ever
        if(!lua_Sprites.exists(id))
        {
            if(Std.parseInt(id) == null)
                return Reflect.getProperty(PlayState.instance, id);

            @:privateAccess
            return PlayState.strumLineNotes.members[Std.parseInt(id)];
        }

        return lua_Sprites.get(id);
    }

    function getCharacterByName(id:String):Dynamic
    {
        // lua objects or what ever
        if(lua_Characters.exists(id))
            return lua_Characters.get(id);
        else
            return null;
    }

    public function die()
    {
        PlayState.songMultiplier = oldMultiplier;

        Lua.close(lua);
        lua = null;
    }

    function getLuaErrorMessage(l) {
        var v:String = Lua.tostring(l, -1);
        Lua.pop(l, 1);

        return v;
    }

    function callLua(func_name : String, args : Array<Dynamic>, ?type : String) : Dynamic
    {
        var result : Any = null;

        Lua.getglobal(lua, func_name);

        for( arg in args ) {
            Convert.toLua(lua, arg);
        }

        result = Lua.pcall(lua, args.length, 1, 0);

        var p = Lua.tostring(lua, result);
        var e = getLuaErrorMessage(lua);

        if (e != null)
        {
            if (p != null)
            {
                /*
                Application.current.window.alert("LUA ERROR:\n" + p + "\nhaxe things: " + e,"Infinity Engine Modcharts");
                lua = null; 
                LoadingState.loadAndSwitchState(new MainMenuState());
                */
            }
        }

        if( result == null) {
            return null;
        } else {
            return convert(result, type);
        }
    }

    public function setVar(var_name:String, object:Dynamic)
    {
        if(Std.isOfType(object, Bool))
            Lua.pushboolean(lua, object);
        else if(Std.isOfType(object, String))
            Lua.pushstring(lua, object);
        else
            Lua.pushnumber(lua, object);

        Lua.setglobal(lua, var_name);
    }

    var oldMultiplier:Float = PlayState.songMultiplier;

    function new(?path:Null<String>)
    {
        trace("ass");
        
        oldMultiplier = PlayState.songMultiplier;
        
        lua_Sprites.set("player", PlayState.player);
        lua_Sprites.set("speakers", PlayState.speakers);
        lua_Sprites.set("opponent", PlayState.opponent);

        lua_Characters.set("player", PlayState.opponent);
        lua_Characters.set("speakers", PlayState.speakers);
        lua_Characters.set("opponent", PlayState.opponent);

        lua_Sounds.set("Inst", FlxG.sound.music);
        lua_Sounds.set("Voices", PlayState.instance.vocals);

        lua = LuaL.newstate();
        LuaL.openlibs(lua);

        trace("lua version: " + Lua.version());
        trace("LuaJIT version: " + Lua.versionJIT());

        Lua.init_callbacks(lua);

        if(path == null)
            path = Util.getPath("songs/" + PlayState.storedSong + "/script.lua");

        var result = LuaL.dofile(lua, path); // execute le file

        if (result != 0)
        {
            Application.current.window.alert("lua COMPILE ERROR:\n" + Lua.tostring(lua,result), genericTitle);
        }

        // setting sum globals
        setVar("difficulty", PlayState.storedDifficulty);
        setVar("bpm", Conductor.bpm);
        setVar("songBpm", PlayState.song.bpm);
        setVar("songName", PlayState.storedSong);
        setVar("difficulty", PlayState.storedDifficulty);
        setVar("keyCount", PlayState.song.keyCount);
        setVar("scrollSpeed", PlayState.instance.speed);
        setVar("fpsCap", Options.getData("fpsCap"));
        setVar("botplay", Options.getData("botplay"));
        setVar("downscroll", Options.getData("downscroll"));
        setVar("cameraZooms", Options.getData("camera-zooms"));
        setVar("inGameOver", PlayState.instance.isDead);

        setVar("curStep", 0);
        setVar("curBeat", 0);
        setVar("crochet", Conductor.stepCrochet);
        setVar("safeZoneOffset", Conductor.safeZoneOffset);

        setVar("hudZoom", PlayState.instance.hudCam.zoom);
        setVar("cameraZoom", FlxG.camera.zoom);
        setVar("cameraAngle", FlxG.camera.angle);
        setVar("hudCamAngle", PlayState.instance.hudCam.angle);

        setVar("screenWidth", lime.app.Application.current.window.display.currentMode.width);
        setVar("screenHeight", lime.app.Application.current.window.display.currentMode.height);
        setVar("windowWidth", FlxG.width);
        setVar("windowHeight", FlxG.height);

        // we addin sum callbacks

        Lua_helper.add_callback(lua,"call", function(v:String, ?resultName:String, ?args:Array<Dynamic>):Dynamic {
            if (args == null) args = [];
            var splittedVar = v.split(".");
            if (splittedVar.length == 0) return false;
            var currentObj = variables[splittedVar[0]];
            for (i in 1...splittedVar.length - 1) {
                var property = Reflect.getProperty(currentObj, splittedVar[i]);
                if (property != null) {
                    currentObj = property;
                } else {
                    trace('Variable $v doesn\'t exist or is equal to null.');
                    return false;
                }
            }
            var func = Reflect.getProperty(currentObj, splittedVar[splittedVar.length - 1]);

            var finalArgs = [];
            for (a in args) {
                if (Std.isOfType(a, String)) {
                    var str = cast(a, String);
                    if (str.startsWith("${") && str.endsWith("}")) {
                        var st = str.substr(2, str.length - 3);
                        trace(st);
                        var v = getVarAlt(st);
                        if (v != null) {
                            finalArgs.push(v);
                        } else {
                            finalArgs.push(a);
                        }
                    } else {
                        finalArgs.push(a);
                    }
                } else {
                    finalArgs.push(a);
                }
            }
            if (func != null) {
                var result = null;
                try {
                    result = Reflect.callMethod(null, func, finalArgs);
                } catch(e) {
                    trace('$e');
                }
                if (resultName == null) {
                    return result;
                } else {
                    variables[resultName] = result;
                    return '$' + resultName;
                }
            } else {
                trace('Function $v doesn\'t exist or is equal to null.');
                return false;
            }
        });

        Lua_helper.add_callback(lua,"openURL", function(url:String = "https://www.google.com") {
            if(Options.getData("allow-lua-openurls"))
                Util.openURL(url);
        });

        Lua_helper.add_callback(lua,"getOption", function(save:String) {
            return Options.getData(save);
        });

        Lua_helper.add_callback(lua, "saveOption", function(save:String, value:String, ?flush:Bool = true) {
            Options.saveData(save, value);
        });

        Lua_helper.add_callback(lua,"setObjectCamera", function(id:String, camera:String = "") {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
                Reflect.setProperty(object, "cameras", [cameraFromString(camera)]);
        });

        Lua_helper.add_callback(lua,"getObjectOrder", function(id:String) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                return getInstance().members.indexOf(object);
            }
            
            // yo dumbass your object doesn't exist!
            trace("Object: " + object + " doesn't exist!");
            return -1;
        });

        Lua_helper.add_callback(lua,"setObjectOrder", function(id:String, order:Int = 0) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                getInstance().remove(object);
                getInstance().insert(order, object);
                return;
            }
            
            // yo dumbass your object doesn't exist!
            trace("Object: " + object + " doesn't exist!");
        });

        Lua_helper.add_callback(lua,"screenCenter", function(id:String, ?axis:String = "XY") {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                switch(axis)
                {
                    case 'X':
                        object.screenCenter(X);
                    case 'Y':
                        object.screenCenter(Y);
                    default:
                        object.screenCenter(XY);
                }
                return;
            }
            
            // yo dumbass your object doesn't exist!
            trace("Object: " + object + " doesn't exist!");
        });

        Lua_helper.add_callback(lua,"setGraphicSize", function(id:String, width:Int = 0, height:Int = 0) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
                object.setGraphicSize(width, height);
        });

        Lua_helper.add_callback(lua,"updateHitbox", function(id:String) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
                object.updateHitbox();
        });

        Lua_helper.add_callback(lua, "setBlendMode", function(id:String, blend:String = '') {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
                object.blend = blendModeFromString(blend);
		});

        Lua_helper.add_callback(lua,"makeStageSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1, front:Bool = false) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:StageSprite = new StageSprite(x, y);
                Sprite.isNormalSprite = true;

                @:privateAccess
                if(filename != null && filename.length > 0)
                    Sprite.loadGraphic(Util.getImage("stages/" + PlayState.instance.stage.megaCoolPoggersStage + "/" + filename, false));

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                /*@:privateAccess
                if(!front)
                    PlayState.instance.stage.add(Sprite);
                else
                    PlayState.instance.stageFront.add(Sprite);*/
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", genericTitle);
        });

        Lua_helper.add_callback(lua,"makeStageAnimatedSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1, front:Bool = false) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:StageSprite = new StageSprite(x, y);

                @:privateAccess
                Sprite.frames = Util.getSparrow(PlayState.instance.stage.megaCoolPoggersStage + "/" + filename, false);

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                /*@:privateAccess
                if(!front)
                    PlayState.instance.stage.add(Sprite);
                else
                    PlayState.instance.stageFront.add(Sprite);*/
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", genericTitle);
        });

        Lua_helper.add_callback(lua,"makeSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxSprite = new FlxSprite(x, y);

                if(filename != null && filename.length > 0)
                    Sprite.loadGraphic(Util.getImage(filename));

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                //PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", genericTitle);
        });

        Lua_helper.add_callback(lua,"makeAnimatedSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxSprite = new FlxSprite(x, y);

                Sprite.frames = Util.getSparrow(filename);

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                //PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", genericTitle);
        });

		Lua_helper.add_callback(lua, "addStageSprite", function(id:String, front:Bool = false) {
            var Sprite:StageSprite = lua_Sprites.get(id);

            if (Sprite == null)
                return false;

            if(front)
                PlayState.instance.stageFront.add(Sprite);
            else
            {
                if(!PlayState.instance.isDead)
                {
                    var position:Int = PlayState.instance.members.indexOf(PlayState.speakers);
                    if(PlayState.instance.members.indexOf(PlayState.player) < position)
                        position = PlayState.instance.members.indexOf(PlayState.player);
                    else if(PlayState.instance.members.indexOf(PlayState.opponent) < position)
                        position = PlayState.instance.members.indexOf(PlayState.opponent);

                    PlayState.instance.stage.insert(position, Sprite);
                }
            }
            
            return true;
		});

		Lua_helper.add_callback(lua, "addSprite", function(id:String, front:Bool = false) {
            var Sprite:FlxSprite = lua_Sprites.get(id);

            if (Sprite == null)
                return false;

            if(front)
                PlayState.instance.add(Sprite);
            else
            {
                if(PlayState.instance.isDead)
                {
                    GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.player), Sprite);
                }
                else
                {
                    var position:Int = PlayState.instance.members.indexOf(PlayState.speakers);
                    if(PlayState.instance.members.indexOf(PlayState.player) < position)
                        position = PlayState.instance.members.indexOf(PlayState.player);
                    else if(PlayState.instance.members.indexOf(PlayState.opponent) < position)
                        position = PlayState.instance.members.indexOf(PlayState.opponent);

                    PlayState.instance.insert(position, Sprite);
                }
            }

            return true;
		});

        Lua_helper.add_callback(lua, "removeStageSprite", function(id:String, ?front:Bool = false) {
            var sprite = lua_Sprites.get(id);

            if (sprite == null)
                return false;

            lua_Sprites.remove(id);

            if(front)
                PlayState.instance.stage.remove(sprite);
            else
                PlayState.instance.stageFront.remove(sprite);

            sprite.kill();
            sprite.destroy();

            return true;
        });

        Lua_helper.add_callback(lua, "removeSprite", function(id:String) {
            var sprite = lua_Sprites.get(id);

            if (sprite == null)
                return false;

            lua_Sprites.remove(id);

            PlayState.instance.remove(sprite);
            sprite.kill();
            sprite.destroy();

            return true;
        });

        Lua_helper.add_callback(lua,"getHealth",function() {
            return PlayState.instance.health;
        });

        Lua_helper.add_callback(lua,"setHealth", function (heal:Float) {
            PlayState.instance.health = heal;
        });

        Lua_helper.add_callback(lua,"getMinHealth",function() {
            return PlayState.instance.minHealth;
        });

        Lua_helper.add_callback(lua,"getMaxHealth",function() {
            return PlayState.instance.maxHealth;
        });

        Lua_helper.add_callback(lua,'changeHealthRange', function (minHealth:Float, maxHealth:Float) {
            @:privateAccess
            {
                var bar = PlayState.instance.healthBar;
                PlayState.instance.minHealth = minHealth;
                PlayState.instance.maxHealth = maxHealth;
                bar.setRange(minHealth, maxHealth);
            }
        });

        Lua_helper.add_callback(lua,"setHudAngle", function (x:Float) {
            PlayState.instance.hudCam.angle = x;
        });

        Lua_helper.add_callback(lua,"setHudPosition", function (x:Int, y:Int) {
            PlayState.instance.hudCam.x = x;
            PlayState.instance.hudCam.y = y;
        });

        Lua_helper.add_callback(lua,"getHudX", function () {
            return PlayState.instance.hudCam.x;
        });

        Lua_helper.add_callback(lua,"getHudY", function () {
            return PlayState.instance.hudCam.y;
        });
        
        Lua_helper.add_callback(lua,"setCamPosition", function (x:Int, y:Int) {
            @:privateAccess
            {
                PlayState.instance.camFollow.x = x;
                PlayState.instance.camFollow.y = y;
            }
        });

        Lua_helper.add_callback(lua,"getCameraX", function () {
            @:privateAccess
            return PlayState.instance.camFollow.x;
        });

        Lua_helper.add_callback(lua,"getCameraY", function () {
            @:privateAccess
            return PlayState.instance.camFollow.y;
        });

        Lua_helper.add_callback(lua,"getCamZoom", function() {
            return FlxG.camera.zoom;
        });

        Lua_helper.add_callback(lua,"getHudZoom", function() {
            return PlayState.instance.hudCam.zoom;
        });

        Lua_helper.add_callback(lua,"setCamZoom", function(zoomAmount:Float) {
            FlxG.camera.zoom = zoomAmount;
        });

        Lua_helper.add_callback(lua,"setHudZoom", function(zoomAmount:Float) {
            PlayState.instance.hudCam.zoom = zoomAmount;
        });


        Lua_helper.add_callback(lua, "setStrumlineY", function(y:Float, ?dontMove:Bool = false)
        {
            PlayState.instance.strumArea.y = y;

            if(!dontMove)
            {
                for(note in PlayState.strumLineNotes)
                {
                    note.y = y;
                }
            }
        });

        Lua_helper.add_callback(lua,"getRenderedNotes", function() {
            return PlayState.instance.notes.length;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteX", function(id:Int) {
            return PlayState.instance.notes.members[id].x;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteY", function(id:Int) {
            return PlayState.instance.notes.members[id].y;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteType", function(id:Int) {
            return PlayState.instance.notes.members[id].noteID;
        });

        Lua_helper.add_callback(lua,"isSustain", function(id:Int) {
            return PlayState.instance.notes.members[id].isSustainNote;
        });

        Lua_helper.add_callback(lua,"isParentSustain", function(id:Int) {
            return PlayState.instance.notes.members[id].lastNote.isSustainNote;
        });
        
        Lua_helper.add_callback(lua,"getRenderedNoteParentX", function(id:Int) {
            return PlayState.instance.notes.members[id].lastNote.x;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteParentY", function(id:Int) {
            return PlayState.instance.notes.members[id].lastNote.y;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteHit", function(id:Int) {
            return PlayState.instance.notes.members[id].mustPress;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteCalcX", function(id:Int) {
            if (PlayState.instance.notes.members[id].mustPress)
                return PlayState.playerStrumArrows.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteID))].x;

            return PlayState.strumLineNotes.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteID))].x;
        });

        Lua_helper.add_callback(lua,"anyNotes", function() {
            return PlayState.instance.notes.members.length != 0;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteStrumtime", function(id:Int) {
            return PlayState.instance.notes.members[id].strum;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteScaleX", function(id:Int) {
            return PlayState.instance.notes.members[id].scale.x;
        });

        Lua_helper.add_callback(lua,"setRenderedNotePos", function(x:Float,y:Float, id:Int) {
            if (PlayState.instance.notes.members[id] == null)
                throw('error! you cannot set a rendered notes position when it doesnt exist! ID: ' + id);
            else
            {
                PlayState.instance.notes.members[id].modifiedByLua = true;
                PlayState.instance.notes.members[id].x = x;
                PlayState.instance.notes.members[id].y = y;
            }
        });

        Lua_helper.add_callback(lua,"setRenderedNoteAlpha", function(alpha:Float, id:Int) {
            PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].alpha = alpha;
        });

        Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scale:Float, id:Int) {
            PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].setGraphicSize(Std.int(PlayState.instance.notes.members[id].width * scale));
        });

        Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scaleX:Int, scaleY:Int, id:Int) {
            PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].setGraphicSize(scaleX,scaleY);
        });

        Lua_helper.add_callback(lua,"getRenderedNoteWidth", function(id:Int) {
            return PlayState.instance.notes.members[id].width;
        });

        Lua_helper.add_callback(lua,"getRenderedNoteHeight", function(id:Int) {
            return PlayState.instance.notes.members[id].height;
        });

        Lua_helper.add_callback(lua,"setRenderedNoteAngle", function(angle:Float, id:Int) {
            PlayState.instance.notes.members[id].modifiedByLua = true;
            PlayState.instance.notes.members[id].angle = angle;
        });


        Lua_helper.add_callback(lua,"setObjectX", function(id:String, x:Int) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                object.x = x;
            }
        });

        Lua_helper.add_callback(lua,"setObjectY", function(id:String, y:Int) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                object.y = y;
            }
        });

        Lua_helper.add_callback(lua,"setObjectPos", function(id:String, x:Int, y:Int) {
            var object = getObjectByName(id);

            if(object != null)
            {
                object.x = x;
                object.y = y;
            }
        });

        Lua_helper.add_callback(lua,"setScrollFactor", function(id:String, x:Float,y:Float) {
            var object = getObjectByName(id);

            if(getObjectByName(id) != null)
            {
                object.scrollFactor.set(x,y);
            }
        });
        
        Lua_helper.add_callback(lua,"setObjectAccelerationX", function(id:String, x:Int) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                object.acceleration.x = x;
            }
        });
        
        Lua_helper.add_callback(lua,"setObjectDragX", function(id:String, x:Int) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                object.drag.x = x;
            }
        });
        
        Lua_helper.add_callback(lua,"setObjectVelocityX", function(id:String, x:Int) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                object.velocity.x = x;
            }
        });

        Lua_helper.add_callback(lua,"setObjectAntialiasing", function(id:String, antialiasing:Bool) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                object.antialiasing = antialiasing;
            }
        });

        Lua_helper.add_callback(lua,"addAnimationByPrefix", function(id:String,prefix:String,anim:String,fps:Int = 30, looped:Bool = true) {
            var object:FlxSprite = getObjectByName(id);

            if(object != null)
            {
                object.animation.addByPrefix(prefix, anim, fps, looped);
            }
        });

        Lua_helper.add_callback(lua,"addAnimationByIndices", function(id:String,prefix:String,indiceString:String,anim:String,fps:Int = 30, looped:Bool = true) {
            if(getObjectByName(id) != null)
            {
                var indices:Array<Dynamic> = indiceString.split(",");

                for(indiceIndex in 0...indices.length)
                {
                    indices[indiceIndex] = Std.parseInt(indices[indiceIndex]);
                }

                getObjectByName(id).animation.addByIndices(anim, prefix, indices, "", fps, looped);
            }
        });
        
        Lua_helper.add_callback(lua,"objectPlayAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false) {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).animation.play(anim, force, reverse);
            }
        });
        
        Lua_helper.add_callback(lua,"playObjectDance", function(id:String, ?altAnim:String = '') {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).dance(altAnim);
            }
        });

        Lua_helper.add_callback(lua,"playCharacterAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false) {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).playAnim(anim, force, reverse);
            }
        });

        Lua_helper.add_callback(lua,"setCharacterShouldDance", function(id:String, shouldDance:Bool = true) {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).shouldDance = shouldDance;
            }
        });

        Lua_helper.add_callback(lua,"playCharacterDance", function(id:String,?altAnim:String) {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).dance(altAnim);
            }
        });

        Lua_helper.add_callback(lua,"setObjectAlpha", function(alpha:Float,id:String) {
            if(getObjectByName(id) != null)
                Reflect.setProperty(getObjectByName(id), "alpha", alpha);
        });

        Lua_helper.add_callback(lua,"setObjectColor", function(id:String,r:Int,g:Int,b:Int,alpha:Int = 255) {
            if(getObjectByName(id) != null)
            {
                Reflect.setProperty(getObjectByName(id), "color", FlxColor.fromRGB(r, g, b, alpha));
            }
        });

        Lua_helper.add_callback(lua,"setObjectAccelerationY", function(y:Int,id:String) {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).acceleration.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setObjectDragY", function(y:Int,id:String) {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).drag.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setObjectVelocityY", function(y:Int,id:String) {
            if(getObjectByName(id) != null)
            {
                getObjectByName(id).velocity.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setObjectAngle", function(angle:Float,id:String) {
            if(getObjectByName(id) != null)
                Reflect.setProperty(getObjectByName(id), "angle", angle);
        });

        Lua_helper.add_callback(lua,"setObjectModAngle", function(angle:Int,id:String) {
            if(getObjectByName(id) != null)
                getObjectByName(id).modAngle = angle;
        });

        Lua_helper.add_callback(lua,"setObjectScale", function(scale:Float,id:String) {
            if(getObjectByName(id) != null)
                getObjectByName(id).setGraphicSize(Std.int(getObjectByName(id).width * scale));
        });
        
        Lua_helper.add_callback(lua, "setObjectScaleXY", function(scaleX:Float, scaleY:Float, id:String)
        {
            if(getObjectByName(id) != null)
                getObjectByName(id).setGraphicSize(Std.int(getObjectByName(id).width * scaleX), Std.int(getObjectByName(id).height * scaleY));
        });

        Lua_helper.add_callback(lua, "setObjectFlipX", function(flip:Bool, id:String)
        {
            if(getObjectByName(id) != null)
                getObjectByName(id).flipX = flip;
        });

        Lua_helper.add_callback(lua, "setObjectFlipY", function(flip:Bool, id:String)
        {
            if(getObjectByName(id) != null)
                getObjectByName(id).flipY = flip;
        });

        Lua_helper.add_callback(lua,"getObjectWidth", function (id:String) {
            if(getObjectByName(id) != null)
                return getObjectByName(id).width;
            else 
                return 0;
        });

        Lua_helper.add_callback(lua,"getObjectHeight", function (id:String) {
            if(getObjectByName(id) != null)
                return getObjectByName(id).height;
            else
                return 0;
        });

        Lua_helper.add_callback(lua,"getObjectAlpha", function(id:String) {
            if(getObjectByName(id) != null)
                return getObjectByName(id).alpha;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getObjectAngle", function(id:String) {
            if(getObjectByName(id) != null)
                return getObjectByName(id).angle;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getObjectX", function (id:String) {
            if(getObjectByName(id) != null)
                return getObjectByName(id).x;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getObjectY", function (id:String) {
            if(getObjectByName(id) != null)
                return getObjectByName(id).y;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"setWindowPos",function(x:Int,y:Int) {
            Application.current.window.move(x, y);
        });

        Lua_helper.add_callback(lua,"getWindowX",function() {
            return Application.current.window.x;
        });

        Lua_helper.add_callback(lua,"getWindowY",function() {
            return Application.current.window.y;
        });

        Lua_helper.add_callback(lua,"getCenteredWindowX",function() {
            return (Application.current.window.display.currentMode.width / 2) - (Application.current.window.width / 2);
        });

        Lua_helper.add_callback(lua,"getCenteredWindowY",function() {
            return (Application.current.window.display.currentMode.height / 2) - (Application.current.window.height / 2);
        });

        Lua_helper.add_callback(lua,"resizeWindow",function(Width:Int,Height:Int) {
            Application.current.window.resize(Width,Height);
        });
        
        Lua_helper.add_callback(lua,"getScreenWidth",function() {
            return Application.current.window.display.currentMode.width;
        });

        Lua_helper.add_callback(lua,"getScreenHeight",function() {
            return Application.current.window.display.currentMode.height;
        });

        Lua_helper.add_callback(lua,"getWindowWidth",function() {
            return Application.current.window.width;
        });

        Lua_helper.add_callback(lua,"getWindowHeight",function() {
            return Application.current.window.height;
        });

        Lua_helper.add_callback(lua,"changeOpponentCharacter", function (character:String) {
            PlayState.opponent.loadCharacter(character);
        });

        Lua_helper.add_callback(lua,"changeSpeakersCharacter", function (character:String) {
            PlayState.speakers.loadCharacter(character);
        });

        Lua_helper.add_callback(lua,"changePlayStateCharacter", function (character:String) {
            PlayState.player.loadCharacter(character);
        });

        var original_Scroll_Speed = PlayState.instance.speed;

        Lua_helper.add_callback(lua,"getBaseScrollSpeed",function() {
            return original_Scroll_Speed;
        });

        Lua_helper.add_callback(lua,"getScrollSpeed",function() {
            return PlayState.instance.speed;
        });

        Lua_helper.add_callback(lua,"setScrollSpeed",function(speed:Float) {
            PlayState.instance.speed = speed;
        });

        Lua_helper.add_callback(lua, "createSound", function(id:String, file_Path:String, ?looped:Bool = false) {
            if(lua_Sounds.get(id) == null)
            {
                lua_Sounds.set(id, new FlxSound().loadEmbedded(Util.getSound(file_Path), looped));

                FlxG.sound.list.add(lua_Sounds.get(id));
            }
            else
                trace("Error! Sound " + id + " already exists! Try another sound name!");
        });

        Lua_helper.add_callback(lua, "removeSound",function(id:String) {
            if(lua_Sounds.get(id) != null)
            {
                var sound = lua_Sounds.get(id);
                sound.stop();
                sound.kill();
                sound.destroy();

                lua_Sounds.set(id, null);
            }
        });

        Lua_helper.add_callback(lua, "playSound",function(id:String, ?forceRestart:Bool = false) {
            if(lua_Sounds.get(id) != null)
                lua_Sounds.get(id).play(forceRestart);
        });

        Lua_helper.add_callback(lua, "stopSound",function(id:String) {
            if(lua_Sounds.get(id) != null)
                lua_Sounds.get(id).stop();
        });

        Lua_helper.add_callback(lua,"setSoundVolume", function(id:String, volume:Float) {
            if(lua_Sounds.get(id) != null)
                lua_Sounds.get(id).volume = volume;
        });

        Lua_helper.add_callback(lua,"tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {angle: toAngle}, time, {ease: FlxEase.quintInOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngleOut", function(toAngle:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoomOut", function(toZoom:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngleOut", function(toAngle:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoomOut", function(toZoom:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosOut", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngleOut", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngleOut", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngleOut", function(id:String, toAngle:Int, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngleIn", function(toAngle:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoomIn", function(toZoom:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.quintInOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngleIn", function(toAngle:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoomIn", function(toZoom:Float, time:Float, onComplete:String = "") {
            FlxTween.tween(PlayState.instance.hudCam, {zoom:toZoom}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosIn", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngleIn", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngleIn", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngleIn", function(id:String, toAngle:Int, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Float, time:Float, onComplete:String = "") {
            if(getObjectByName(id) != null)
                FlxTween.tween(getObjectByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenObjectColor", function(id:String, r1:Int, g1:Int, b1:Int, r2:Int, g2:Int, b2:Int, time:Float, onComplete:String = "") {
            var object = getObjectByName(id);

            if(getObjectByName(id) != null)
            {
                FlxTween.color(
                    object,
                    time,
                    FlxColor.fromRGB(r1, g1, b1, 255),
                    FlxColor.fromRGB(r2, g2, b2, 255),
                    {
                        ease: FlxEase.circIn,
                        onComplete: function(flxTween:FlxTween) {
                            if (onComplete != '' && onComplete != null)
                            {
                                callLua(onComplete,[id]);
                            }
                        }
                    }
                );
            }
        });


        Lua_helper.add_callback(lua,"setProperty", function(object:String, property:String, value:Dynamic) {
            if(object != "")
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, object) != null)
                    Reflect.setProperty(Reflect.getProperty(PlayState.instance, object), property, value);
                else
                    Reflect.setProperty(Reflect.getProperty(PlayState, object), property, value);
            }
            else
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, property) != null)
                    Reflect.setProperty(PlayState.instance, property, value);
                else
                    Reflect.setProperty(PlayState, property, value);
            }
        });

        Lua_helper.add_callback(lua,"getProperty", function(object:String, property:String) {
            if(object != "")
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, object) != null)
                    return Reflect.getProperty(Reflect.getProperty(PlayState.instance, object), property);
                else
                    return Reflect.getProperty(Reflect.getProperty(PlayState, object), property);
            }
            else
            {
                @:privateAccess
                if(Reflect.getProperty(PlayState.instance, property) != null)
                    return Reflect.getProperty(PlayState.instance, property);
                else
                    return Reflect.getProperty(PlayState, property);
            }
        });

        Lua_helper.add_callback(lua, "getPropertyFromClass", function(className:String, variable:String) {
            @:privateAccess
            {
                var variablePaths = variable.split(".");

                if(variablePaths.length > 1)
                {
                    var selectedVariable:Dynamic = Reflect.getProperty(Type.resolveClass(className), variablePaths[0]);

                    for (i in 1...variablePaths.length-1)
                    {
                        selectedVariable = Reflect.getProperty(selectedVariable, variablePaths[i]);
                    }

                    return Reflect.getProperty(selectedVariable, variablePaths[variablePaths.length - 1]);
                }

                return Reflect.getProperty(Type.resolveClass(className), variable);
            }
		});

		Lua_helper.add_callback(lua, "setPropertyFromClass", function(className:String, variable:String, value:Dynamic) {
            @:privateAccess
            {
                var variablePaths:Array<String> = variable.split('.');

                if(variablePaths.length > 1)
                {
                    var selectedVariable:Dynamic = Reflect.getProperty(Type.resolveClass(className), variablePaths[0]);

                    for (i in 1...variablePaths.length-1)
                    {
                        selectedVariable = Reflect.getProperty(selectedVariable, variablePaths[i]);
                    }

                    return Reflect.setProperty(selectedVariable, variablePaths[variablePaths.length - 1], value);
                }

                return Reflect.setProperty(Type.resolveClass(className), variable, value);
            }
		});

        Lua_helper.add_callback(lua,"setSongPosition", function(position:Float) {
            Conductor.songPosition = position;
            setVar('songPos', Conductor.songPosition);
        });

        Lua_helper.add_callback(lua,"stopSong", function() {
            @:privateAccess
            {
                PlayState.paused = true;

                FlxG.sound.music.volume = 0;
                PlayState.instance.vocals.volume = 0;
    
                PlayState.instance.notes.clear();
                PlayState.instance.remove(PlayState.instance.notes);

                FlxG.sound.music.time = 0;
                PlayState.instance.vocals.time = 0;
    
                Conductor.songPosition = 0;
                PlayState.songMultiplier = 0;

                Conductor.recalculateStuff(PlayState.songMultiplier);

                #if cpp
                lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, PlayState.songMultiplier);

                if(PlayState.instance.vocals.playing)
                    lime.media.openal.AL.sourcef(PlayState.instance.vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, PlayState.songMultiplier);
                #end

                PlayState.instance.stopSong = true;
            }

            return true;
        });

        Lua_helper.add_callback(lua, "makeGraphic", function(id:String, width:Int, height:Int, color:String) {
            if(getObjectByName(id) != null)
                getObjectByName(id).makeGraphic(width, height, FlxColor.fromString(color));
		});

        Lua_helper.add_callback(lua,"setObjectTextColor", function(id:String, color:String) {
            if(getObjectByName(id) != null)
                Reflect.setProperty(getObjectByName(id), "color", FlxColor.fromString(color));
        });

        Lua_helper.add_callback(lua,"setObjectText", function(id:String, text:String) {
            if(getObjectByName(id) != null)
                Reflect.setProperty(getObjectByName(id), "text", text);
        });

        Lua_helper.add_callback(lua,"setObjectAlignment", function(id:String, align:String) {
            if(getObjectByName(id) != null)
                Reflect.setProperty(getObjectByName(id), "alignment", align);
        });

        Lua_helper.add_callback(lua,"makeText", function(id:String, text:String, x:Float, y:Float, size:Int = 32, font:String = "vcr", fieldWidth:Float = 0) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxText = new FlxText(x, y, fieldWidth, text, size);
                Sprite.font = Util.getFont(font);


                lua_Sprites.set(id, Sprite);

                PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", genericTitle);
        });

        Lua_helper.add_callback(lua,"endSong", function() {
            @:privateAccess
            {
                FlxG.sound.music.time = FlxG.sound.music.length;
                PlayState.instance.vocals.time = FlxG.sound.music.length;

                PlayState.instance.health = 500000;
                PlayState.instance.invincible = true;

                PlayState.instance.stopSong = false;

                PlayState.instance.resyncVocals();
            }

            return true;
        });

        executeState("onCreate", []);
        executeState("createLua", []);
    }

    public function setup()
    {
        lua_Sprites.set("player", PlayState.player);
        lua_Sprites.set("speakers", PlayState.speakers);
        lua_Sprites.set("opponent", PlayState.opponent);

        lua_Characters.set("player", PlayState.player);
        lua_Characters.set("speakers", PlayState.opponent);
        lua_Characters.set("opponent", PlayState.speakers);

        lua_Sounds.set("Inst", FlxG.sound.music);
        lua_Sounds.set("Voices", PlayState.instance.vocals);

        for (i in 0...PlayState.strumLineNotes.length)
        {
            var member = PlayState.strumLineNotes.members[i];

            setVar("defaultStrum" + i + "X", member.x);
            setVar("defaultStrum" + i + "Y", member.y);
            setVar("defaultStrum" + i + "Angle", member.angle);
        }

        @:privateAccess
        for(object in PlayState.instance.stage.stageObjects)
        {
            lua_Sprites.set(object[0], object[1]);
        }

            for(char in 0...PlayState.opponent.members.length)
            {
                lua_Sprites.set("dadCharacter" + char, PlayState.opponent.members[char]);
                lua_Characters.set("dadCharacter" + char, PlayState.opponent);
            }

            for(char in 0...PlayState.player.members.length)
            {
                lua_Sprites.set("bfCharacter" + char, PlayState.player.members[char]);
                lua_Characters.set("bfCharacter" + char, PlayState.player);
            }

            for(char in 0...PlayState.opponent.members.length)
            {
                lua_Sprites.set("gfCharacter" + char, PlayState.speakers.members[char]);
                lua_Characters.set("gfCharacter" + char, PlayState.speakers);
            }
    }

    private function convert(v : Any, type : String) : Dynamic { // I didn't write this lol
        if(Std.isOfType(v, String) && type != null ) {
            var v : String = v;

            if( type.substr(0, 4) == 'array' )
            {
                if( type.substr(4) == 'float' ) {
                    var array : Array<String> = v.split(',');
                    var array2 : Array<Float> = new Array();

                    for( vars in array ) {
                        array2.push(Std.parseFloat(vars));
                    }

                    return array2;
                    }
                    else if( type.substr(4) == 'int' ) {
                    var array : Array<String> = v.split(',');
                    var array2 : Array<Int> = new Array();

                    for( vars in array ) {
                        array2.push(Std.parseInt(vars));
                    }

                    return array2;
                    } 
                    else {
                    var array : Array<String> = v.split(',');

                    return array;
                }
            } else if( type == 'float' ) {
                return Std.parseFloat(v);
            } else if( type == 'int' ) {
                return Std.parseInt(v);
            } else if( type == 'bool' ) {
                if( v == 'true' ) {
                return true;
                } else {
                return false;
                }
            } else {
                return v;
            }
            } else {
            return v;
        }
    }

    public function getVar(var_name : String, type : String) : Dynamic {
		var result:Any = null;

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua,-1);
		Lua.pop(lua, 1);

		if (result == null)
		    return null;
		else
        {
		    var new_result = convert(result, type);
		    return new_result;
		}
	}

    public function getVarAlt(v:String) {
        var splittedVar = v.split(".");
        if (splittedVar.length == 0) return null;
        var currentObj = variables[splittedVar[0]];
        for (i in 1...splittedVar.length) {
            var property = Reflect.getProperty(currentObj, splittedVar[i]);
            if (property != null) {
                currentObj = property;
            } else {
                trace('Variable $v doesn\'t exist or is equal to null.');
                return null;
            }
        }
        return currentObj;
    }

    public function executeState(name,args:Array<Dynamic>)
    {
        return Lua.tostring(lua, callLua(name, args));
    }

    public static function createLuaHandler(?path:Null<String>):LuaHandler
    {
        return new LuaHandler(path);
    }

    function cameraFromString(cam:String):FlxCamera
    {
        switch(cam.toLowerCase())
        {
            case 'camgame' | 'gamecam' | 'game': return PlayState.instance.gameCam;
            case 'camhud' | 'hudcam' | 'hud': return PlayState.instance.hudCam;
            case 'camother' | 'othercam' | 'other': return PlayState.instance.otherCam;
        }

        return PlayState.instance.gameCam;
    }

    function blendModeFromString(blend:String):BlendMode
    {
        switch(blend.toLowerCase().trim())
        {
            case 'add': return ADD;
            case 'alpha': return ALPHA;
            case 'darken': return DARKEN;
            case 'difference': return DIFFERENCE;
            case 'erase': return ERASE;
            case 'hardlight': return HARDLIGHT;
            case 'invert': return INVERT;
            case 'layer': return LAYER;
            case 'lighten': return LIGHTEN;
            case 'multiply': return MULTIPLY;
            case 'overlay': return OVERLAY;
            case 'screen': return SCREEN;
            case 'shader': return SHADER;
            case 'subtract': return SUBTRACT;
        }

        return NORMAL;
    }

	inline function getInstance()
    {
        return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
    }
}
#end