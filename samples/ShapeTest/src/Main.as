package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import starling.core.Starling;
	
	[SWF( width="800", height="600", frameRate="60", backgroundColor="#CCCCCC" )]
	public class Main extends Sprite
	{
		private var mStarling		:Starling;
		
		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			mStarling = new Starling(StarlingMain, stage);
			mStarling.antiAliasing = 1;
			mStarling.start();
			
			//graphics.lineStyle(20, 0xFFFFFF);
			//graphics.moveTo(100, 100);
			//graphics.lineTo(200, 100);
			//graphics.lineTo(300, 200);
		}
	}
}