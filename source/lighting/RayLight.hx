package lighting;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ORL
 */
class RayLight extends Light
{
	private var _vis:Visibility;
	private var _shadow:FlxSprite;
	private var _scalex:Float;
	private var _scaley:Float;

	public function new(x:Float, y:Float, vis:Visibility, ?follow:FlxSprite)
	{
		super(x, y, follow,"assets/images/lamp.png");
		_vis = vis;
		_shadow = new FlxSprite();
		_shadow.makeGraphic(Math.floor(width), Math.floor(height), FlxColor.TRANSPARENT);
		_scalex = scale.x;
		_scaley = scale.y;

		if (_follow == null) {
			makeShadow( x,y);
			this.x = (this.x) - (width / 2);
			this.y = (this.y) - (height / 2);
		}
	}

	private function makeShadow(px:Float, py:Float):Void {
		_vis.setLightLocation( px, py);
		_vis.sweep();

		_shadow.graphic.bitmap.lock();
		_shadow.graphic.bitmap.fillRect( new Rectangle(0, 0, width, height), FlxColor.TRANSPARENT);
		_shadow.graphic.bitmap.unlock();
		for (_vertex in _vis.output) {
			_vertex.x = _vertex.x + width / 2 - px;
			_vertex.y = _vertex.y + height / 2 - py;
		}
		FlxSpriteUtil.drawPolygon(_shadow, _vis.output, 0xFFFFFFFF);
		FlxSpriteUtil.alphaMaskFlxSprite(_shadow, this, this);
	}

	override public function update(elapsed:Float) {
		if(this.visible)
		{
			if (_follow != null) {
				makeShadow( _follow.x + _follow.width / 2, _follow.y + _follow.height / 2);
			} else if ((scale.x != _scalex)||(scale.y != _scaley)) {

				_scalex = scale.x;
				_scaley = scale.y;
				var invscalex:Float = 1 / _scalex;
				var invscaley:Float = 1 / _scaley;
				var data:BitmapData = new BitmapData(Math.floor(width*invscalex), Math.floor(height*invscaley), true, FlxColor.TRANSPARENT);
				var matrix:Matrix = new Matrix();
				matrix.scale(invscalex, invscaley);
				data.draw(_shadow.graphic.bitmap, matrix);
				_shadow.graphic.bitmap.lock();
				_shadow.graphic.bitmap.copyPixels(data, new Rectangle(((width*invscalex)-width)/2,((height*invscaley)-height)/2, width, height), new Point(0, 0));
				_shadow.graphic.bitmap.unlock();
				FlxSpriteUtil.alphaMaskFlxSprite(_shadow, this, this);
			}
		}
		super.update(elapsed);
	}

}
