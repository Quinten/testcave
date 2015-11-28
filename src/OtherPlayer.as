package
{
	import org.flixel.*;

	public class OtherPlayer extends FlxSprite
	{
		[Embed(source="data/bully.png")] protected var ImgBully:Class;
		[Embed(source="data/asplode.mp3")] protected var SndExplode:Class;
		
		protected var _jumpPower:int;
		protected var _bullets:FlxGroup;
		protected var _restart:Number;
		protected var _gibs:FlxEmitter;
		
		public var xHome:Number = 32;
		public var yHome:Number = 32;
		public var aim:uint = RIGHT;
		public var shoot:Boolean = false;
		public var aniFrame:String = "idle";
		public var doFlicker:Boolean = false;
		public var doKill:Boolean = false;
	
		public function OtherPlayer(X:int,Y:int,Bullets:FlxGroup,Gibs:FlxEmitter)
		{
			super(X,Y);
			loadGraphic(ImgBully,true,true,16);
			_restart = 0;
			
			//bounding box tweaks			
			width = 12;
			height = 16;
			
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
			if (doKill && alive) {
				this.kill(); // Otherplayer only explodes and stuff
			}else if (!doKill && !alive) {
				this.relive();
				x = xHome;
				y = yHome;
			}
			// position
			if (shoot) {
				x = xHome;
				y = yHome;				
			}else{	
				x += (xHome - x) / 2;
				y += (yHome - y) / 2;
			}

			//SHOOTING
			if(shoot){
				getMidpoint(_point);
				(_bullets.recycle(Bullet) as Bullet).shoot(_point, aim);
				shoot = false;
			}
			
			play(aniFrame);
			
			if (doFlicker) {
				this.flicker(0.2);
			}

		}
		
		override public function hurt(Damage:Number):void
		{
			// players health is evaluated on their side
		}
		
		override public function kill():void
		{
			if(!alive)
				return;
			alive = false;
			trace("otherplayer EKIA");
			FlxG.play(SndExplode);
			//FlxG.play(SndExplode2);
			flicker(0);
			FlxG.camera.shake(0.005,0.35);
			//FlxG.camera.flash(0xffd8eba2,0.35);
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
			//setTimeout(relive, 7000);
		}
		
		public function relive():void {
			//FlxG.camera.flash(0xffd8eba2,0.35);
			health = 10;
			//acceleration.y = 420;
			alive = true;
			visible = true;
			solid = true;
		}
	}
}