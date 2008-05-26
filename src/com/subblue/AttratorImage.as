package com.subblue
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.graphics.codec.PNGEncoder;

	public class AttratorImage extends Image
	{
		public var a:Number = 2;
		public var b:Number = -2;
		public var c:Number = 2;
		public var d:Number = -2;
		public var drawing:Boolean = true;
		public var useAttractor:int = 0;		// Select the attractor method to use
		public var color:uint = 0x000000;		// Colour of plotted point
		public var intensity:int = 3;			// Increment the intensity of the plotted point
		public var bgColor:uint = 0xFFFFFF; 	// Background colour
		public var resolution:Number = 1;		// Resolution of render
		
		private var ow:int;						// Original width
		private var oh:int;						// Original height
		private var ox:int;						// x-origin
		private var oy:int;						// y-origin
		private var scale:Array;				// Scaling factor
		private var p:Array = [Math.random(),Math.random()];
		private var bmpd:BitmapData;
		private var baseColor:uint;
		
		public function AttratorImage()
		{
			super();
		}
		
		public function setup():void
		{
			ow = this.width;
			oh = this.height;
			reset();
		}
		
		public function update():void
		{
			this.source = render();
		} 
		
		public function reset():void
		{
			setResolution();
			var a:uint = bgColor == 0xFFFFFF ? 0x00 : 0xFF;
			baseColor = (a << 24) | bgColor;
			bmpd = new BitmapData(this.width, this.height, true, baseColor);
		}
		
 		override public function get source():Object
		{
			return render();
		}
		
		public function export():ByteArray
		{
			var pngenc:PNGEncoder = new PNGEncoder();
			return pngenc.encode(bmpd);
		}
		
		public function params():String
		{
			return String(useAttractor + " a" + a + " b" + b + " c" + c + " d" + d + " s" + resolution);
		}
		
		private function setResolution():void
		{
			this.scaleX = this.scaleY = resolution;
			this.width = ow * resolution;
			this.height = oh * resolution;
			scale = setScale();
			ox = this.width / 2;
			oy = this.height / 2;
		}
		
		private function render():Object
		{
			if (drawing) {
				bmpd.lock();
				for (var i:int = 0; i < 10000; i++) {
					if (useAttractor == 0) {
						p = peterDeJongAttractor(p[0], p[1]);
					} else {
						p = cliffordAttractor(p[0], p[1]);
					}
				}
				bmpd.unlock();
			}
			return new Bitmap(bmpd);
		}
		
		// Peter de Jong attractor:
		// x' = sin(a * y) - cos(b * x)
		// y' = sin(c * x) - cos(d * y)
		private function peterDeJongAttractor(x:Number, y:Number):Array
		{
			var p:Array = [];
			var xn:Number, yn:Number;

			p[0] = Math.sin(a * y) - Math.cos(b * x);
			p[1] = Math.sin(c * x) - Math.cos(d * y);
			xn = ox + (p[0] * scale[0]);
			yn = oy + (p[1] * scale[1]);
			
			bmpd.setPixel32(xn, yn, setColor(bmpd.getPixel32(xn, yn)));
			
			return p;
		}
		
		// Clifford attractor:
		// x' = sin(a * y) + c * cos(a * x)
		// y' = sin(b * x) + d * cos(b * y)
		private function cliffordAttractor(x:Number, y:Number):Array
		{
			var p:Array = [];
			var xn:Number, yn:Number;

			p[0] = Math.sin(a * y) + c * Math.cos(a * x);
			p[1] = Math.sin(b * x) + d * Math.cos(b * y);
			xn = ox + (p[0] * scale[0]);
			yn = oy + (p[1] * scale[1]);
			
			bmpd.setPixel32(xn, yn, setColor(bmpd.getPixel32(xn, yn)));
			
			return p;
		}
		
		
		private function setColor(col:uint):uint
		{
			var colAlpha:Number = col == baseColor ? 0x00 : (col & 0xFF000000) >>> 24;
			var newAlpha:Number = Math.min(255, colAlpha + intensity);
			return (newAlpha << 24) | color;
		}
		
		private function setScale():Array
		{
			if (useAttractor == 0) {
				return [100 * resolution, 100 * resolution];
			} else {
				//return (1 / Math.max(Math.abs(c), Math.abs(d))) * resolution * 150;
				return [(1 / Math.abs(c)) * resolution * 150, (1 / Math.abs(d)) * resolution * 150];
			}
			
		}
	}
}