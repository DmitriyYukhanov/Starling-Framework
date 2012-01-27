package starling.display
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.graphics.Fill;
	import starling.display.graphics.Stroke;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.textures.Texture;
	
	public class Shape extends DisplayObjectContainer
	{
		private var penPositionPrev	:Point;
		private var penPosition		:Point;
		
		private var currentFill		:Fill;
		private var currentStroke	:Stroke;
		
		public function Shape()
		{
			penPosition = new Point();
			penPositionPrev = new Point();
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            return new Rectangle();
        }
		
		public function clear():void
		{
			while ( numChildren > 0 )
			{
				var child:DisplayObject = getChildAt(0);
				child.dispose();
				removeChildAt(0);
			}
		}
		
		public function beginStroke( closed:Boolean = false ):Stroke
		{
			currentStroke = new Stroke();
			addChild(currentStroke);
			return currentStroke;
		}
		
		public function beginTexturedStroke( texture:Texture, closed:Boolean = false ):Stroke
		{
			currentStroke = new Stroke();
			currentStroke.material.fragmentShader = new TextureVertexColorFragmentShader();
			currentStroke.material.textures[0] = texture;
			addChild(currentStroke);
			return currentStroke;
		}
		
		public function endStroke():void
		{
			currentStroke = null;
		}
		
		public function beginFill():Fill
		{
			currentFill = new Fill()
			addChild(currentFill);
			return currentFill;
		}
		
		public function beginTexturedFill( texture:Texture, m:Matrix = null ):Fill
		{
			currentFill = new Fill()
			currentFill.material.fragmentShader = new TextureVertexColorFragmentShader();
			currentFill.material.textures[0] = texture;
			if ( m )
			{
				currentFill.matrix = m;
			}
			addChild(currentFill);
			return currentFill;
		}
		
		public function endFill():void
		{
			currentFill = null;
		}
		
		public function moveTo( x:Number, y:Number ):void
		{
			penPositionPrev.x = penPosition.x;
			penPositionPrev.y = penPosition.y;
			penPosition.x = x;
			penPosition.y = y;
		}
		
		public function lineTo( x:Number, y:Number, thickness:Number = 1, r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1, r2:Number = 1, g2:Number = 1, b2:Number = 1, a2:Number = 1 ):void
		{
			penPositionPrev.x = penPosition.x;
			penPositionPrev.y = penPosition.y;
			penPosition.x = x;
			penPosition.y = y;
			
			if ( currentFill )
			{
				currentFill.addVertex( x, y, r, g, b, a );
			}
			
			if ( currentStroke )
			{
				currentStroke.addVertex( x, y, thickness, r, g, b, a, r2, g2, b2, a2 );
			}
		}
	}
}