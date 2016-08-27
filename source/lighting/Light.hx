package lighting;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;

/**
 * ...
 * @author ORL
 */
class Light extends FlxSprite
{
	private var _follow:FlxSprite;

	public function new(x:Float, y:Float, ?follow:FlxSprite,?path:String = "assets/images/light.png")
	{
		super(x, y);
		_follow = follow;
		loadGraphic(path);

		this.blend = BlendMode.SCREEN;
	}

	public function getXY():FlxPoint {
		if (_follow != null) {
			var pscreenXY:FlxPoint = _follow.getScreenPosition();
			return new FlxPoint(pscreenXY.x - width / 2  + _follow.width / 2, pscreenXY.y - height / 2  + _follow.height / 2);
		} else {
			return getScreenPosition();
		}
	}

}
