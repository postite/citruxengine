/**
 * SpriteView is the first official implementation of a Citrus Engine "view". It creates and manages graphics using the traditional
 * Flash display list (addChild(), removeChild()) using DisplayObjects (MovieClips, Bitmaps, etc).
 * 
 * <p>You might think, "Is there any other way to display graphics in Flash?", and the answer is yes. Many Flash game programmers
 * prefer to use other rendering methods. The most common alternative is called "blitting", which is what Flixel uses. There are
 * also 3D games on the way that will use Adobe Stage3D to render graphics.</p>
 */
package com.citrusengine.view.spriteview;

import com.citrusengine.view.CitrusView;
import com.citrusengine.view.ISpriteView;
import flash.display.Sprite;

class SpriteView extends CitrusView {
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

	/**
	 * @inherit 
	 */
	override public function update() : Void {
		super.update();
		//Update Camera
		if(cameraTarget)  {
			var diffX : Float = (-cameraTarget.x + cameraOffset.x) - _viewRoot.x;
			var diffY : Float = (-cameraTarget.y + cameraOffset.y) - _viewRoot.y;
			var velocityX : Float = diffX * cameraEasing.x;
			var velocityY : Float = diffY * cameraEasing.y;
			_viewRoot.x += velocityX;
			_viewRoot.y += velocityY;
			//Constrain to camera bounds
			if(cameraBounds)  {
				if(-_viewRoot.x <= cameraBounds.left || cameraBounds.width < cameraLensWidth) _viewRoot.x = -cameraBounds.left
				else if(-_viewRoot.x + cameraLensWidth >= cameraBounds.right) _viewRoot.x = -cameraBounds.right + cameraLensWidth;
				if(-_viewRoot.y <= cameraBounds.top || cameraBounds.height < cameraLensHeight) _viewRoot.y = -cameraBounds.top
				else if(-_viewRoot.y + cameraLensHeight >= cameraBounds.bottom) _viewRoot.y = -cameraBounds.bottom + cameraLensHeight;
			}
		}
		for(var sprite : SpriteArt in _viewObjects) {
			if(sprite.group != sprite.citrusObject.group) updateGroupForSprite(sprite);
			sprite.update(this);
		}

	}

	/**
	 * @inherit 
	 */
	override function createArt(citrusObject : Dynamic) : Dynamic {
		var viewObject : ISpriteView = try cast(citrusObject, ISpriteView) catch(e) null;
		var art : SpriteArt = new SpriteArt(viewObject);
		//Perform an initial update
		art.update(this);
		updateGroupForSprite(art);
		return art;
	}

	/**
	 * @inherit 
	 */
	override function destroyArt(citrusObject : Dynamic) : Void {
		var spriteArt : SpriteArt = _viewObjects[citrusObject];
		spriteArt.parent.removeChild(spriteArt);
	}

	function updateGroupForSprite(sprite : SpriteArt) : Void {
		//Create the container sprite (group) if it has not been created yet.
		while(sprite.group >= _viewRoot.numChildren)_viewRoot.addChild(new Sprite());
		//Add the sprite to the appropriate group
		cast((_viewRoot.getChildAt(sprite.group)), Sprite).addChild(sprite);
	}

}

