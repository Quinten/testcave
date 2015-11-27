package  
{
	import flash.geom.Point;

	public class SpawnPointFactory
	{
		private static var _points:Array = new Array();
		private static var _scaleFactor:int = 16;
		
		_points[0] = [2, 2];
		_points[1] = [43, 5];
		_points[2] = [25, 25];
		_points[3] = [4, 35];
		_points[4] = [124, 2];
		_points[5] = [115, 20];
		_points[6] = [40, 49];
		_points[7] = [12, 56];
		_points[8] = [113, 41];
		_points[9] = [76, 18];
		_points[10] = [73, 31];
		_points[11] = [123, 68];
		_points[12] = [50, 18];
		_points[13] = [5, 61];
		_points[14] = [78, 3];
		_points[15] = [97, 29];
		
		public static function getSpawnPoint():Point {
			var randomIndex:int = Math.floor(Math.random() * _points.length);
			randomIndex = 7;
			trace("spawnpoint = " + randomIndex);// if we get stuck in a wall, we can see which spawnpoint needs to be adjusted
			return new Point(_points[randomIndex][0] * _scaleFactor, _points[randomIndex][1] * _scaleFactor);
		}
		
	}
}