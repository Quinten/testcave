package
{
	import org.flixel.*;
	
	import flash.geom.Point;
	
	import flash.utils.setTimeout;

	public class NonPlayer extends FlxSprite
	{
		[Embed(source="data/bully.png")] protected var ImgBully:Class;
		[Embed(source="data/asplode.mp3")] protected var SndExplode:Class;
		[Embed(source="data/hurt.mp3")] protected var SndHurt:Class;
		[Embed(source="data/jam.mp3")] protected var SndJam:Class;
		
		protected var _jumpPower:int;
		protected var _bullets:FlxGroup;
		protected var _restart:Number;
		protected var _gibs:FlxEmitter;
		
		public var aim:uint;
		public var shoot:Boolean = false;
		public var aniFrame:String = "idle";
		
		public var start:Boolean = false;
		
		public var tmpVY:Number = 0;
		private var autoShotFired:Boolean = false;
		public var justKilled:Boolean = false;
		
		//This is the player object class.  Most of the comments I would put in here
		//would be near duplicates of the Enemy class, so if you're confused at all
		//I'd recommend checking that out for some ideas!
		public function NonPlayer(X:int,Y:int,Bullets:FlxGroup,Gibs:FlxEmitter)
		{
			super(X,Y);
			//loadGraphic(ImgBully, true, true, 8);
			loadGraphic(ImgBully,true,true,16);
			_restart = 0;
			
			//bounding box tweaks
			width = 12;
			height = 16;
			
			_jumpPower = 240;
			acceleration.y = 420;
			
			// animations
			addAnimation("idle", [0]);
			addAnimation("run", [1, 2, 3], 12);
			addAnimation("jump", [4]);
			addAnimation("run_shoot", [5]);
			addAnimation("fall_shoot", [6]);
			addAnimation("jump_shoot", [7]);
			addAnimation("up_shoot", [8]);
			
			//bullet stuff
			_bullets = Bullets;
			_gibs = Gibs;
		}
		
		override public function destroy():void
		{
			super.destroy();
			_bullets = null;
			_gibs = null;
		}
		
		override public function update():void
		{
			if(FlxG.keys.justPressed("K") && FlxG.keys.SHIFT)
			{
				this.kill();
			}
			
			//MOVEMENT
			//acceleration.x = 0;
			//if(FlxG.keys.LEFT)
			//{
				//facing = LEFT;
				//acceleration.x -= drag.x;
			//}
			//else if(FlxG.keys.RIGHT)
			//{
				//facing = RIGHT;
				//acceleration.x += drag.x;
			//}
			/*if(FlxG.keys.justPressed("X") && !velocity.y && FlxG.keys.SHIFT)
			{
				velocity.y = -_jumpPower;
			}*/
			
			//AIMING
			if(FlxG.keys.UP)
				aim = UP;
			else if(FlxG.keys.DOWN && velocity.y)
				aim = DOWN;
			else
				aim = facing;
			
			shoot = autoShotFired;
			autoShotFired = false;
			if(FlxG.keys.justPressed("C") && FlxG.keys.SHIFT)
			{
				if(flickering)
					FlxG.play(SndJam);
				else
				{
					getMidpoint(_point);
					(_bullets.recycle(Bullet) as Bullet).shoot(_point,aim);
					if (aim == DOWN)
						velocity.y -= 48;
						//velocity.y -= 36;
					shoot = true;
				}
			}
			
			//if (pathSpeed != 0 && !velocity.y) {
				//velocity.y = -_jumpPower;
			//}
			
			//trace(velocity.x);
			if(!justTouched(UP)){
				velocity.y = tmpVY;
			}
			
			if (velocity.x < 0) {
				facing = LEFT;
			} else if (velocity.x > 0) {
				facing = RIGHT;
			}
			
			if(velocity.y != 0)
			{
				if(aim == UP) aniFrame = "jump_shoot";
				else if(aim == DOWN) aniFrame = "fall_shoot";
				else aniFrame = "jump";
			}
			else if(velocity.x == 0)
			{
				if (aim == UP) aniFrame = "up_shoot";
				else if (shoot) aniFrame = "run_shoot";
				else  aniFrame = "idle";
			}
			else
			{
				if (aim == UP) aniFrame = "up_shoot";
				else if (shoot) aniFrame = "run_shoot";
				else aniFrame = "run";
			}
			
			play(aniFrame);
		}
		
		override public function hurt(Damage:Number):void
		{
			//Damage = 0;
			if(flickering)
				return;
			FlxG.play(SndHurt);
			flicker(1.3);
			//if(velocity.x > 0)
				//velocity.x = -maxVelocity.x;
			//else
				//velocity.x = maxVelocity.x;
			super.hurt(Damage);
		}
		
		override public function kill():void
		{
			if(!alive)
				return;
			alive = false;
			FlxG.play(SndExplode);
			flicker(0);
			FlxG.camera.shake(0.005,0.35);
			if(_gibs != null)
			{
				_gibs.at(this);
				_gibs.start(true,5,0,5);
			}
			velocity.make();
			acceleration.make();
			visible = false;
			solid = false;
			justKilled = true;
			//setTimeout(relive, 2000);
			//trace("hello");
			relive();
		}
		
		public function relive():void {
			//trace("yello");
			var spawnPoint:Point = SpawnPointFactory.getSpawnPoint();
			this.x = spawnPoint.x;
			//trace("pello");
			this.y = spawnPoint.y;
			health = 10;
			acceleration.y = 420;
			alive = true;
			visible = true;
			solid = true;
		}
		
		public function autoShoot():void {
			//shoot = false;
			getMidpoint(_point);
			(_bullets.recycle(Bullet) as Bullet).shoot(_point,aim);
			if (aim == DOWN)
				velocity.y -= 48;
			//shoot = true;
			autoShotFired = true;
		}
	}
}