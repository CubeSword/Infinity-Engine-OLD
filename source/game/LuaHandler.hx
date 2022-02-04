package game;

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
    public var lua:State = null;

    //i'm gonna need help with this swgveruidhuk
}
#end