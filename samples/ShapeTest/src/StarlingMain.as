package
{
	import flash.display.Bitmap;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.display.Sprite;
	import starling.display.Shape;
	
	public class StarlingMain extends Sprite
	{
		[Embed( source = "/assets/Checker.png" )]
		private var CheckerBMP		:Class;
		
		private var shape			:Shape;
		
		private var prevPoint		:Point;
		
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
			var m:Matrix = new Matrix();
			m.rotate(Math.PI * 0.25);
			//shape.beginBitmapFill( checkerBitmap.bitmapData, m );
			
			
			
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			shape.clear();
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseDownHandler( event:MouseEvent ):void
		{
			prevPoint = new Point( Starling.current.nativeStage.mouseX, Starling.current.nativeStage.mouseY );
			
			shape.beginFill();
			shape.lineTo( prevPoint.x, prevPoint.y, Math.random(), Math.random(), Math.random() );
			
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			var dx:Number = Starling.current.nativeStage.mouseX - prevPoint.x;
			var dy:Number = Starling.current.nativeStage.mouseY - prevPoint.y;
			if ( dx * dx + dy * dy > 20 )
			{
				prevPoint = new Point( Starling.current.nativeStage.mouseX, Starling.current.nativeStage.mouseY );
				shape.lineTo( prevPoint.x, prevPoint.y, Math.random(), Math.random(), Math.random() );
			}
		}
		
		private function mouseUpHandler( event:MouseEvent ):void
		{
			shape.endFill();
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
	}
}