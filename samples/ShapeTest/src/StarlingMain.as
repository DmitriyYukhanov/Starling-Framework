package
{
	import flash.display.Bitmap;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.display.graphics.Fill;
	import starling.display.graphics.Stroke;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
	import starling.display.shaders.vertex.RippleVertexShader;
	import starling.display.shaders.vertex.StandardVertexShader;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.display.Sprite;
	import starling.textures.Texture;
	//import starling.display.Shape;
	
	public class StarlingMain extends Sprite
	{
		[Embed( source = "/assets/Checker.png" )]
		private var CheckerBMP		:Class;
		[Embed( source = "/assets/Rock.png" )]
		private var RockBMP		:Class;
		[Embed( source = "/assets/Grass.png" )]
		private var GrassBMP		:Class;
		
		private var shape			:Shape;
		
		private var currentPoint	:Point;
		private var prevPoint		:Point;
		
		private var distance		:Number;
		
		private var rockTexture		:Texture;
		
		//private var fill			:Fill;
		//private var stroke			:Stroke;
		
		public function StarlingMain()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded ( e:Event ):void
		{
			shape = new Shape();
			addChild(shape);
			
			rockTexture = Texture.fromBitmap( new RockBMP(), false );
			
			//fill = new Fill();
			//fill.material = new StandardMaterial( new StandardVertexShader(), new TextureVertexColorFragmentShader() );
			//fill.material.textures[0] = Texture.fromBitmap( new RockBMP(), false );
			//addChild(fill);
			
			//stroke = new Stroke();
			//stroke.material = new StandardMaterial( new StandardVertexShader(), new TextureVertexColorFragmentShader() );
			//stroke.material.textures[0] = Texture.fromBitmap( new GrassBMP(), false );
			//addChild(stroke);
		
			currentPoint = new Point();
			prevPoint = new Point();
			
			
			//addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		private var numFrames:int = 0;
		private function enterFrameHandler( event:Event ):void
		{
			shape.clear();
			
			//shape.beginStroke(true);
			shape.beginTexturedFill( rockTexture );
			for ( var i:int = 0; i < 3 * 100; i++ )
			{
				var thickness:Number = 30 + Math.random() * 30;
				shape.lineTo( Math.random() * Starling.current.nativeStage.stageWidth, Math.random() * Starling.current.nativeStage.stageHeight, thickness );
			}
			
			numFrames++;
			if ( numFrames == 500 )
			{
				trace("Finished");
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			shape.clear();
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseDownHandler( event:MouseEvent ):void
		{
			currentPoint.x =  Starling.current.nativeStage.mouseX;
			currentPoint.y =  Starling.current.nativeStage.mouseY;
			prevPoint.x = currentPoint.x;
			prevPoint.y = currentPoint.y;
			
			distance = 0;
			
			var m:Matrix = new Matrix( 1, 0, 0, 1, currentPoint.x, currentPoint.y );
			m.scale(0.5, 0.5);
			m.translate(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight);
			shape.beginTexturedFill( Texture.fromBitmap( new RockBMP(), false ), m );
			shape.beginTexturedStroke( Texture.fromBitmap( new GrassBMP(), false ) );
			
			var thickness:Number = 30 + Math.random() * 30;
			shape.lineTo( currentPoint.x, currentPoint.y, thickness );
			
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			currentPoint.x += (Starling.current.nativeStage.mouseX - currentPoint.x) * 1;
			currentPoint.y += (Starling.current.nativeStage.mouseY - currentPoint.y) * 1;
				
			var dx:Number = currentPoint.x - prevPoint.x;
			var dy:Number = currentPoint.y - prevPoint.y;
			var d:Number = Math.sqrt( dx * dx + dy * dy );
			
			if ( d > 20 )
			{
				distance += d;
				
				prevPoint.x = currentPoint.x;
				prevPoint.y = currentPoint.y;
				
				var thickness:Number = 30 + Math.random() * 30;
				shape.lineTo( currentPoint.x, currentPoint.y, thickness );
			}
		}
		
		private function mouseUpHandler( event:MouseEvent ):void
		{
			shape.endFill();
			shape.endStroke();
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
	}
}