/**
 * StarlingView is based on  Adobe Stage3D and the Starling framework to render graphics. 
 * It creates and manages graphics like the traditional Flash display list thanks to Starling :
 * (addChild(), removeChild()) using Starling DisplayObjects (MovieClip, Image, Sprite, Quad etc).
 */
package com.citrusengine.view.starlingview;

import starling.display.Sprite;
import com.citrusengine.view.CitrusView;
import com.citrusengine.view.ISpriteView;
import com.citrusengine.view.spriteview.Box2DDebugArt;
import flash.display.MovieClip;

class StarlingView extends CitrusView {
	public var viewRoot(getViewRoot, never) : Sprite;

	var _viewRoot : Sprite;
	public function new(root : Sprite) {
		super(root, ISpriteView);
		_viewRoot = new Sprite();
		root.addChild(_viewRoot);
	}

	public function getViewRoot() : Sprite {
		return _viewRoot;
	}

	override public function update() : Void {
		super.update();
		// Update Camera
		if(cameraTarget)  {
			var diffX : Float = (-cameraTarget.x + cameraOffset.x) - _viewRoot.x;
			var diffY : Float = (-cameraTarget.y + cameraOffset.y) - _viewRoot.y;
			var velocityX : Float = diffX * cameraEasing.x;
			var velocityY : Float = diffY * cameraEasing.y;
			_viewRoot.x += velocityX;
			_viewRoot.y += velocityY;
			// Constrain to camera bounds
			if(cameraBounds)  {
				if(-_viewRoot.x <= cameraBounds.left || cameraBounds.width < cameraLensWidth) _viewRoot.x = -cameraBounds.left
				else if(-_viewRoot.x + cameraLensWidth >= cameraBounds.right) _viewRoot.x = -cameraBounds.right + cameraLensWidth;
				if(-_viewRoot.y <= cameraBounds.top || cameraBounds.height < cameraLensHeight) _viewRoot.y = -cameraBounds.top
				else if(-_viewRoot.y + cameraLensHeight >= cameraBounds.bottom) _viewRoot.y = -cameraBounds.bottom + cameraLensHeight;
			}
		}
		for(var sprite : StarlingArt in _viewObjects) {
			if(sprite.group != sprite.citrusObject.group) updateGroupForSprite(sprite);
			sprite.update(this);
		}

	}

	override function createArt(citrusObject : Dynamic) : Dynamic {
		var viewObject : ISpriteView = try cast(citrusObject, ISpriteView) catch(e) null;
		//Changing to appropriate Box2DDebugArt
		if(citrusObject.view == com.citrusengine.view.spriteview.Box2DDebugArt) citrusObject.view = com.citrusengine.view.starlingview.Box2DDebugArt;
		if(citrusObject.view == flash.display.MovieClip) citrusObject.view = starling.display.Sprite;
		var art : StarlingArt = new StarlingArt(viewObject);
		// Perform an initial update
		art.update(this);
		updateGroupForSprite(art);
		return art;
	}

	/**
	 * @inherit 
	 */
	override function destroyArt(citrusObject : Dynamic) : Void {
		var spriteArt : StarlingArt = _viewObjects[citrusObject];
		spriteArt.destroy();
		spriteArt.parent.removeChild(spriteArt);
	}

	function updateGroupForSprite(sprite : StarlingArt) : Void {
		// Create the container sprite (group) if it has not been created yet.
		while(sprite.group >= _viewRoot.numChildren)_viewRoot.addChild(new Sprite());
		// Add the sprite to the appropriate group
		cast((_viewRoot.getChildAt(sprite.group)), Sprite).addChild(sprite);
	}

}

