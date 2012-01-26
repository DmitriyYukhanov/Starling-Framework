package starling.display
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.graphics.IGraphicsData;
	import starling.display.graphics.IFill;
	import starling.display.graphics.BitmapFill;
	
	public class Shape extends DisplayObject
	{
		private var penPositionPrev	:Point;
		private var penPosition		:Point;
		private var graphicsData	:Vector.<IGraphicsData>
		
		private var currentFill		:IFill;
		
		public function Shape()
		{
			graphicsData = new Vector.<IGraphicsData>();
			penPosition = new Point();
			penPositionPrev = new Point();
		}
		
		override public function dispose():void
		{
			super.dispose();
			for ( var i:int = 0; i < graphicsData.length; i++ )
			{
				graphicsData[i].dispose();
			}
			graphicsData = null;
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            return new Rectangle();
        }
		
		public function clear():void
		{
			for ( var i:int = 0; i < graphicsData.length; i++ )
			{
				graphicsData[i].dispose();
			}
			graphicsData = new Vector.<IGraphicsData>();
			penPosition = new Point();
			penPositionPrev = new Point();
		}
		
		public function beginBitmapFill( bitmapData:BitmapData, m:Matrix = null, smoothing:Boolean = false ):void
		{
			currentFill = new BitmapFill();
			BitmapFill(currentFill).bitmapData = bitmapData;
			graphicsData.push(currentFill);
		}
		
		public function endFill():void
		{
			if ( !currentFill ) return;
			currentFill = null;
		}
		
		public function moveTo( x:Number, y:Number ):void
		{
			penPositionPrev.x = penPosition.x;
			penPositionPrev.y = penPosition.y;
			penPosition.x = x;
			penPosition.y = y;
		}
		
		public function lineTo( x:Number, y:Number, r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1, u:Number = -1, v:Number = -1 ):void
		{
			penPositionPrev.x = penPosition.x;
			penPositionPrev.y = penPosition.y;
			penPosition.x = x;
			penPosition.y = y;
			
			if ( currentFill )
			{
				currentFill.addVertex( x, y, r, g, b, a, u, v );
			}
		}
		
		override public function render(support:RenderSupport, alpha:Number):void
		{
			for ( var i:int = 0; i < graphicsData.length; i++ )
			{
				graphicsData[i].render(support, alpha);
			}
		}
	}
}