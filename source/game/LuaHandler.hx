package game;

import ui.Icon;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
#if linc_luajit
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

    function getActorByName(id:String):Dynamic
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

        lua_Sprites = [
            'player' => PlayState.player,
            'speakers' => PlayState.speakers,
            'opponent' => PlayState.opponent,
        ];

        lua_Characters = [
            'player' => PlayState.player,
            'speakers' => PlayState.speakers,
            'opponent' => PlayState.opponent,
        ];
    
        @:privateAccess
        lua_Sounds = [
            'Inst' => FlxG.sound.music,
            'Voices' => PlayState.instance.vocals
        ];
    
        @:privateAccess
        lua_Sounds = [
            'Inst' => FlxG.sound.music,
            'Voices' => PlayState.instance.vocals
        ];

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
        setVar("keyCount", PlayState.song.keyCount);
        setVar("scrollSpeed", PlayState.song);
        setVar("fpsCap", Options.getData("fpsCap"));
        setVar("botplay", Options.getData("botplay"));
        setVar("downscroll", Options.getData("downscroll"));
        setVar("cameraZooms", Options.getData("camera-zooms"));

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

        Lua_helper.add_callback(lua,"openURL", function(url:String = "https://www.google.com") {
            if(Options.getData("allow-lua-openurls"))
                Util.openURL(url);
        });

        Lua_helper.add_callback(lua,"flixelGetData", function(save:String) {
            return Reflect.getProperty("flixel.FlxG", 'save.data.$save');
        });

        Lua_helper.add_callback(lua, "flixelSaveData", function(save:String, value:String, ?flush:Bool = true) {
            Reflect.setProperty("flixel.FlxG", 'save.data.$save', value);
            if(flush)
                FlxG.save.flush();
        });

        Lua_helper.add_callback(lua,"setObjectCamera", function(id:String, camera:String = "") {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                Reflect.setProperty(actor, "cameras", [cameraFromString(camera)]);
        });

        Lua_helper.add_callback(lua,"setGraphicSize", function(id:String, width:Int = 0, height:Int = 0) {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                actor.setGraphicSize(width, height);
        });

        Lua_helper.add_callback(lua,"updateHitbox", function(id:String) {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                actor.updateHitbox();
        });

        Lua_helper.add_callback(lua, "setBlendMode", function(id:String, blend:String = '') {
            var actor:FlxSprite = getActorByName(id);

            if(actor != null)
                actor.blend = blendModeFromString(blend);
		});

        Lua_helper.add_callback(lua,"makeStageSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1, front:Bool = false) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:StageSprite = new StageSprite(x, y);
                Sprite.isNormalSprite = true;

                @:privateAccess
                Sprite.loadGraphic(Util.getImage("stages/" + PlayState.instance.stage.megaCoolPoggersStage + "/" + filename, false));

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                @:privateAccess
                if(front)
                    PlayState.instance.stage.add(Sprite);
                else
                    PlayState.instance.stageFront.add(Sprite);
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
    
                @:privateAccess
                if(front)
                    PlayState.instance.stage.add(Sprite);
                else
                    PlayState.instance.stageFront.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", genericTitle);
        });

        Lua_helper.add_callback(lua,"makeSprite", function(id:String, filename:String, x:Float, y:Float, size:Float = 1) {
            if(!lua_Sprites.exists(id))
            {
                var Sprite:FlxSprite = new FlxSprite(x, y);

                Sprite.loadGraphic(Util.getImage(filename));

                Sprite.setGraphicSize(Std.int(Sprite.width * size));
                Sprite.updateHitbox();
    
                lua_Sprites.set(id, Sprite);
    
                PlayState.instance.add(Sprite);
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
    
                PlayState.instance.add(Sprite);
            }
            else
                Application.current.window.alert("Sprite " + id + " already exists! Choose a different name!", genericTitle);
        });

        Lua_helper.add_callback(lua, "destroySprite", function(id:String) {
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


        Lua_helper.add_callback(lua,"setActorX", function(x:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).x = x;
            }
        });

        Lua_helper.add_callback(lua,"setActorY", function(y:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).y = y;
            }
        });

        Lua_helper.add_callback(lua,"setActorPos", function(x:Int,y:Int,id:String) {
            var actor = getActorByName(id);

            if(actor != null)
            {
                actor.x = x;
                actor.y = y;
            }
        });

        Lua_helper.add_callback(lua,"setActorScroll", function(x:Float,y:Float,id:String) {
            var actor = getActorByName(id);

            if(getActorByName(id) != null)
            {
                actor.scrollFactor.set(x,y);
            }
        });
        
        Lua_helper.add_callback(lua,"setActorAccelerationX", function(x:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).acceleration.x = x;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorDragX", function(x:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).drag.x = x;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorVelocityX", function(x:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).velocity.x = x;
            }
        });

        Lua_helper.add_callback(lua,"setActorAntialiasing", function(antialiasing:Bool,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).antialiasing = antialiasing;
            }
        });

        Lua_helper.add_callback(lua,"addActorAnimation", function(id:String,prefix:String,anim:String,fps:Int = 30, looped:Bool = true) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).animation.addByPrefix(prefix, anim, fps, looped);
            }
        });

        Lua_helper.add_callback(lua,"addActorAnimationIndices", function(id:String,prefix:String,indiceString:String,anim:String,fps:Int = 30, looped:Bool = true) {
            if(getActorByName(id) != null)
            {
                var indices:Array<Dynamic> = indiceString.split(",");

                for(indiceIndex in 0...indices.length)
                {
                    indices[indiceIndex] = Std.parseInt(indices[indiceIndex]);
                }

                getActorByName(id).animation.addByIndices(anim, prefix, indices, "", fps, looped);
            }
        });
        
        Lua_helper.add_callback(lua,"playActorAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).animation.play(anim, force, reverse);
            }
        });
        
        Lua_helper.add_callback(lua,"playActorDance", function(id:String, ?altAnim:String = '') {
            if(getActorByName(id) != null)
            {
                getActorByName(id).dance(altAnim);
            }
        });

        Lua_helper.add_callback(lua,"playCharacterAnimation", function(id:String,anim:String,force:Bool = false,reverse:Bool = false) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).playAnim(anim, force, reverse);
            }
        });

        Lua_helper.add_callback(lua,"setCharacterShouldDance", function(id:String, shouldDance:Bool = true) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).shouldDance = shouldDance;
            }
        });

        Lua_helper.add_callback(lua,"playCharacterDance", function(id:String,?altAnim:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).dance(altAnim);
            }
        });

        Lua_helper.add_callback(lua,"setActorAlpha", function(alpha:Float,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).alpha = alpha;
                getActorByName(id).updateColorTransform();
            }
        });

        Lua_helper.add_callback(lua,"setActorColor", function(id:String,r:Int,g:Int,b:Int,alpha:Int = 255) {
            if(getActorByName(id) != null)
            {
                Reflect.setProperty(getActorByName(id), "color", FlxColor.fromRGB(r, g, b, alpha));
            }
        });

        Lua_helper.add_callback(lua,"setActorAccelerationY", function(y:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).acceleration.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorDragY", function(y:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).drag.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorVelocityY", function(y:Int,id:String) {
            if(getActorByName(id) != null)
            {
                getActorByName(id).velocity.y = y;
            }
        });
        
        Lua_helper.add_callback(lua,"setActorAngle", function(angle:Float,id:String) {
            if(getActorByName(id) != null)
                Reflect.setProperty(getActorByName(id), "angle", angle);
        });

        Lua_helper.add_callback(lua,"setActorModAngle", function(angle:Int,id:String) {
            if(getActorByName(id) != null)
                getActorByName(id).modAngle = angle;
        });

        Lua_helper.add_callback(lua,"setActorScale", function(scale:Float,id:String) {
            if(getActorByName(id) != null)
                getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
        });
        
        Lua_helper.add_callback(lua, "setActorScaleXY", function(scaleX:Float, scaleY:Float, id:String)
        {
            if(getActorByName(id) != null)
                getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scaleX), Std.int(getActorByName(id).height * scaleY));
        });

        Lua_helper.add_callback(lua, "setActorFlipX", function(flip:Bool, id:String)
        {
            if(getActorByName(id) != null)
                getActorByName(id).flipX = flip;
        });

        Lua_helper.add_callback(lua, "setActorFlipY", function(flip:Bool, id:String)
        {
            if(getActorByName(id) != null)
                getActorByName(id).flipY = flip;
        });

        Lua_helper.add_callback(lua,"getActorWidth", function (id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).width;
            else 
                return 0;
        });

        Lua_helper.add_callback(lua,"getActorHeight", function (id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).height;
            else
                return 0;
        });

        Lua_helper.add_callback(lua,"getActorAlpha", function(id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).alpha;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getActorAngle", function(id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).angle;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getActorX", function (id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).x;
            else
                return 0.0;
        });

        Lua_helper.add_callback(lua,"getActorY", function (id:String) {
            if(getActorByName(id) != null)
                return getActorByName(id).y;
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

        Lua_helper.add_callback(lua,"tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {angle:toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {zoom:toZoom}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.linear, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.quintInOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngleOut", function(toAngle:Float, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoomOut", function(toZoom:Float, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngleOut", function(toAngle:Float, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {angle:toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoomOut", function(toZoom:Float, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {zoom:toZoom}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosOut", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngleOut", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngleOut", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngleOut", function(id:String, toAngle:Int, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenCameraAngleIn", function(toAngle:Float, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenCameraZoomIn", function(toZoom:Float, time:Float, onComplete:String) {
            FlxTween.tween(FlxG.camera, {zoom:toZoom}, time, {ease: FlxEase.quintInOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });
                        
        Lua_helper.add_callback(lua,"tweenHudAngleIn", function(toAngle:Float, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {angle:toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenHudZoomIn", function(toZoom:Float, time:Float, onComplete:String) {
            FlxTween.tween(PlayState.instance.hudCam, {zoom:toZoom}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,["camera"]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosIn", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosXAngleIn", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenPosYAngleIn", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenAngleIn", function(id:String, toAngle:Int, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Float, time:Float, onComplete:String) {
            if(getActorByName(id) != null)
                FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
        });

        Lua_helper.add_callback(lua,"tweenActorColor", function(id:String, r1:Int, g1:Int, b1:Int, r2:Int, g2:Int, b2:Int, time:Float, onComplete:String) {
            var actor = getActorByName(id);

            if(getActorByName(id) != null)
            {
                FlxTween.color(
                    actor,
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
            @:privateAccess
            if(Reflect.getProperty(PlayState.instance, object) != null)
                Reflect.setProperty(Reflect.getProperty(PlayState.instance, object), property, value);
            else
                Reflect.setProperty(Reflect.getProperty(PlayState, object), property, value);
        });

        Lua_helper.add_callback(lua,"getProperty", function(object:String, property:String) {
            @:privateAccess
            if(Reflect.getProperty(PlayState.instance, object) != null)
                return Reflect.getProperty(Reflect.getProperty(PlayState.instance, object), property);
            else
                return Reflect.getProperty(Reflect.getProperty(PlayState, object), property);
        });

        Lua_helper.add_callback(lua, "getPropertyFromClass", function(className:String, variable:String) {
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
		});

		Lua_helper.add_callback(lua, "setPropertyFromClass", function(className:String, variable:String, value:Dynamic) {
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
            case 'hudCam' | 'hud': return PlayState.instance.hudCam;
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
}
#end