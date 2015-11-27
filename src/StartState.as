package
{
	import flash.geom.Point;
	import org.flixel.*;

	public class StartState extends FlxState
	{
		[Embed(source="data/cavetiles.png")] protected var ImgTech:Class;
		[Embed(source="data/titlecave.png")] private var ImgMap:Class;
		[Embed(source="data/redgibs.png")] private var ImgGibs:Class;
		
		//major game object storage
		protected var _blocks:FlxGroup;
		protected var _bullets:FlxGroup;
		protected var _player:Player;
		protected var _littleGibs:FlxEmitter;
		
		//meta groups, to help speed up collisions
		protected var _objects:FlxGroup;
		
		protected var level:FlxTilemap = new FlxTilemap();
		
		override public function create():void
		{
			FlxG.mouse.hide();
			FlxG.bgColor = 0xff052117;
			
			// particle pieces
			_littleGibs = new FlxEmitter();
			_littleGibs.setXSpeed(-150,150);
			_littleGibs.setYSpeed(-200,0);
			_littleGibs.setRotation(-720,-720);
			_littleGibs.gravity = 350;
			_littleGibs.bounce = 0.5;
			_littleGibs.makeParticles(ImgGibs,10,10,true,0.5);
			
			// object groups or pools
			_blocks = new FlxGroup();
			_bullets = new FlxGroup();

			_player = new Player(84,48,_bullets, _littleGibs)
			_player.health = 10;
			_player.start = true;
			generateCave();
			
			var instr1:FlxText = new FlxText(16, 16, 120);
			instr1.setFormat(null, 8, 0xff10895F, "left", 0);
			instr1.text = "arrow-keys to move\nX to jump\nC to shoot";
			add(instr1);
			
			var instr2:FlxText = new FlxText(184, 16, 120);
			instr2.setFormat(null, 8, 0xff10895F, "right", 0);
			instr2.text = "shoot to kill\nand stay alive";
			add(instr2);
			
			var instr3:FlxText = new FlxText(0, 210, 320);
			instr3.setFormat(null, 8, 0xff10895F, "center", 0);
			instr3.text = "press K to skip life";
			add(instr3);
			
			var instr4:FlxText = new FlxText(84, 116, 120);
			instr4.setFormat(null, 8, 0xff10895F, "left", 0);
			instr4.text = "shift+X,C or K\ncontrol twin";
			add(instr4);

			add(_littleGibs);
			add(_blocks);

			add(_player);
			
			FlxG.camera.setBounds(0, 0, 320, 240, true);

			add(_bullets);

			_objects = new FlxGroup();
			_objects.add(_bullets);
			_objects.add(_player);
			_objects.add(_littleGibs);
			
			FlxG.flash(0xff131c1b);
		}
		
		override public function destroy():void
		{
			super.destroy();
			_blocks = null;
			_bullets = null;
			_player = null;
			_littleGibs = null;
			_objects = null;
		}

		override public function update():void
		{			
			super.update();
			
			FlxG.collide(_blocks,_objects);
		}
		
		protected function generateCave():void {
			level = new FlxTilemap();
			level.loadMap(FlxTilemap.imageToCSV(ImgMap,false,2),ImgTech,0,0,FlxTilemap.ALT);
			_blocks.add(level);
		}

	}
}
