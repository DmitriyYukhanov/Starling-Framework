package starling.display.materials
{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import starling.display.shaders.IShader;
	
	public interface IMaterial
	{
		function set vertexShader( value:IShader ):void;
		function get vertexShader():IShader;
		function set fragmentShader( value:IShader ):void
		function get fragmentShader():IShader;
		function drawTriangles( context:Context3D, matrix:Matrix3D, vertexBuffer:VertexBuffer3D, indexBuffer:IndexBuffer3D ):void;
	}
	
}