package ui;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class AlphabetText extends FlxSpriteGroup
{
    // Public Variables //
    public var text:String = "coolswag";

    public var targetY:Int = 0;
    public var isMenuItem:Bool = false;

    public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

    // Private Variables //
    private var bold:Bool = true;

    private var splitText:Array<String> = [];
    private var splitTextButMultiLengthChars:Array<String> = [];

    public function new(?x:Float = 0.0, ?y:Float = 0.0, ?text_Param:String = "coolswag", ?size:Float = 70/*, ?typed:Bool = false temporarily disabled until i wanna make it work lol*/)
    {
        super(x,y);

        text = text_Param.toLowerCase();
        splitText = text.split("");

        var startingX:Float = 0;
        var curLine:Int = 0;
        var quoteAmount:Int = 1;
        var multiLengthChars:Map<String, String> = [
            "&" => "ampersand",
            "<" => "less",
            ">" => "more",
            '"' => "quote"
        ];
        
        for(i in 0...splitText.length)
        {
            if (multiLengthChars.exists(splitText[i])) {
                splitTextButMultiLengthChars.push(multiLengthChars.get(splitText[i]));
            } else {
                splitTextButMultiLengthChars.push(splitText[i]);
            }
            var character:String = splitTextButMultiLengthChars[i];

            switch (character) {
                case "\n":
                    curLine ++;
                    startingX = 0;

                case " ":
                    startingX += (size*(size/70))/(size/35);

                case "quote":
                    if (quoteAmount == Math.floor(quoteAmount/2)*2) {
                        var alphabetChar:AlphabetCharacter = new AlphabetCharacter('quoteb', curLine, i, startingX, size);
                        add(alphabetChar);
                        startingX += alphabetChar.width + 0.3*(size/70);
                    } else {
                        var alphabetChar:AlphabetCharacter = new AlphabetCharacter('quotea', curLine, i, startingX, size);
                        add(alphabetChar);
                        startingX += alphabetChar.width + 0.3*(size/70);
                    }
                    quoteAmount ++;
                default:
                    var alphabetChar:AlphabetCharacter = new AlphabetCharacter(character, curLine, i, startingX, size);
                    add(alphabetChar);
                    startingX += alphabetChar.width + 0.3*(size/70);
            }
        }
    }

	override function update(elapsed:Float)
	{
		if(isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var lerpVal:Float = Util.boundTo(elapsed * 9.6, 0, 1);
			
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);

			if(forceX != Math.NEGATIVE_INFINITY) {
				x = forceX;
			} else {
				x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
			}
		}

		super.update(elapsed);
	}
}

class AlphabetCharacter extends FlxSprite
{
    // Public Variables //
    public var bold:Bool = true;

    // Static Variables //
    public static var availableCharacters:Array<String> = [
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
        "0","1","2","3","4","5","6","7","8","9",
        "!","?",".","-","+","(",")","*","more","less","ampersand","'",'quotea','quoteb',"_"
    ];

    public function new(character:String = "a", line:Int = 0, ?id:Int, ?startX:Float = 0.0, ?size:Float = 70)
    {
        super();

        antialiasing = Options.getData('anti-aliasing');

        if(id != null)
            ID = id;

        frames = Util.getSparrow("Alphabet");

        if(availableCharacters.contains(character)) {
            animation.addByPrefix("default", character.toUpperCase() + "0", 24);
            animation.play("default", true);
        } else {
            animation.addByPrefix("default", "MISSING0", 24);
            animation.play("default", true);
        }
        scale.set(size/70, size/70);
        updateHitbox();

        x = startX;
        if (character == "." || character == "_") {
            y = ((line*size)+8*(size/70))+(size/1.3-height/2);
        } else if (character == "-" || character == "+"){
            y = ((line*size)+8*(size/70))+(size/2-height/2);
        } else {
            y = ((line*size)+8*(size/70));
        }
    }
}
