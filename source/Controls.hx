package;

import game.PlayState;
import openfl.display.Sprite;
import flixel.input.FlxInput.FlxInputState;
import flixel.FlxSprite;
import flixel.FlxG;

class Controls
{
    // ui controls
    // just pressed variants
    public static var UI_LEFT:Bool = false;
    public static var UI_DOWN:Bool = false;
    public static var UI_UP:Bool = false;
    public static var UI_RIGHT:Bool = false;

    // held down variants
    public static var UI_LEFT_P:Bool = false;
    public static var UI_DOWN_P:Bool = false;
    public static var UI_UP_P:Bool = false;
    public static var UI_RIGHT_P:Bool = false;

    // note controls
    // just pressed variants
    public static var NOTE_LEFT:Bool = false;
    public static var NOTE_DOWN:Bool = false;
    public static var NOTE_UP:Bool = false;
    public static var NOTE_RIGHT:Bool = false;

    // held down variants
    public static var NOTE_LEFT_P:Bool = false;
    public static var NOTE_DOWN_P:Bool = false;
    public static var NOTE_UP_P:Bool = false;
    public static var NOTE_RIGHT_P:Bool = false;

    // misc keys
    public static var back:Bool = false;
    public static var backP:Bool = false;
    public static var shift:Bool = false;
    public static var shiftP:Bool = false;
    public static var accept:Bool = false;
    public static var acceptP:Bool = false;
    public static var reset:Bool = false;
    public static var resetP:Bool = false;

    public static var uiBinds:Array<String> = [];
    public static var uiBindsAlt:Array<String> = [];

    public static var mainBinds:Array<String> = [];
    public static var altBinds:Array<String> = [];

    public static function refreshControls():Void
    {
        uiBinds = Options.getData('uiBinds');
        uiBindsAlt = Options.getData('uiBindsAlt');
    
        mainBinds = Options.getData('mainBinds')[PlayState.keyCount - 1];
        altBinds = Options.getData('altBinds')[PlayState.keyCount - 1];

        /*trace(uiBinds);
        trace(mainBinds);*/
        // ui
        back = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[4]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[4]), FlxInputState.JUST_PRESSED);
        backP = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[4]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[4]), FlxInputState.PRESSED);
        shift = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[5]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[5]), FlxInputState.JUST_PRESSED);
        shiftP = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[5]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[5]), FlxInputState.PRESSED);
        accept = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[6]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[6]), FlxInputState.JUST_PRESSED);
        acceptP = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[6]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[6]), FlxInputState.PRESSED);
        reset = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[7]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[7]), FlxInputState.JUST_PRESSED);
        resetP = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[7]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[7]), FlxInputState.PRESSED);

        UI_LEFT = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[0]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[0]), FlxInputState.JUST_PRESSED);
        UI_DOWN = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[1]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[1]), FlxInputState.JUST_PRESSED);
        UI_UP = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[2]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[2]), FlxInputState.JUST_PRESSED);
        UI_RIGHT = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[3]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[3]), FlxInputState.JUST_PRESSED);

        UI_LEFT_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[0]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[0]), FlxInputState.PRESSED);
        UI_DOWN_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[1]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[1]), FlxInputState.PRESSED);
        UI_UP_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[2]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[2]), FlxInputState.PRESSED);
        UI_RIGHT_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[3]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[3]), FlxInputState.PRESSED);

        // notes
        NOTE_LEFT = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[0]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[0]), FlxInputState.JUST_PRESSED);
        NOTE_DOWN = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[1]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[1]), FlxInputState.JUST_PRESSED);
        NOTE_UP = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[2]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[2]), FlxInputState.JUST_PRESSED);
        NOTE_RIGHT = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[3]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[3]), FlxInputState.JUST_PRESSED);

        NOTE_LEFT_P = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[0]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[0]), FlxInputState.PRESSED);
        NOTE_DOWN_P = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[1]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[1]), FlxInputState.PRESSED);
        NOTE_UP_P = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[2]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[2]), FlxInputState.PRESSED);
        NOTE_RIGHT_P = FlxG.keys.checkStatus(FlxKey.fromString(mainBinds[3]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(altBinds[3]), FlxInputState.PRESSED);
    }
}