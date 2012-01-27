/**
 * Animation Sequence represents a single animation sprite sheet. You will create one animation sequence per animation that your
 * character has. Your animation sequences will be added to a <code>BlittingArt</code> object, which is the primary art object that
 * represents your character in a Blitting view.
 */
package com.citrusengine.view.blittingview;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;

class AnimationSequence {
	public var frameWidth(getFrameWidth, never) : Float;
	public var frameHeight(getFrameHeight, never) : Float;
	public var numRows(getNumRows, never) : Float;
	public var numColumns(getNumColumns, never) : Float;
	public var numFrames(getNumFrames, never) : Float;

	public var loop : Bool;
	public var currFrame : Float;
	public var bitmapData : BitmapData;
	public var invertedBitmapData : BitmapData;
	public var name : String;
	var _frameWidth : Float;
	var _frameHeight : Float;
	var _numFrames : Float;
	var _numRows : Float;
	var _numColumns : Float;
	/**
	 * Creates a new AnimationSequence, to be added to your character's BlittinArt.
	 * @param	bitmap A Bitmap class, BitmapData class, or Bitmap object that creates a BitmapData sprite sheet. This is usually an embedded graphic class.
	 * @param	name A name representing what the animation sequence is, such as "walk", "jump", or "die".
	 * @param	frameWidth The width of a single frame in your sprite sheet animation.
	 * @param	frameHeight The height of a single frame in your sprite sheet animation.
	 * @param	loop When your animation reaches the last frame, does it start over (true) or just stay at the end (false)?
	 * @param	willInvert Should we generate an inverted copy of your bitmap? (useful for things that walk left and right).
	 */
	public function new(bitmap : Dynamic, name : String = "", frameWidth : Float = 0, frameHeight : Float = 0, loop : Bool = true, willInvert : Bool = false) {
		currFrame = 0;
		this.name = name;
		var bitmapObject : Bitmap;
		if(Std.is(bitmap, Class))  {
			bitmapObject = try cast(new Bitmap(), Bitmap) catch(e) null;
			if(!bitmapObject) bitmapData = try cast(new Bitmap(), BitmapData) catch(e) null;
		}

		else  {
			bitmapObject = bitmap;
		}

		if(!bitmapData) bitmapData = bitmapObject.bitmapData;
		if(willInvert)  {
			var matrix : Matrix = new Matrix();
			matrix.scale(-1, 1);
			matrix.translate(bitmapData.width, 0);
			invertedBitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0x00000000);
			invertedBitmapData.draw(bitmapData, matrix);
		}
		_frameWidth = frameWidth;
		if(_frameWidth == 0) _frameWidth = bitmapData.width;
		_frameHeight = frameHeight;
		if(_frameHeight == 0) _frameHeight = bitmapData.height;
		if(bitmapData.width % _frameWidth != 0)  {
			trace("Warning: You did not specify a valid frame width in animation " + name + ". The frame width is not evenly divisible by the bitmap width.");
		}
		if(bitmapData.height % _frameHeight != 0)  {
			trace("Warning: You did not specify a valid frame height in animation " + name + ". The frame height is not evenly divisible by the bitmap height.");
		}
		_numRows = Math.round(bitmapData.height / _frameHeight);
		_numColumns = Math.round(bitmapData.width / _frameWidth);
		_numFrames = _numRows * _numColumns;
		this.loop = loop;
	}

	public function getFrameWidth() : Float {
		return _frameWidth;
	}

	public function getFrameHeight() : Float {
		return _frameHeight;
	}

	public function getNumRows() : Float {
		return _numRows;
	}

	public function getNumColumns() : Float {
		return _numColumns;
	}

	public function getNumFrames() : Float {
		return _numFrames;
	}

}

