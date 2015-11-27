package  
{
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
		
	/**
	 * ...
	 * @author Quinten Clause
	 */
	
	public class SpulMenu
	{	
		public var contextMenu:ContextMenu;
		
		public function SpulMenu() 
		{
			contextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			var item:ContextMenuItem = new ContextMenuItem("More stuff @ http://strafspul.be");
            contextMenu.customItems.push(item);
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
		}
		
		private function menuItemSelectHandler(e:ContextMenuEvent):void 
		{
			navigateToURL(new URLRequest("http://strafspul.be"), "_blank");
		}
		
	}

}