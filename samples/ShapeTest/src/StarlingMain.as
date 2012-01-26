package
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.display.Sprite;
	import starling.display.Shape;
	
	public class StarlingMain extends Sprite
	{
		[Embed( source = "/assets/Checker.png" )]
		private var CheckerBMP		:Class;
		
		private var shape			:Shape;
		
		public function StarlingMain()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			shape = new Shape();
			//shape.rotation = Math.PI * 0.25;
			//shape.x = stage.stageWidth * 0.5;
			//shape.y = stage.stageHeight * 0.5;
			
			addChild(shape);
			
			var checkerBitmap:Bitmap = new CheckerBMP();
			shape.beginBitmapFill( checkerBitmap.bitmapData );
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function mouseDownHandler( event:MouseEvent ):void
		{
			shape.lineTo( Starling.current.nativeStage.mouseX, Starling.current.nativeStage.mouseY, 1, 0 );
		}
		
	}
}