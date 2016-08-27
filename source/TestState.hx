package;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.FlxCamera;
import lighting.*;
class TestState extends FlxState
{
	// embed our graphics


	private var _mapData:BitmapData;		// our map Data - we draw our map here to be turned into a tilemap later
	private var _rooms:Array<Rectangle>;	// a Array that holds all our rooms
	private var _halls:Array<Rectangle>;	// a Array that holds all our halls
	private var _leafs:Array<Leaf>;		// a Array that holds all our leafs
	private var _boxs:Array<FlxSprite>;		// a Array that holds all our leafs
	private var _grpGraphicMap:FlxGroup;	// group for holding the map sprite, so it stays behind the UI elements
	private var _grpTestMap:FlxGroup;		// group for holding the tilemap for testing, so it stays behind the UI and player
	private var _grpUI:FlxGroup;			// group for the UI to be in front of everything
	private var _sprMap:FlxSprite;			// sprite to hold a scaled version of our map to show on the screen
	private var _map:FlxTilemap;			// the tilemap for testing out the map

	private var lightSource:FlxSprite;
	private var lightMan:LightManager;
	private var vis:Visibility;
	private var debug:Bool = false;
	override public function create():Void
	{
		add(_grpGraphicMap = new FlxGroup());
		add(_grpTestMap = new FlxGroup());

		// We need to create a sprite to display our Map - it will be scaled up to fill the screen.
		// our map Sprite will be the size of or finished tileMap/tilesize.
		_sprMap = new FlxSprite(Reg.width / 2 - Reg.width / 32, Reg.height / 2 - Reg.height / 32).makeGraphic(Math.floor(Reg.width / 16), Math.floor(Reg.height / 16), 0x0);
		_sprMap.scale.x = 16;
		_sprMap.scale.y = 16;

		_grpGraphicMap.add(_sprMap);
		_grpTestMap.visible = false;
		setupLights();

		FlxG.mouse.visible = true;


		GenerateMap();
		setupLights();
		PlayMap();
	}


