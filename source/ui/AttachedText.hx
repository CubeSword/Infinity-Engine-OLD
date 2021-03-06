package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class AttachedText extends AlphabetText
{
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sprTracker:FlxSprite;
	public var copyVisible:Bool = true;
	public var copyAlpha:Bool = false;
	public var isAlt:Bool = false;

	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0, ?scale:Float = 1) {
		super(0, 0, text, scale);
		isMenuItem = false;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if(copyVisible) {
				visible = sprTracker.visible;
			}
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}

		super.update(elapsed);
	}
}
