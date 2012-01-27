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
		protected var vertices	:Vector.<Vertex>;
		protected var _matrix	:Matrix;
		
		public function Fill()
		{
			vertices = new Vector.<Vertex>();
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
			
			vertices.push( new Vertex( x, y, 0, 1, 1, 1, 1, textureCoordinate.x, textureCoordinate.y ) );
		}
			
		override public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			if ( vertices.length < 3 ) return;
			
			if ( vertexBuffer == null )
			{
				var indices:Vector.<uint> = triangulate(vertices);
				if ( indices.length < 3 ) return;
				vertexBuffer = Starling.context.createVertexBuffer( vertices.length, Vertex.STRIDE );
				vertexBuffer.uploadFromVector( VertexUtil.flattenVertices(vertices), 0, vertices.length )
				indexBuffer = Starling.context.createIndexBuffer( indices.length );
				indexBuffer.uploadFromVector( indices, 0, indices.length );
			}
			
			super.render( renderSupport, alpha );
		}
		
		private static function triangulate( vertices:Vector.<Vertex> ):Vector.<uint>
		{
			var indices:Vector.<uint> = new Vector.<uint>();
			var openList:Vector.<Vertex> = vertices.slice();
			
			var currentIndex:int = 0;
			var iter:int = 0;
			while ( openList.length > 2 )
			{
				iter++;
				if ( iter > 5000 )
				{
					break;
				}
				currentIndex = currentIndex % openList.length;
				
				if ( openList.length == 3 )
				{
					//trace( "making triangle : " + vertices.indexOf(openList[0]) + ", " + vertices.indexOf(openList[1]) + ", " + vertices.indexOf(openList[2]) );
					indices.push( vertices.indexOf(openList[0]), vertices.indexOf(openList[1]), vertices.indexOf(openList[2]) );
					//trace("finished");
					break;
				}
					
				var previousIndex:int = currentIndex ==  0 ? openList.length - 1 : currentIndex - 1;
				var nextIndex:int = currentIndex == openList.length - 1 ? 0 : currentIndex + 1;
				var v0:Vertex = openList[previousIndex];
				var v1:Vertex = openList[currentIndex];
				var v2:Vertex = openList[nextIndex];
				
				
				//trace( "testing triangle : " + vertices.indexOf(v0) + ", " + vertices.indexOf(v1) + ", " + vertices.indexOf(v2) );
				
				if ( isReflex( v0.x, v0.y, v1.x, v1.y, v2.x, v2.y ) == false )
				{
					//trace("index is not reflex. Skipping. " +vertices.indexOf(v1));
					currentIndex++;
					continue;
				}
				
				var startIndex:int = nextIndex + 1 == openList.length ? 0 : nextIndex + 1;
				var L:int = openList.length - 3;
				var found:Boolean = false;
				for ( var i:int = 0; i < L; i++ )
				{
					var index:int = (startIndex + i) % openList.length;
					var v:Vertex = openList[index];
					//trace("Testing if point is in triangle : " + vertices.indexOf(v));
					
					if ( isPointInTriangle(v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, v.x, v.y) )
					{
						found = true;
						break;
					}
				}
				if ( found )
				{
					//trace("Point found in triangle. Skipping");
					currentIndex++;
					continue;
				}
				
				//trace( "making triangle : " + vertices.indexOf(v0) + ", " + vertices.indexOf(v1) + ", " + vertices.indexOf(v2) );
				indices.push( vertices.indexOf(v0), vertices.indexOf(v1), vertices.indexOf(v2) );
				//trace( "removing vertex : " +vertices.indexOf(v1) );
				openList.splice( currentIndex, 1 );
			}
			
			return indices;
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