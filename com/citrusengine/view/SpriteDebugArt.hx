package com.citrusengine.view;

import com.citrusengine.core.CitrusObject;
import com.citrusengine.objects.CitrusSprite;
import flash.display.MovieClip;
import flash.events.Event;

class SpriteDebugArt extends MovieClip {

	public function new() {
		addEventListener(Event.ADDED, handleAddedToParent);
	}

	function handleAddedToParent(e : Event) : Void {
	}

	public function initialize(object : CitrusObject) : Void {
		var citrusSprite : CitrusSprite = try cast(object, CitrusSprite) catch(e) null;
		if(citrusSprite)  {
			graphics.lineStyle(1, 0x222222);
			graphics.beginFill(0x888888);
			graphics.drawRect(0, 0, citrusSprite.width, citrusSprite.height);
			graphics.endFill();
		}
	}

}

