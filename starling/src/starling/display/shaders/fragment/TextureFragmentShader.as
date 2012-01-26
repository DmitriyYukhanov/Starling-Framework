package starling.display.shaders.fragment
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import starling.shaders.AbstractShader;
	
	public class TextureFragmentShader extends AbstractShader
	{
		public var texture		:Texture;
		
		public function TextureFragmentShader( texture:Texture )
		{
			this.texture = texture;
			
			var agal:String =
			"tex ft1, v1, fs0 <2d, repeat, linear> \n" +
			"mov oc, ft1"
			
			compileAGAL( Context3DProgramType.FRAGMENT, agal );
		}
		
		override public function setConstants( context:Context3D, firstRegister:int ):void
		{
			context.setTextureAt(0, texture);
		}
	}
}