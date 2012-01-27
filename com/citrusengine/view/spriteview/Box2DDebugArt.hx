/**
 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
 * sets visible to false, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
 */
package com.citrusengine.view.spriteview;

import box2das.dynamics.B2DebugDraw;
import com.citrusengine.physics.Box2D;
import com.citrusengine.view.spriteview.SpriteArt;
import com.citrusengine.core.CitrusObject;
import com.citrusengine.view.ISpriteView;
import flash.display.MovieClip;
import flash.events.Event;

class Box2DDebugArt extends MovieClip {

	var _box2D : Box2D;
	var _debugDrawer : B2DebugDraw;
	public function new() {
		addEventListener(Event.ADDED, handleAddedToParent);
		addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		addEventListener(Event.REMOVED, destroy);
	}

	function handleAddedToParent(e : Event) : Void {
		removeEventListener(Event.ADDED, handleAddedToParent);
		_box2D = try cast(cast((parent), SpriteArt).citrusObject, Box2D) catch(e) null;
		_debugDrawer = new B2DebugDraw();
		addChild(_debugDrawer);
		_debugDrawer.world = _box2D.world;
		_debugDrawer.scale = _box2D.scale;
	}

	function destroy(e : Event) : Void {
		removeEventListener(Event.ADDED, handleAddedToParent);
		removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		removeEventListener(Event.REMOVED, destroy);
	}

	function handleEnterFrame(e : Event) : Void {
		_debugDrawer.Draw();
	}

}

