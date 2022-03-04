package menus.dialogueEditor;

import flixel.addons.ui.FlxUICheckBox;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUI;
import ui.CustomDropdown;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxBasic;
import ui.DialogueBox;
import flixel.util.FlxColor;
import flixel.addons.text.FlxTypeText;
import flixel.FlxG;
import flixel.FlxSprite;

typedef DialogueBoxFile =
{
    var scale:Float;
    var font:String;
    var fontSize:Int;
    var boxPosition:Array<Float>;
    var textPosition:Array<Float>;
    var antialiasing:Bool;
    var animations:Array<Array<Dynamic>>;
    var fieldWidth:Int;
    var textColor:Array<Int>;
};

class BoxEditorMenu extends BasicSubState
{
    var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	var blockPressWhileScrolling:Array<CustomDropdown> = [];

    var skin:String = "normal";

    var UI_box:FlxUITabMenu;

    var exampleText:String = "Lorem ipsum dolor sit amet";

    var char:DialogueCharacter;
    var box:EditorDialogueBox;
    var text:FlxTypeText;

    public var characterSpeak:Bool = false;

    public var json:DialogueBoxFile;

	override public function create()
    {
        super.create();

        json = Util.getJsonContents(Util.getPath('dialogue/boxes/$skin/config.json'));

        box = new EditorDialogueBox(json.boxPosition[0], json.boxPosition[1], skin);
        add(box);

        text = new FlxTypeText(json.textPosition[0], json.textPosition[1], json.fieldWidth, exampleText, json.fontSize);
        text.setFormat(Util.getFont(json.font), json.fontSize, FlxColor.fromRGB(json.textColor[0], json.textColor[1], json.textColor[2]), LEFT);
        text.start(0.05);
        text.completeCallback = (function (){
            characterSpeak = false;
        });
        add(text);

        characterSpeak = true;

        char = new DialogueCharacter("bf", box);
        add(char);

        setObjectOrder(0, char);
        setObjectOrder(1, box);
        setObjectOrder(2, text);

		var tabs = [
			{name: "Animation", label: "Animation"},
            {name: "Config", label: "Config"}
		];

        UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 10;
		UI_box.y = 10;
		add(UI_box);

        addAnimUI();
    }

    var reverseOpenAnimCheckbox:FlxUICheckBox;

    function addAnimUI()
    {
		//base ui thingy :D
		var tab_group_animation = new FlxUI(null, UI_box);
		tab_group_animation.name = "Animation";

        var openAnimText = new FlxText(10, 80, 0, "Open Animation (Use name from XML)");
        
		var openAnimationInput = new FlxUIInputText(10, openAnimText.y + 20, (Std.int(UI_box.width) - 10) - 50, "", 8);
		blockPressWhileTypingOn.push(openAnimationInput);

        reverseOpenAnimCheckbox = new FlxUICheckBox(10, 80, null, null, 'Reverse Anim', 100);
		reverseOpenAnimCheckbox.name = 'reverseOpenAnimCheckbox';

        reverseOpenAnimCheckbox.callback = function()
        {
            // a
        };

        // adding things
        tab_group_animation.add(openAnimText);
		tab_group_animation.add(openAnimationInput);

		// final addings
		UI_box.addGroup(tab_group_animation);
		UI_box.scrollFactor.set();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		var blockInput:Bool = false;

		for (inputText in blockPressWhileTypingOn)
		{
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if(!blockInput)
		{
			for (stepper in blockPressWhileTypingOnStepper)
			{
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;

				if(leText.hasFocus)
				{
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					blockInput = true;
					break;
				}
			}
		}

		if(!blockInput)
		{
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];

			for (dropDownMenu in blockPressWhileScrolling)
			{
				if(dropDownMenu.dropPanel.visible)
				{
					blockInput = true;
					break;
				}
			}
		}

        if(!blockInput)
        {
            if(Controls.back)
            {
                DialogueEditorMenu.instance.tweenBackLol();
                close();
            }
    
            if(FlxG.keys.justPressed.SPACE)
            {
                text.resetText(exampleText);
                text.start();
                characterSpeak = true;
            }
        }

        if(characterSpeak)
            char.playAnim('normal-talk');
    }   

    function setObjectOrder(pos:Int = 0, object:FlxBasic)
    {
        remove(object);
        insert(pos, object);
    }
}

class EditorDialogueBox extends FlxSprite
{
    public var json:DialogueBoxFile;

    override public function new(x, y, ?skin:String = "normal")
    {
        super(x, y);
        loadSkin(skin);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function loadSkin(?skin:String = "normal")
    {
        json = Util.getJsonContents(Util.getPath('dialogue/boxes/$skin/config.json'));

		frames = Util.getSparrow('dialogue/boxes/$skin/assets', false);

		animation.addByPrefix('open', json.animations[0][0], json.animations[0][1], false);
		animation.addByPrefix('idle', json.animations[1][0], json.animations[1][1], true);
		animation.addByPrefix('loud', json.animations[2][0], json.animations[2][1], true);

		animation.addByIndices('close', 'Speech Bubble Normal Open', [4, 3, 2, 1, 0], "", 12, false);
        animation.play('idle');

		antialiasing = Options.getData('anti-aliasing');
    }
}