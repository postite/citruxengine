package com.citrusengine.view.blittingview;

import com.citrusengine.math.MathVector;
import com.citrusengine.view.CitrusView;
import com.citrusengine.view.ISpriteView;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.GetDefinitionByName;

class BlittingView extends CitrusView {
	public var cameraPosition(getCameraPosition, never) : MathVector;

	public var backgroundColor : Float;
	var _canvasBitmap : Bitmap;
	var _canvas : BitmapData;
	var _spriteOrder : Array<Dynamic>;
	var _spritesAdded : UInt;
	var _cameraPosition : MathVector;
	public function new(root : Sprite) {
		backgroundColor = 0xffffffff;
		_spriteOrder = [];
		_spritesAdded = 0;
		_cameraPosition = new MathVector();
		super(root, ISpriteView);
		_canvas = new BitmapData(cameraLensWidth, cameraLensHeight, true, backgroundColor);
		_canvasBitmap = new Bitmap(_canvas);
		root.addChild(_canvasBitmap);
	}

	public function getCameraPosition() : MathVector {
		return _cameraPosition;
	}

	override public function update() : Void {
		super.update();
		//Update Camera
		if(cameraTarget)  {
			//Update camera position
			var diffX : Float = (cameraTarget.x - cameraOffset.x) - _cameraPosition.x;
			var diffY : Float = (cameraTarget.y - cameraOffset.x) - _cameraPosition.y;
			var velocityX : Float = diffX * cameraEasing.x;
			var velocityY : Float = diffY * cameraEasing.y;
			_cameraPosition.x += velocityX;
			_cameraPosition.y += velocityY;
			//Constrain to camera bounds
			if(cameraBounds)  {
				if(_cameraPosition.x <= cameraBounds.left || cameraBounds.width < cameraLensWidth) _cameraPosition.x = cameraBounds.left
				else if(_cameraPosition.x + cameraLensWidth >= cameraBounds.right) _cameraPosition.x = cameraBounds.right - cameraLensWidth;
				if(_cameraPosition.y <= cameraBounds.top || cameraBounds.height < cameraLensHeight) _cameraPosition.y = cameraBounds.top
				else if(_cameraPosition.y + cameraLensHeight >= cameraBounds.bottom) _cameraPosition.y = cameraBounds.bottom - cameraLensHeight;
			}
		}
		_canvas.lock();
		_canvas.fillRect(new Rectangle(0, 0, cameraLensWidth, cameraLensHeight), backgroundColor);
		var n : Float = _spriteOrder.length;
		var i : Int = 0;
		while(i < n) {
			updateArt(_spriteOrder[i].citrusObject, _spriteOrder[i]);
			i++;
		}
		_canvas.unlock();
	}

	public function updateCanvas() : Void {
		_canvas = new BitmapData(cameraLensWidth, cameraLensHeight, true, backgroundColor);
		_canvasBitmap.bitmapData = _canvas;
	}

	override function createArt(citrusObject : Dynamic) : Dynamic {
		var viewObject : ISpriteView = try cast(citrusObject, ISpriteView) catch(e) null;
		var blittingArt : BlittingArt;
		if(Std.is(viewObject.view, BlittingArt))  {
			blittingArt = try cast(viewObject.view, BlittingArt) catch(e) null;
		}

		else if(Std.is(viewObject.view, String))  {
			var artClass : Class<Dynamic> = Type.getClass(getDefinitionByName(try cast(viewObject.view, String) catch(e) null));
			blittingArt = try cast(new ArtClass(), BlittingArt) catch(e) null;
		}
		if(!blittingArt)  {
			trace("Warning: the 'view' property of " + viewObject + " must be a BlittingArt object since you are using the BlittingView");
			blittingArt = new BlittingArt();
		}
		blittingArt.addIndex = _spritesAdded++;
		blittingArt.group = viewObject.group;
		blittingArt.initialize(citrusObject);
		blittingArt.registration = viewObject.registration;
		blittingArt.offset = new MathVector(viewObject.offsetX, viewObject.offsetY);
		_spriteOrder.push(blittingArt);
		updateGroupSorting();
		return blittingArt;
	}

	override function destroyArt(citrusObject : Dynamic) : Void {
		var art : BlittingArt = _viewObjects[citrusObject];
		_spriteOrder.splice(_spriteOrder.indexOf(art), 1);
	}

	override function updateArt(citrusObject : Dynamic, art : Dynamic) : Void {
		var bart : BlittingArt = try cast(art, BlittingArt) catch(e) null;
		var object : ISpriteView = try cast(citrusObject, ISpriteView) catch(e) null;
		//shortcut
		var ca : AnimationSequence = bart.currAnimation;
		if(!ca || !object.visible) return;
		bart.play(object.animation);
		var position : Point = new Point();
		position.x = (object.x - _cameraPosition.x) * object.parallax;
		position.y = (object.y - _cameraPosition.y) * object.parallax;
		//handle registration
		if(bart.registration == "center")  {
			position.x -= ca.frameWidth * 0.5;
			position.y -= ca.frameHeight * 0.5;
		}
		if(bart.group != object.group)  {
			bart.group = object.group;
			updateGroupSorting();
		}
		var rect : Rectangle = new Rectangle();
		if(object.inverted && ca.invertedBitmapData) rect.x = ca.bitmapData.width - ca.frameWidth - ((ca.currFrame % ca.numColumns) * ca.frameWidth) - bart.offset.x
		else rect.x = (ca.currFrame % ca.numColumns) * ca.frameWidth + bart.offset.x;
		rect.y = int(ca.currFrame / ca.numColumns) * ca.frameHeight + bart.offset.y;
		rect.width = ca.frameWidth;
		rect.height = ca.frameHeight;
		//draw
		_canvas.copyPixels(((object.inverted && ca.invertedBitmapData)) ? ca.invertedBitmapData : ca.bitmapData, rect, position, null, null, true);
		//increment the frame
		ca.currFrame++;
		if(ca.currFrame >= ca.numFrames)  {
			if(ca.loop) ca.currFrame = 0
			else ca.currFrame = ca.numFrames - 1;
		}
	}

	function updateGroupSorting() : Void {
		_spriteOrder.sortOn(["group", "addIndex"], Array.NUMERIC);
	}

}

