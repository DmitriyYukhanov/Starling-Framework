package starling.display.graphics
{
	import flash.display3D.Context3D;
	import starling.core.RenderSupport;
	
	public interface IGraphicsData
	{
		function dispose():void
		function render( renderSupport:RenderSupport, alpha:Number ):void
	}
}