package starling.display.graphics
{
	public class StrokeVertex extends Vertex
	{
		public var thickness:Number;
		public var r2:Number;
		public var g2:Number;
		public var b2:Number;
		public var a2:Number;
		
		public function StrokeVertex( x:Number = 0, y:Number = 0, z:Number = 0, r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1, r2:Number = 1, g2:Number = 1, b2:Number = 1, a2:Number = 1, u:Number = 0, v:Number = 0, thickness:Number = 1 )
		{
			super( x, y, z, r, g, b, a, u, v );
			this.r2 = r2;
			this.g2 = g2;
			this.b2 = b2;
			this.a2 = a2;
			this.thickness = thickness;
		}
		
		override public function clone():Vertex
		{
			return new StrokeVertex(x, y, z, r, g, b, a, r2, g2, b2, a2, u, v);
		}
	}
}