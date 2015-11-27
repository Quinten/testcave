package
{
	import flash.geom.Point;
	import org.flixel.*;
	
	import realtimelib.P2PGame;
	import realtimelib.events.PeerStatusEvent;
	
	import flash.events.Event;
    import flash.utils.Timer;
    import flash.events.TimerEvent;

	public class PlayState extends FlxState
	{
		[Embed(source="data/cavetiles.png")] protected var ImgTech:Class;
		[Embed(source="data/crazycave.png")] private var ImgMap:Class;
		[Embed(source = "data/redgibs.png")] private var ImgGibs:Class;
		[Embed(source="data/blauwjoggingvestje3.mp3")] private var SndTrack:Class;
		
		//major game object storage
		protected var _blocks:FlxGroup;
		protected var _bullets:FlxGroup;
		protected var _player:Player;
		protected var _enemyBullets:FlxGroup;
		protected var _npcBullets:FlxGroup;
		protected var _littleGibs:FlxEmitter;
		
		//meta groups, to help speed up collisions
		protected var _objects:FlxGroup;
		
		protected var level:FlxTilemap = new FlxTilemap();
		
		private var _pgame:P2PGame;
		private const SERVER:String = "rtmfp://p2p.rtmfp.net/";
		private const DEVKEY:String = "XXX";
		protected var _enemies:Object;
		protected var _npcenemies:Object;
		private var _pconnected:Boolean = false;
		
		private var _npc:NonPlayer;
		private var npcLap:int = 0;
		private var maxLap:int = 150;
		
		protected var _hud:FlxGroup;
		
		protected var _score:FlxText;
		protected var _score2:FlxText;
		
		//public var killsScore:int = 0;
		//public var minutesScore:int = 0;
		
		private var aliveTimer:Timer = new Timer(1000 * 60, 0);
		
		private var playerIsDead:Boolean = false;
		
		override public function create():void
		{
			FlxG.mouse.hide();
			
			//FlxG.bgColor = 0xff021610;
			FlxG.bgColor = 0xff052117;
			
			// particles of dead player
			_littleGibs = new FlxEmitter();
			_littleGibs.setXSpeed(-150,150);
			_littleGibs.setYSpeed(-200,0);
			_littleGibs.setRotation(-720,-720);
			_littleGibs.gravity = 350;
			_littleGibs.bounce = 0.5;
			_littleGibs.makeParticles(ImgGibs,10,10,true,0.5);
			
			// groups or pools
			_blocks = new FlxGroup();
			_enemyBullets = new FlxGroup();
			_bullets = new FlxGroup();
			_npcBullets = new FlxGroup();
			
			var spawnPoint:Point = SpawnPointFactory.getSpawnPoint();
			_player = new Player(spawnPoint.x,spawnPoint.y,_bullets, _littleGibs)
			_player.health = 10;
			generateCave();

			add(_littleGibs);
			add(_blocks);

			add(_player);
			
			FlxG.camera.setBounds(0,0,2048,1152,true);
			FlxG.camera.follow(_player,FlxCamera.STYLE_PLATFORMER);

			add(_enemyBullets);
			add(_bullets);
			add(_npcBullets);

			_objects = new FlxGroup();
			_objects.add(_enemyBullets);
			_objects.add(_bullets);
			_objects.add(_player);
			_objects.add(_littleGibs);
			_objects.add(_npcBullets);
			
			FlxG.flash(0xff131c1b);
			
			_pgame = new P2PGame(SERVER + DEVKEY, "quintibustestcave");
			_pgame.addEventListener(Event.CONNECT, onGameConnect);
			_pgame.addEventListener(Event.CHANGE, onUsersChange);
			
			var usr:String = "user"+(Math.round(Math.random()*1000000));
			_pgame.connect(usr);
			
			var spawnPointNpc:Point = SpawnPointFactory.getSpawnPoint();
			_npc = new NonPlayer(spawnPointNpc.x, spawnPointNpc.y, _npcBullets, _littleGibs);
			_npc.health = 10;
			_objects.add(_npc);
			add(_npc);
			
			_hud = new FlxGroup();
			
			_score = new FlxText(2,2,FlxG.width/2);
			_score.setFormat(null, 8, 0xff10895F, "left", 0);
			//_score.text = "Kills: 0\nAlive: 01:32";
			_hud.add(_score);
			FlxG.scores[0] = 0; // [0] current time alive (in minutes)
			FlxG.scores[1] = 0; // [1] current kills
			updateScoreHud();
			
			aliveTimer.addEventListener(TimerEvent.TIMER, onTick);
			aliveTimer.start();
			
			_hud.setAll("scrollFactor",new FlxPoint(0,0));
			_hud.setAll("cameras", [FlxG.camera]);
			add(_hud);
			
			FlxG.playMusic(SndTrack);
		}
		
		private function onTick(e:TimerEvent):void
		{
			FlxG.scores[0] += 1;
			updateScoreHud();
		}
		
		private function updateScoreHud():void {
			var hours:String = String(Math.floor(FlxG.scores[0] / 60));
			var minutes:String = String(FlxG.scores[0] % 60);
			if (minutes.length < 2) {
				minutes = "0" + minutes;
			}
			_score.text = "Alive: " + hours + ":" + minutes + "\nKills: " + FlxG.scores[1];
		}
		
		private function onGameConnect(event:Event):void{
			trace("onGameConnect");
			_pgame.session.mainChat.addEventListener(PeerStatusEvent.USER_ADDED, onUserAdded);
			_pgame.session.mainChat.addEventListener(PeerStatusEvent.USER_REMOVED, onUserRemoved);

			_enemies = new Object();
			_npcenemies = new Object();
			_pgame.setReceivePositionCallback(onReceivePosition);
			_pconnected = true;
		}
		
		private function onUserAdded(event:PeerStatusEvent):void{
			addEnemy(event.info);
		}
		
		private function onUserRemoved(event:PeerStatusEvent):void {
			if (_enemies[event.info.id] == null) {
				return;
			}
			trace("hello");
			_enemies[event.info.id].kill();
			_enemies[event.info.id].alive = false;
			_enemies[event.info.id].exists = false;
			
			_npcenemies[event.info.id].kill();
			_npcenemies[event.info.id].alive = false;
			_npcenemies[event.info.id].exists = false;
			trace("pello");
		}
		
		private function addEnemy(user:Object):void{
			if(user.id != _pgame.session.myUser.id){
				if(_enemies[user.id]==null){
					var enemy:OtherPlayer = new OtherPlayer(32, 32, _enemyBullets, _littleGibs);
					_enemies[user.id] = enemy;
					//_blocks.add(enemy);
					add(enemy);
					var npcenemy:OtherPlayer = new OtherPlayer(32, 32, _enemyBullets, _littleGibs);
					_npcenemies[user.id] = npcenemy;
					add(npcenemy);
				}
			}
		}
		
		private function onUsersChange(event:Event):void{
			trace("Users: \n"+_pgame.session.mainChat.userNamesString);
			for each(var user:Object in _pgame.session.mainChat.userList){
				addEnemy(user);
			}			
		}
		
		protected function onReceivePosition(peerID:String, obj:Object):void {
			if (_enemies[peerID] == null) {
				return;
			}
			trace("hello");
			var enemy:OtherPlayer = _enemies[peerID];
			if(enemy!=null){				
				enemy.xHome = obj.x;
				enemy.yHome = obj.y;
				enemy.facing = obj.facing;
				enemy.aim = obj.aim;
				enemy.shoot = obj.shoot;
				enemy.aniFrame = obj.aniFrame;
				enemy.doFlicker = obj.flicker;
				enemy.doKill = obj.doKill;
				enemy.visible = obj.visible;
			}
			var npcenemy:OtherPlayer = _npcenemies[peerID];
			if(npcenemy!=null){				
				npcenemy.xHome = obj.npcpos.x;
				npcenemy.yHome = obj.npcpos.y;
				npcenemy.facing = obj.npcpos.facing;
				npcenemy.aim = obj.npcpos.aim;
				npcenemy.shoot = obj.npcpos.shoot;
				npcenemy.aniFrame = obj.npcpos.aniFrame;
				npcenemy.doFlicker = obj.npcpos.flicker;
				npcenemy.doKill = obj.npcpos.doKill;
				npcenemy.visible = obj.npcpos.visible;
			}
			trace("pello");
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			_blocks = null;
			_bullets = null;
			_player = null;
			_enemyBullets = null;
			_littleGibs = null;
			_npcBullets = null;
			_npc = null;
			
			_objects = null;
		}

		override public function update():void
		{			
			super.update();
			
			FlxG.collide(_blocks, _objects);
			//trace(npc.velocity.x);
			FlxG.overlap(_enemyBullets, _player, overlapped);
			FlxG.overlap(_npcBullets, _player, overlapped);
			FlxG.overlap(_enemyBullets, _npc, overlapped);
			FlxG.overlap(_bullets, _npc, overlapped);
			
			if(_pconnected){
				sendPlayerUpdates();
			} else {
				//_player.alive = true;
			}
			
			npcLap++;
			//if (npcLap % 50 && !npc.velocity.y && !npc.velocity.x) {
				//npc.velocity.y = -240;
			//}
			/*if (!npc.velocity.y && !npc.velocity.x) {
				npc.velocity.y = -240;
			}*/
			//if (!npc.velocity.y && ((npc.isTouching(FlxObject.LEFT) || npc.isTouching(FlxObject.RIGHT)) || (_player.aim == FlxObject.UP && FlxG.keys.justPressed("C")))) {
			if (!_npc.velocity.y && ((_npc.isTouching(FlxObject.LEFT) || _npc.isTouching(FlxObject.RIGHT)) || (FlxG.keys.justPressed("X") && FlxG.keys.SHIFT))) {
				_npc.velocity.y = -240;
			}
			_npc.tmpVY = _npc.velocity.y;
			if (npcLap > maxLap) {
				//trace("ola");
				var path:FlxPath = level.findPath(new FlxPoint(_npc.x + _npc.width / 2, _npc.y + _npc.height / 2), new FlxPoint(_player.x + _player.width / 2, _player.y + _player.height / 2), true);
				//var path:FlxPath = level.findPath(new FlxPoint(npc.x, npc.y), new FlxPoint(_player.x, _player.y), true);
				//var path:FlxPath = level.findPath(new FlxPoint(npc.x - npc.width / 2, npc.y - npc.height / 2), new FlxPoint(_player.x + _player.width / 2, _player.y + _player.height / 2), true);
				if(path){
					_npc.followPath(path, 60, FlxObject.PATH_HORIZONTAL_ONLY);
				}
				//trace("pola");
				//npc.followPath(path, 100);
				npcLap = 0;
			}
			
			if (_npc.pathSpeed == 0) {
				_npc.stopFollowingPath(true);
				_npc.velocity.x = _npc.velocity.y = 0;
			}
			
			if (!playerIsDead && !_player.alive) {
				trace("player just died");
				playerIsDead = true;
				// do something once, when the player just died
				aliveTimer.stop();
			}
			
			if (playerIsDead && _player.alive) {
				trace("player just revived");
				playerIsDead = false;
				// do something once, when the player just revived
				FlxG.scores[0] = 0;
				FlxG.scores[1] = 0;
				updateScoreHud();
				aliveTimer.start();
			}
		}

		//This is an overlap callback function, triggered by the calls to FlxU.overlap().
		protected function overlapped(Sprite1:FlxSprite,Sprite2:FlxSprite):void
		{
			Sprite2.hurt(1);
			//trace(Sprite1.velocity.x);
			if(Sprite2 is Player){
				if(Sprite1.velocity.x > 0){
					Sprite2.velocity.x += 90;
				}else if (Sprite1.velocity.x < 0) {
					Sprite2.velocity.x -= 90;
				}
			}
			if (Sprite2 is NonPlayer) {
				if(Sprite1.velocity.x > 0){
					_npc.aim = FlxObject.LEFT;
				}else if (Sprite1.velocity.x < 0) {
					_npc.aim = FlxObject.RIGHT;
				}else if (Sprite1.velocity.y > 0) {
					_npc.aim = FlxObject.UP;
				}else if (Sprite1.velocity.y < 0) {
					_npc.aim = FlxObject.DOWN;
				}
				_npc.autoShoot();
			}
			if(Sprite1 is Bullet)
				Sprite1.kill();
		}
		
		protected function generateCave():void {
			level = new FlxTilemap();
			level.loadMap(FlxTilemap.imageToCSV(ImgMap,false,2),ImgTech,0,0,FlxTilemap.ALT);
			_blocks.add(level);
		}
		
		public function sendPlayerUpdates():void
		{
			var pos:Object = new Object();
			pos.x = _player.x;
			pos.y = _player.y;
			pos.facing = _player.facing;
			pos.aim = _player.aim;
			pos.shoot = _player.shoot;
			pos.aniFrame = _player.aniFrame;
			pos.flicker = _player.flickering;
			pos.doKill = !_player.alive;
			pos.visible = _player.visible;
			
			var npcpos:Object = new Object();
			npcpos.x = _npc.x;
			npcpos.y = _npc.y;
			npcpos.facing = _npc.facing;
			npcpos.aim = _npc.aim;
			npcpos.shoot = _npc.shoot;
			npcpos.aniFrame = _npc.aniFrame;
			npcpos.flicker = _npc.flickering;
			//npcpos.doKill = !_npc.alive;
			npcpos.doKill = _npc.justKilled;
			npcpos.visible = _npc.visible;
			
			pos.npcpos = npcpos;
			
			_pgame.sendPosition(pos);
			
			
			// players are only dead long enough until they have sended they have died
			/*if (!_player.alive) {
				_player.alive = true;
			}*/
			_npc.justKilled = false;
		}
	}
}
