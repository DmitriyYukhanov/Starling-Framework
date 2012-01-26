package starling.display.graphics
{
	public class Vertex
	{
		public static const STRIDE		:int = 9;
		
		public var x	:Number;
		public var y	:Number;
		public var z	:Number;
		public var r	:Number;
		public var g	:Number;
		public var b	:Number;
		public var a	:Number;
		public var u	:Number;
		public var v	:Number;
		
		public function Vertex( x:Number = 0, y:Number = 0, z:Number = 0, r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1, u:Number = 0, v:Number = 0 )
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.u = u;
			this.v = v;
			this.r = r;// Math.random();
			this.g = g;// Math.random();
			this.b = b;// Math.random();
			this.a = 1;
		}
		
		public function clone():Vertex
		{
			return new Vertex(x, y, z, u, v, r, g, b, a);
		}
	}
}