	private function setupLights():Void
	{
		vis = new Visibility();
		vis.loadMap(640);
		lightMan = new LightManager();
		add(lightMan);

		add(lightSource = new FlxSprite().makeGraphic(2,2,0xffff0000));

		lightMan.addLight(new RayLight(0, 0, vis, lightSource));
	}
	private function PlayMap():Void
	{
		// switch to 'play' mode
		_grpTestMap.visible = true;
		_grpGraphicMap.visible = false;

		// turn our map Data into CSV, and make a new Tilemap out of it
		var newMap:FlxTilemap = new FlxTilemap();
		var csvData:String = FlxStringUtil.bitmapToCSV(_mapData);
		newMap.loadMapFromCSV(csvData, "assets/images/tileset.png", 16, 16, OFF, 0, 0, 1);
		if (_map != null)
		{
			// if an old map exists, replace it with our new map
			var oldMap:FlxTilemap = _map;
			_grpTestMap.replace(oldMap, newMap);
			oldMap.kill();
			oldMap.destroy();
		}
		else
		{
			// if no old map exists (first time we hit 'play'), add the new map to the group
			_grpTestMap.add(newMap);
		}
		_map = newMap;
		Reg.map = _map;
		updateMap(_map);
		//FlxG.camera.bounds = new FlxPoint#inRect(0,0,_map.width,_map.height);
	}
	/*
	* reads the map and loads sagements to the visibilty class
	*/
	private function updateMap(m:FlxTilemap):Void
	{
		var c:Int = 0;
		var f:Int = 0;
		var lastIndex1 = 0;
		var lastIndex2 = 0;
		var up = 0;
		var down = 0;
		var s:FlxSprite;
		for (y in 0...m.heightInTiles) {
			lastIndex1 = 0;
			lastIndex2 = 0;
			for (x in 0...m.widthInTiles) {
				if(m.getTile(x,y) != 0  && m.getTile(x,y-1) == 0)
				{
					up ++;
				}
				else
				{
					if(up >= 1)
					{
						c++;
						if(debug)
						add(s = new FlxSprite(lastIndex1*16,y*16).makeGraphic(16*(up),3,0xffff0000));
						vis.addSegment(lastIndex1*16,y*16, (lastIndex1 + up)*16, y*16);
					}
					lastIndex1 = x+1;
					up = 0;
				}
				if(m.getTile(x,y) != 0  && m.getTile(x,y+1) == 0)
				{
					down ++;
				}
				else
				{
					if(down >= 1)
					{c++;
						if(debug)
						add(s = new FlxSprite(lastIndex2*16,(y+1)*16).makeGraphic(16*(down),3,0xff0000ff));
						vis.addSegment(lastIndex2*16,(y+1)*16, (lastIndex2 + down)*16, (y+1)*16);
					}

					lastIndex2 = x+1;
					down = 0;
				}
			}
		}
		var left = 0;
		var right = 0;
		for (x in 0...m.widthInTiles) {
			lastIndex1 = 0;
			lastIndex2 = 0;
			for (y in 0...m.heightInTiles) {
				if(m.getTile(x,y) != 0  && m.getTile(x-1,y) == 0)
				{
					left ++;
				}
				else
				{
					if(left >= 1)
					{c++;
						if(debug)
						add(s = new FlxSprite(x*16,lastIndex1*16).makeGraphic(3,16*(left),0xffffff00));
						vis.addSegment(x*16,lastIndex1*16, x*16, (lastIndex1 + left)*16);
					}
					lastIndex1 = y+1;
					left = 0;
				}
				if(m.getTile(x,y) != 0  && m.getTile(x+1,y) == 0)
				{
					right ++;
				}
				else
				{
					if(right >= 1)
					{c++;
						if(debug)
						add(s = new FlxSprite((x+1)*16,lastIndex2*16).makeGraphic(3,16*(right),0xff00ff00));
						vis.addSegment((x+1)*16,lastIndex2*16, (x+1)*16, (lastIndex2 + right)*16);
					}
					lastIndex2 = y+1;
					right = 0;
				}
			}
		}
		//change the tiles to make it look better
		for (x in 0...m.widthInTiles) {
			for (y in 0...m.heightInTiles) {
				var rand:Int = Math.floor(Math.random()*3);
				var n:Int = getHexValue(m,x,y);
				switch (m.getTile(x,y))
				{
					case 0:
						switch (rand) {
							case 0: m.setTile(x,y,0,true);
						}
					case 1:
						if(n == 255)
							m.setTile(x,y,1,true);
						else
						{
							rand = Math.floor(Math.random()*7);
							switch (rand) {
								case 0: m.setTile(x,y,16,true);
								case 1: m.setTile(x,y,17,true);
								case 2: m.setTile(x,y,18,true);
								case 3: m.setTile(x,y,20,true);
								case 4: m.setTile(x,y,21,true);
								case 5: m.setTile(x,y,22,true);
								case 6: m.setTile(x,y,23,true);
							}
						}
				}
			}
		}
	}
	private function getHexValue(m:FlxTilemap,x:Int, y:Int):Int
	{
		var result:Int = 0;
		if(tileExists(m,x+1,y+1))
			result += 1;
		if(tileExists(m,x+1,y))
			result += 2;
		if(tileExists(m,x+1,y-1))
			result += 4;
		if(tileExists(m,x,y-1))
			result += 8;
		if(tileExists(m,x-1,y-1))
			result += 16;
		if(tileExists(m,x-1,y))
			result += 32;
		if(tileExists(m,x-1,y+1))
			result += 64;
		if(tileExists(m,x,y+1))
			result += 128;

		return result;
	}
	private function tileExists(m:FlxTilemap,x:Int,y:Int):Bool
	{
		if(x>=0 && y>=0 && x<m.widthInTiles && y<m.heightInTiles)
			if(m.getTile(x,y)!= 0)
				return true;
			else
				return false;
		else
		return false;
	}
	private function GenerateMap():Void
	{
		// reset our mapData
		_mapData = new BitmapData(Math.floor(_sprMap.width),Math.floor( _sprMap.height), false, 0xff000000);
		// setup the screen/UI
		_grpTestMap.visible = false;
		_grpGraphicMap.visible = true;

		// reset our Array
		_rooms = new Array<Rectangle>();
		_halls = new Array<Rectangle>();
		_leafs = new Array<Leaf>();

		var l:Leaf; // helper leaf

		// first, create a leaf to be the 'root' of all leaves.
		var root:Leaf = new Leaf(0, 0, Math.floor(_sprMap.width),Math.floor( _sprMap.height));
		_leafs.push(root);

		var did_split:Bool = true;
		// we loop through every leaf in our Array over and over again, until no more leafs can be split.
		while (did_split)
		{
			did_split = false;
			for (l in _leafs)
			{
				if (l.leftChild == null && l.rightChild == null) // if this leaf is not already split...
				{
					// if this leaf is too big, or 75% chance...
					if (l.width > Reg.MAX_LEAF_SIZE || l.height > Reg.MAX_LEAF_SIZE || Math.random() > 0.25)
					{
						if (l.split()) // split the leaf!
						{
							// if we did split, push the child leafs to the Array so we can loop into them next
							_leafs.push(l.leftChild);
							_leafs.push(l.rightChild);
							did_split = true;
						}
					}
				}
			}
		}

		// next, iterate through each leaf and create a room in each one.
		root.createRooms();

		for (l in _leafs)
		{
			// then we draw the room and hallway if it exists
			if (l.room != null)
			{
				drawRoom(l.room);
			}

			if (l.halls != null && l.halls.length > 0)
			{
				drawHalls(l.halls);
			}
		}
		// make our map Sprite's pixels a copy of our map Data BitmapData. Tell flixel the sprite is 'dirty' (so it flushes the cache for that sprite)
		_sprMap.pixels = _mapData.clone();
		_sprMap.dirty = true;

		//Reg.player.addLight();
		FlxG.worldBounds.set(0,0,Reg.width,Reg.height);
	}
	private function drawHalls(h:Array<Rectangle>):Void
	{
		// add each hall to the hall Array, and draw the hall onto our mapData
		for (r in h)
		{
			_halls.push(r);
			_mapData.fillRect(r, FlxColor.WHITE);
		}
	}
	private function drawRoom(r:Rectangle):Void
	{
		// add this room to the room Array, and draw the room onto our mapData
		_rooms.push(r);
		_mapData.fillRect(r, FlxColor.WHITE);
	}
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(FlxG.keys.pressed.ESCAPE)
		{
			if(lightMan != null)
				lightMan.destroyAllLight();

			FlxG.switchState(new TestState());
		}

		lightSource.reset(FlxG.mouse.x,FlxG.mouse.y);
	}

}
