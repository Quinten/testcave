package
{
	import org.flixel.*;
	
	import flash.geom.Point;
	
	import flash.utils.setTimeout;

	public class Player extends FlxSprite
	{
		[Embed(source="data/bully.png")] protected var ImgBully:Class;
		[Embed(source="data/asplode.mp3")] protected var SndExplode:Class;
		[Embed(source="data/asplode2.mp3")] protected var SndExplode2:Class;
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

		public function Player(X:int,Y:int,Bullets:FlxGroup,Gibs:FlxEmitter)
		{
			super(X,Y);
			loadGraphic(ImgBully,true,true,16);
			_restart = 0;
			
			//bounding box tweaks
			width = 12;
			height = 16;
			
			//basic player physics
			var runSpeed:uint = 80;
			//var runSpeed:uint = 60;
			drag.x = runSpeed*6;
			//drag.x = runSpeed*8;
			acceleration.y = 420;
			//_jumpPower = 200;
			_jumpPower = 240;
			maxVelocity.x = runSpeed;
			maxVelocity.y = _jumpPower;
			
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
			if(FlxG.keys.justPressed("K") && !FlxG.keys.SHIFT)
			{
				this.kill();
			}
			
			//MOVEMENT
			acceleration.x = 0;
			if(FlxG.keys.LEFT)
			{
				facing = LEFT;
				acceleration.x -= drag.x;
			}
			else if(FlxG.keys.RIGHT)
			{
				facing = RIGHT;
				acceleration.x += drag.x;
			}
			if(FlxG.keys.justPressed("X") && !velocity.y && !FlxG.keys.SHIFT)
			{
				velocity.y = -_jumpPower;
			}
			
			//AIMING
			if(FlxG.keys.UP)
				aim = UP;
			else if(FlxG.keys.DOWN && velocity.y)
				aim = DOWN;
			else
				aim = facing;
			
			shoot = false;
			if(FlxG.keys.justPressed("C") && !FlxG.keys.SHIFT)
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
			FlxG.play(SndExplode, 0.8);
			FlxG.play(SndExplode2, 0.8);
			flicker(0);
			FlxG.camera.shake(0.005,0.35);
			//FlxG.camera.flash(0xffd8eba2,0.35);
			FlxG.camera.fade(0x052117, 6);
			//FlxG.camera.
			if(_gibs != null)
			{
				_gibs.at(this);
				//_gibs.start(true, 5, 0, 50);
				_gibs.start(true,5,0,5);
			}
			
			velocity.make();
			acceleration.make();
			visible = false;
			solid = false;
			if (start) {
				setTimeout(enterCave, 6000);
			}else{
				setTimeout(relive, 6000);
			}
		}
		
		public function relive():void {
			FlxG.camera.stopFX();
			FlxG.camera.flash(0xffd8eba2,0.35);
			var spawnPoint:Point = SpawnPointFactory.getSpawnPoint();
			this.x = spawnPoint.x;
			this.y = spawnPoint.y;
			health = 10;
			acceleration.y = 420;
			alive = true;
			visible = true;
			solid = true;
		}
		
		public function enterCave():void {
			FlxG.camera.stopFX();
			FlxG.camera.flash(0xffd8eba2, 0.35);
			FlxG.switchState(new PlayState());
		}
	}
}