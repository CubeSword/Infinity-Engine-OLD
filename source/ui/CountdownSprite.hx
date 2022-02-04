package ui;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class CountdownSprite extends FlxSprite {
	var filePath:String = 'countdown/normal/';
	
	public function new(countdownStr:String, pixel:Bool = false)
	{
		super();
		if(!pixel)
			antialiasing = Options.getData('anti-aliasing');

		if(pixel)
			filePath = 'countdown/pixel/';

		loadGraphic(Util.getImage(filePath + countdownStr));
		screenCenter();
		scrollFactor.set();
		
		FlxTween.tween(this, {alpha: 0}, (game.Conductor.crochet / 1000) / game.PlayState.songMultiplier, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				this.destroy();
			}
		});

		if(pixel)
			scale.set(game.PlayState.pixelAssetZoom, game.PlayState.pixelAssetZoom);
	}
	
	override public function update(elapsed) {
		super.update(elapsed);
	}
}
