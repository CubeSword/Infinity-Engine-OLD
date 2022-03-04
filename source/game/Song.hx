package game;

import game.Section;

using StringTools;

class Event
{
	public var name:String;
	public var position:Float;
	public var value:Float;
	public var type:String;

	public function new(name:String,pos:Float,value:Float,type:String)
	{
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}

typedef Song =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gf:Null<String>;
	var stage:Null<String>;
	var validScore:Bool;

	var modchartPath:String;

	var keyCount:Null<Int>;

	var timescale:Array<Int>;

	var chartOffset:Null<Int>; // in milliseconds

	// shaggy pog
	var mania:Null<Int>;

	var ui_Skin:String;

	var cutscene:String;
	var endCutscene:String;

	var eventObjects:Array<Event>;
}