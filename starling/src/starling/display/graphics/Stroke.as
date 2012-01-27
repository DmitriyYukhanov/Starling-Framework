package starling.display.graphics
{
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.materials.IMaterial;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.VertexColorFragmentShader;
	import starling.display.shaders.IShader;
	import starling.display.shaders.vertex.RippleVertexShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.textures.Texture;
	
	public class Stroke extends Graphic
	{
		protected var vertices	:Vector.<StrokeVertex>;
		protected var _closed 	:Boolean = false;
		
		public function Stroke()
		{
			vertices = new Vector.<StrokeVertex>();
		}
		
		public function addVertex( 	x:Number, y:Number, thickness:Number = 1,
									r:Number = 1,  g:Number = 1,  b:Number = 1,  a:Number = 1,
									r2:Number = 1, g2:Number = 1, b2:Number = 1, a2:Number = 1 ):void
		{
			if ( vertexBuffer )
			{
				vertexBuffer.dispose();
				vertexBuffer = null;
			}
			
			if ( indexBuffer )
			{
				indexBuffer.dispose();
				indexBuffer = null;
			}
			
			var u:Number = 0;
			var textures:Vector.<Texture> = _material.textures;
			if ( vertices.length > 0 && textures.length > 0 )
			{
				var prevVertex:StrokeVertex = vertices[vertices.length - 1];
				var dx:Number = x - prevVertex.x;
				var dy:Number = y - prevVertex.y;
				var d:Number = Math.sqrt(dx*dx+dy*dy);
				u = prevVertex.u + (d / textures[0].width);
			}
			
			vertices.push( new StrokeVertex( x, y, 0, r, g, b, a, r2, g2, b2, a2, u, 0, thickness ) );
		}
		
		override public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			if ( vertices.length < 3 ) return;
			
			if ( vertexBuffer == null )
			{
				var indices:Vector.<uint> = new Vector.<uint>();
				var renderVertices:Vector.<Number> = new Vector.<Number>();
				
				createPolyLine(vertices, _closed, renderVertices, indices );
				
				if ( indices.length < 3 ) return;
				vertexBuffer = Starling.context.createVertexBuffer( renderVertices.length / Vertex.STRIDE, Vertex.STRIDE );
				vertexBuffer.uploadFromVector( renderVertices, 0, renderVertices.length / Vertex.STRIDE )
				indexBuffer = Starling.context.createIndexBuffer( indices.length );
				indexBuffer.uploadFromVector( indices, 0, indices.length );
			}
			
			super.render( renderSupport, alpha );
		}
		
		private static function createPolyLine( vertices:Vector.<StrokeVertex>, closed:Boolean, outputVertices:Vector.<Number>, outputIndices:Vector.<uint> ):void
		{
			var numVertices:int = vertices.length;
			for ( var i:int = 0; i < numVertices; i++ )
			{
				var v0:StrokeVertex;
				var v1:StrokeVertex = vertices[i];
				var v2:StrokeVertex;
				
				if ( i > 0 )
				{
					v0 = vertices[i - 1];
				}
				else
				{
					v0 = StrokeVertex(v1.clone());
					
				}
				
				if ( i < numVertices - 1 )
				{
					v2 = vertices[i + 1];
				}
				else
				{
					v2 = StrokeVertex(v1.clone());
				}
				
				var d0x:Number = v1.x - v0.x;
				var d0y:Number = v1.y - v0.y;
				var d1x:Number = v2.x - v1.x;
				var d1y:Number = v2.y - v1.y;
				
				if ( i == numVertices - 1 )
				{
					v2.x += d0x;
					v2.y += d0y;
					
					d1x = v2.x - v1.x;
					d1y = v2.y - v1.y;
				}
				
				if ( i == 0 )
				{
					v0.x -= d1x;
					v0.y -= d1y;
					
					d0x = v1.x - v0.x;
					d0y = v1.y - v0.y;
				}
				
				var n0x:Number = -d0y
				var n0y:Number =  d0x;
				var n0m:Number = Math.sqrt(n0x * n0x + n0y * n0y);
				n0x /= n0m;
				n0y /= n0m;
				
				var n1x:Number = -d1y
				var n1y:Number =  d1x;
				var n1m:Number = Math.sqrt(n1x * n1x + n1y * n1y);
				n1x /= n1m;
				n1y /= n1m;
				
				
				
				var p0x:Number = v1.x + n0x * v1.thickness * 0.5;
				var p0y:Number = v1.y + n0y * v1.thickness * 0.5;
				var p2x:Number = v1.x + n1x * v1.thickness * 0.5;
				var p2y:Number = v1.y + n1y * v1.thickness * 0.5;
				
				var i0:Array = intersection(p0x, p0y, p0x +d0x, p0y + d0y, p2x, p2y, p2x + d1x, p2y + d1y );
				
				var p1x:Number = v1.x - n0x * v1.thickness * 0.5;
				var p1y:Number = v1.y - n0y * v1.thickness * 0.5;
				var p3x:Number = v1.x - n1x * v1.thickness * 0.5;
				var p3y:Number = v1.y - n1y * v1.thickness * 0.5;
				
				var i1:Array = intersection(p1x, p1y, p1x +d0x, p1y + d0y, p3x, p3y, p3x + d1x, p3y + d1y );
				
				outputVertices.push(i0[0], i0[1], v1.z, v1.r, v1.g, v1.b, v1.a, v1.u, 1 );
				outputVertices.push(i1[0], i1[1], v1.z, v1.r2, v1.g2, v1.b2, v1.a2, v1.u, 0 );
				
				if ( i < numVertices - 1 )
				{
					var i2:Number = i * 2;
					outputIndices.push(i2, i2 + 2, i2 + 1, i2 + 1, i2 + 2, i2 + 3);
				}
			}
		}
		
		private static const EPSILON:Number = 0.0000001
		static public function intersection( a0x:Number, a0y:Number, a1x:Number, a1y:Number, b0x:Number, b0y:Number, b1x:Number, b1y:Number ):Array
		{
			var ux:Number = (a1x + EPSILON) - (a0x + EPSILON);
			var uy:Number = (a1y + EPSILON) - (a0y + EPSILON);
			
			var vx:Number = (b1x + EPSILON) - (b0x + EPSILON);
			var vy:Number = (b1y + EPSILON) - (b0y + EPSILON);
			
			var wx:Number = (a0x + EPSILON) - (b0x + EPSILON);
			var wy:Number = (a0y + EPSILON) - (b0y + EPSILON);
			
			var D:Number = ux * vy - uy * vx
			if (Math.abs(D) < EPSILON) return [a0x, a0y];
			
			var t:Number = (vx * wy - vy * wx) / D
			
			return [ a0x + t * (a1x - a0x), a0y + t * (a1y - a0y) ];
		}
	}

}