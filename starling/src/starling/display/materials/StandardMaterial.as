package starling.display.materials
{
	import com.adobe.utils.AGALMiniAssembler;
	import starling.display.shaders.fragment.VertexColorFragmentShader;
	import starling.display.shaders.IShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;

	public class StandardMaterial implements IMaterial
	{
		private var program	:Program3D;
		
		private var _vertexShader	:IShader;
		private var _fragmentShader	:IShader;
		
		public function StandardMaterial( context:Context3D, vertexShader:IShader = null, fragmentShader:IShader = null )
		{
			this.vertexShader = vertexShader || new StandardVertexShader();
			this.fragmentShader = fragmentShader || new VertexColorFragmentShader();
		}
		
		public function set vertexShader( value:IShader ):void
		{
			_vertexShader = value;
			if ( program )
			{
				program.dispose();
				program = null;
			}
		}
		
		public function get vertexShader():IShader
		{
			return _vertexShader;
		}
		
		public function set fragmentShader( value:IShader ):void
		{
			_fragmentShader = value;
			if ( program )
			{
				program.dispose();
				program = null;
			}
		}
		
		public function get fragmentShader():IShader
		{
			return _fragmentShader;
		}
		
		public function drawTriangles( context:Context3D, matrix:Matrix3D, vertexBuffer:VertexBuffer3D, indexBuffer:IndexBuffer3D ):void
		{
			context.setVertexBufferAt( 0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			context.setVertexBufferAt( 1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_4 );
			context.setVertexBufferAt( 2, vertexBuffer, 7, Context3DVertexBufferFormat.FLOAT_2 );
			
			if ( program == null && _vertexShader && _fragmentShader )
			{
				program = context.createProgram();
				program.upload( _vertexShader.opCode, _fragmentShader.opCode );
			}
			context.setProgram(program);
			
			_vertexShader.setConstants(context, 4);
			_fragmentShader.setConstants(context, 0);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			
			context.drawTriangles(indexBuffer);
		}
	}
}