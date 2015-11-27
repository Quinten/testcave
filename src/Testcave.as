package
{
	import net.hires.debug.Stats;
	import org.flixel.*;
	
	[SWF(width = "640", height = "480", backgroundColor = "#052117")]
	[FRAME(factoryClass="Preloader")]
	public class Testcave extends FlxGame
	{
		public function Testcave()
		{
			super(320, 240, MenuState, 2, 25, 25);
			forceDebugger = true;
			FlxG.mobile = true;
			
			var spulMenu:SpulMenu = new SpulMenu();
			this.contextMenu = spulMenu.contextMenu;
		}
	}
}