package
{	
	import org.flixel.*;

	public class MenuState extends FlxState
	{
		[Embed(source="data/cursor.png")] public var ImgCursor:Class;
		
		override public function create():void
		{
			FlxG.bgColor = 0xff052117;
			
			FlxG.mouse.show(ImgCursor, 2);
			
			var flixelButton:FlxButton = new FlxButton(FlxG.width/2-40,FlxG.height/2,"enter",onEnter);
			flixelButton.color = 0xff0A4230;
			flixelButton.label.color = 0xff10895F;
			add(flixelButton);
		}
		
		override public function destroy():void
		{
			super.destroy();
		}

		override public function update():void
		{	
			super.update();
		}
		
		protected function onEnter():void
		{
			FlxG.switchState(new StartState());
		}
	}
}
