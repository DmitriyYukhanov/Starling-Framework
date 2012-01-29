package starling.display.graphics
{
	public class VertexUtil
	{
		
		static public function flattenVertices( vertices:Vector.<Vertex>, outputVertices:Vector.<Number> ):void
		{
			var L:int = vertices.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var vertex:Vertex = vertices[i];
				outputVertices.push( vertex.x, vertex.y, vertex.z, vertex.r, vertex.g, vertex.b, vertex.a, vertex.u, vertex.v );
			}
		}
		
		private static const EPSILON:Number = 0.0000001
		static public function intersection( a0:Vertex, a1:Vertex, b0:Vertex, b1:Vertex, limit:Boolean = true ):Vertex
		{
			var ux:Number = (a1.x + EPSILON) - (a0.x + EPSILON);
			var uy:Number = (a1.y + EPSILON) - (a0.y + EPSILON);
			
			var vx:Number = (b1.x + EPSILON) - (b0.x + EPSILON);
			var vy:Number = (b1.y + EPSILON) - (b0.y + EPSILON);
			
			var wx:Number = (a0.x + EPSILON) - (b0.x + EPSILON);
			var wy:Number = (a0.y + EPSILON) - (b0.y + EPSILON);
			
			var D:Number = ux * vy - uy * vx
			if (Math.abs(D) < EPSILON) return null
			
			var t:Number = (vx * wy - vy * wx) / D
			if ( limit )
			{
				if (t < 0 || t > 1) return null
				var t2:Number = (ux * wy - uy * wx) / D
				if (t2 < 0 || t2 > 1) return null
			}
			
			return new Vertex(	a0.x + t * (a1.x - a0.x),
								a0.y + t * (a1.y - a0.y),
								a0.z + t * (a1.z - a0.z),
								a0.u + t * (a1.u - a0.u),
								a0.v + t * (a1.v - a0.v),
								a0.r + t * (a1.r - a0.r),
								a0.g + t * (a1.g - a0.g),
								a0.b + t * (a1.b - a0.b),
								a0.a + t * (a1.a - a0.a) );
		}
	}

}