package starling.display.graphics
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import starling.display.materials.IMaterial;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.display.shaders.vertex.RippleVertexShader;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	
	public class BitmapFill implements IGraphicsData, IFill
	{
		private var vertices		:Vector.<Vertex>;
		private var vertexBuffer	:VertexBuffer3D;
		private var indexBuffer		:IndexBuffer3D;
		private var material		:IMaterial;
		private var texture			:Texture;
		
		private var _bitmapData		:BitmapData;
		
		public function BitmapFill()
		{
			vertices = new Vector.<Vertex>
			material = new StandardMaterial(Starling.context, new RippleVertexShader(), new TextureVertexColorFragmentShader(texture));
		}
		
		public function dispose():void
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
			
			if ( texture )
			{
				texture.dispose();
			}
		}
		
		public function set bitmapData( value:BitmapData ):void
		{
			if ( texture )
			{
				texture.dispose();
			}
			_bitmapData = value;
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		public function addVertex( x:Number, y:Number, r:Number, g:Number, b:Number, a:Number, u:Number, v:Number ):void
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
			
			
			
			vertices.push( new Vertex( x, y, 0, r, g, b, a, u, v ) );
		}
		
		public function render( renderSupport:RenderSupport, alpha:Number ):void
		{
			if ( vertices.length < 3 ) return;
			
			if ( vertexBuffer == null )
			{
				var indices:Vector.<uint> = Triangulator.triangulate(vertices);
				if ( indices.length < 3 ) return;
				vertexBuffer = Starling.context.createVertexBuffer( vertices.length, Vertex.STRIDE );
				vertexBuffer.uploadFromVector( VertexUtil.flattenVertices(vertices), 0, vertices.length )
				indexBuffer = Starling.context.createIndexBuffer( indices.length );
				indexBuffer.uploadFromVector( indices, 0, indices.length );
			}
			
			if ( !texture && bitmapData )
			{
				texture = Starling.context.createTexture( bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false );
				texture.uploadFromBitmapData(bitmapData, 0);
				TextureVertexColorFragmentShader(material.fragmentShader).texture = texture;
			}
			
			//Starling.context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			material.drawTriangles( Starling.context, renderSupport.mvpMatrix, vertexBuffer, indexBuffer );
		}
	}
}