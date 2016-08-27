package;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import lighting.*;

class Reg
{
	public static var MIN_LEAF_SIZE:Int = 10;	// minimum size for a leaf
	public static var MAX_LEAF_SIZE:Int = 20;	// maximum size for a leaf
	public static var map:FlxTilemap;
	public static var width:Int = 640;
	public static var height:Int = 480;

	// function to easily generate a random number between a range
	public static function randomNumber(min:Float, max:Float, ?Absolute:Bool = false):Float
	{
		if (!Absolute)
		{
			return Math.floor(Math.random() * (1 + max - min) + min);
		}
		else
		{
			return Math.abs(Math.floor(Math.random() * (1 + max - min) + min));
		}
	}
}
