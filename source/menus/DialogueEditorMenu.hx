package menus;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxSubState;
import ui.AlphabetText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class DialogueEditorMenu extends BasicState
{
    static public var instance:DialogueEditorMenu;

    var menuBG:FlxSprite;

    var selectedOption:Int = 0;

    var menuState:String = "select";

    var options:Array<String> = [
        "Characters",
        "Boxes"
    ];

    var optionAlphabets:FlxTypedGroup<AlphabetText> = new FlxTypedGroup<AlphabetText>();
    var funnyArrows:AlphabetText;

    override public function new()
    {
        super();
        instance = this;
    }

	override public function create()
    {
        super.create();

        menuBG = new FlxSprite().loadGraphic(Util.getImage('menuDesat', true, "Base Game"));
        menuBG.color = 0xFF3BEBAD;
        add(menuBG);

        for(i in 0...options.length)
        {
            var alphabet = new AlphabetText(0, 0, options[i]);
            alphabet.screenCenter();
            alphabet.y += (80 * i);

            optionAlphabets.add(alphabet);
        }

        for(shit in optionAlphabets)
        {
            shit.y -= (optionAlphabets.length * 30);
        }

        funnyArrows = new AlphabetText(0, 0, "<               >");
        funnyArrows.screenCenter();
        add(funnyArrows);

        add(optionAlphabets);

        changeOptionSelection();
    }

	override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.back)
            transitionState(new MainMenuState());

        if(Controls.UI_UP)
            changeOptionSelection(-1);

        if(Controls.UI_DOWN)
            changeOptionSelection(1);

        if(Controls.accept)
        {
            switch(options[selectedOption])
            {
                case "Characters":
                    //openSubState(new menus.dialogueEditor.BoxEditorMenu());
                case "Boxes":
                    transitionIntoSubState(new menus.dialogueEditor.BoxEditorMenu());
            }
        }
    }

    function changeOptionSelection(?change:Int = 0)
    {
        selectedOption += change;

        if(selectedOption < 0)
            selectedOption = options.length - 1;

        if(selectedOption > options.length - 1)
            selectedOption = 0;

        for(i in 0...optionAlphabets.length)
        {
            if(selectedOption == i)
                optionAlphabets.members[i].alpha = 1;
            else
                optionAlphabets.members[i].alpha = 0.6;
        }

        funnyArrows.y = optionAlphabets.members[selectedOption].y;

        FlxG.sound.play(Util.getSound('menus/scrollMenu'));
    }

    function transitionIntoSubState(substate:FlxSubState)
    {
        for(fuck in 0...optionAlphabets.length)
        {
            FlxTween.tween(optionAlphabets.members[fuck], {alpha: 0}, 0.4, {
                ease: FlxEase.cubeInOut,
                onComplete: function(twn:FlxTween)
                {
                    if(fuck == 0) openSubState(substate);
                }
            });
        }

        FlxTween.tween(funnyArrows, {alpha: 0}, 0.4, {
            ease: FlxEase.cubeInOut
        });
    }

    public function tweenBackLol()
    {
        for(fuck in 0...optionAlphabets.length)
        {
            var whenTheUmTheFuckTheUh:Float = 1;

            if(selectedOption == fuck)
                whenTheUmTheFuckTheUh = 1;
            else
                whenTheUmTheFuckTheUh = 0.6;

            FlxTween.tween(optionAlphabets.members[fuck], {alpha: whenTheUmTheFuckTheUh}, 0.4, {
                ease: FlxEase.cubeInOut
            });
        }

        FlxTween.tween(funnyArrows, {alpha: 1}, 0.4, {
            ease: FlxEase.cubeInOut
        });
    }
}