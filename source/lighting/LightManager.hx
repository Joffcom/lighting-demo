package lighting;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

/**
 * ...
 * @author ORL
 */
class LightManager extends FlxSprite
{
	private var _maincol:Int;
	private var _lights:Array<Light>;

	public function new(mainColor:Int = 0xBB000000)
	{
		super(0, 0);
		_maincol = mainColor;
		makeGraphic(FlxG.width, FlxG.height, _maincol);
		scrollFactor.x = scrollFactor.y = 0;
		blend = openfl.display.BlendMode.MULTIPLY;

		_lights = [];
	}

	override public function update(elapsed:Float):Void {
		// Clear the canvas to a default state.
		graphic.bitmap.lock();
		graphic.bitmap.fillRect( new Rectangle(0,0,FlxG.width, FlxG.height), _maincol);
		graphic.bitmap.unlock();

		//Add lights
		for (_light in _lights) {
			_light.update(elapsed);//force update because lights are not attached to the stage
			//stamp supports only Int coordinates so I'm trying to put it in the best position (needs to be reviewed)
			if(_light.visible)
			stamp(_light, Math.round(Math.floor(_light.getXY().x * 10)/10), Math.round(Math.floor(_light.getXY().y * 10)/10));
		}
	}

	public function addLight(light:Light):Void {
		_lights.push(light);
	}
	public function destroyAllLight()
	{
		for (i in 0 ... _lights.length) {
			_lights[i].kill();
			_lights[i].destroy();
		}
		_lights.splice(0,_lights.length);
	}
}
