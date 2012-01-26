package starling.display.graphics
{
	import flash.display3D.IndexBuffer3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class Triangulator
	{
		public static function triangulate( vertices:Vector.<Vertex> ):Vector.<uint>
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
		
		public static function explode(vertices:Vector.<Vertex>, indices:Vector.<uint>, outputVertices:Vector.<Vertex>, outputIndices:Vector.<uint> ):Boolean
		{
			if ( indices.length % 3 != 0 )
			{
				throw( new Error( "Supplied indicies not multiple of three" ) );
				return false;
			}
			
			for ( var i:int = 0; i < indices.length; i += 3 )
			{
				outputVertices.push(vertices[indices[i]].clone() , vertices[indices[i + 1]].clone(), vertices[indices[i + 2]].clone());
				outputIndices.push( i, i + 1, i + 2 );
			}
			return true;
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