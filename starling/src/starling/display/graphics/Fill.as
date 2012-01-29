package starling.display.graphics
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.materials.IMaterial;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.textures.Texture;
	
	public class Fill extends Graphic
	{
		protected var vertices	:Vector.<Number>;
		protected var _matrix	:Matrix;
		
		public function Fill()
		{
			vertices = new Vector.<Number>();
			_matrix = new Matrix();
		}
		
		public function set matrix( value:Matrix ):void
		{
			_matrix = value;
		}
		
		public function get matrix():Matrix
		{
			return _matrix;
		}
		
		public function addVertex( x:Number, y:Number, r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1 ):void
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
			
			var textureCoordinate:Point = new Point(x, y)
			
			var textures:Vector.<Texture> = _material.textures;
			if ( textures.length > 0 )
			{
				textureCoordinate.x /= textures[0].width;
				textureCoordinate.y /= textures[0].height;
				
				var invert:Matrix = _matrix.clone();
				invert.invert();
				textureCoordinate = invert.transformPoint(textureCoordinate);
				
				
				
				//u = x / textures[0].width;
				//v = y / textures[0].height;
			}
			
			vertices.push( x, y, 0, 1, 1, 1, 1, textureCoordinate.x, textureCoordinate.y );
		}
			
		override public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			if ( vertices.length < Vertex.STRIDE * 3 ) return;
			
			if ( vertexBuffer == null )
			{
				var triangulatedData:Array = triangulate(vertices);
				var renderVertices:Vector.<Number> = triangulatedData[0];
				var indices:Vector.<uint> = triangulatedData[1];
				
				if ( indices.length < 3 ) return;
				var numVertices:int = renderVertices.length / Vertex.STRIDE;
				vertexBuffer = Starling.context.createVertexBuffer( numVertices, Vertex.STRIDE );
				vertexBuffer.uploadFromVector( renderVertices, 0, numVertices )
				indexBuffer = Starling.context.createIndexBuffer( indices.length );
				indexBuffer.uploadFromVector( indices, 0, indices.length );
			}
			
			super.render( renderSupport, alpha );
		}
		
		private static function triangulate( vertices:Vector.<Number> ):Array
		{
			var numVertices:int = vertices.length / Vertex.STRIDE;
			var numTriangles:int = numVertices - 2;
			var numIndices:int = numTriangles * 3;
			
			var outputVertices:Vector.<Number> = new Vector.<Number>();
			var outputIndices:Vector.<uint> = new Vector.<uint>();
			
			var vertexList:VertexList = VertexList.build(vertices, Vertex.STRIDE);
			
			var wn:int = windingNumber(vertexList);
			if ( windingNumber( vertexList ) < 0 )
			{
				VertexList.reverse(vertexList);
			}
			
			
			var iter:int = 0;
			var currentNode:VertexList = vertexList.head;
			while ( true )
			{
				iter++;
				if ( iter > numTriangles*2 )
				{
					break;
				}
				
				var n0:VertexList = currentNode.prev;
				var n1:VertexList = currentNode;
				var n2:VertexList = currentNode.next;
				
				// If vertex list is 3 long.
				if ( n2.next == n0)
				{
					//trace( "making triangle : " + n0.index + ", " + n1.index + ", " + n2.index );
					outputIndices.push( n0.index, n1.index, n2.index );
					break;
				}
				
				var v0x:Number = n0.vertex[0];
				var v0y:Number = n0.vertex[1];
				var v1x:Number = n1.vertex[0];
				var v1y:Number = n1.vertex[1];
				var v2x:Number = n2.vertex[0];
				var v2y:Number = n2.vertex[1];
				
				
				//trace( "testing triangle : " + n0.index + ", " + n1.index + ", " + n2.index );
				
				if ( isReflex( v0x, v0y, v1x, v1y, v2x, v2y ) == false )
				{
					//trace("index is not reflex. Skipping. " + n1.index);
					currentNode = currentNode.next;
					continue;
				}
				
				var startNode:VertexList = n2.next;
				var n:VertexList = startNode;
				var found:Boolean = false;
				while ( n != n0 )
				{
					//trace("Testing if point is in triangle : " + n.index);
					if ( isPointInTriangle(v0x, v0y, v1x, v1y, v2x, v2y, n.vertex[0], n.vertex[1]) )
					{
						found = true;
						break;
					}
					n = n.next;
				}
				
				if ( found )
				{
					//trace("Point found in triangle. Skipping");
					currentNode = currentNode.next;
					continue;
				}
				
				//trace( "making triangle : " + n0.index + ", " + n1.index + ", " + n2.index );
				outputIndices.push( n0.index, n1.index, n2.index );
				//trace( "removing vertex : " + n1.index );
				if ( n1 == n1.head )
				{
					n1.vertex = n2.vertex;
					n1.next = n2.next;
					n1.index = n2.index;
					n1.next.prev = n1;
					VertexList.releaseNode( n2 );
				}
				else
				{
					n0.next = n2;
					n2.prev = n0;
					VertexList.releaseNode( n1 );
				}
				
				currentNode = n0;
			}
			//while ( currentNode != vertexList.head )
			
			//trace("finished");
			//trace("");
			
			return [vertices, outputIndices];
		}
		
		private static function windingNumber( vertexList:VertexList ):int
		{
			var wn:int = 0;
			var node:VertexList = vertexList.head;
			do
			{
				var isLeftResult:Boolean = isLeft( node.vertex[0], node.vertex[1], node.next.vertex[0], node.next.vertex[1], node.next.next.vertex[0], node.next.next.vertex[1] );
				wn += isLeftResult ? -1 : 1;
				node = node.next;
			}
			while ( node != vertexList.head )
			
			return wn;
		}
		
		private static function isLeft(v0x:Number, v0y:Number, v1x:Number, v1y:Number, px:Number, py:Number):Boolean
		{
			return ((v1x - v0x)*(py - v0y) - (px - v0x)*(v1y-v0y)) < 0;
		}
		
		private static function isPointInTriangle(v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, px:Number, py:Number ):Boolean
		{
			if ( isLeft( v0x, v0y, v1x, v1y, px, py ) ) return false;
			if ( isLeft( v1x, v1y, v2x, v2y, px, py ) ) return false;
			if ( isLeft( v2x, v2y, v0x, v0y, px, py ) ) return false;
			return true;
		}
		
		private static function isReflex( v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number ):Boolean
		{
			if ( isLeft( v0x, v0y, v1x, v1y, v2x, v2y ) ) return false;
			if ( isLeft( v1x, v1y, v2x, v2y, v0x, v0y ) ) return false;
			return true;
		}
	}
}