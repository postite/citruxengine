/**
 * This displays Box2D's debug graphics. It does so properly through Citrus Engine's view manager. Box2D by default
 * sets visible to false, so you'll need to set the Box2D object's visible property to true in order to see the debug graphics. 
 */
package com.citrusengine.view.starlingview;

import box2das.dynamics.B2DebugDraw;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import com.citrusengine.physics.Box2D;

class Box2DDebugArt extends Sprite {

	var _box2D : Box2D;
	var _debugDrawer : B2DebugDraw;
	public function new() {
		addEventListener(Event.ADDED, handleAddedToParent);
		addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		addEventListener(Event.REMOVED, destroy);
	}

	function handleAddedToParent(evt : Event) : Void {
		removeEventListener(Event.ADDED, handleAddedToParent);
		_box2D = try cast(cast((parent), StarlingArt).citrusObject, Box2D) catch(e) null;
		_debugDrawer = new B2DebugDraw();
		Starling.current.nativeStage.addChild(_debugDrawer);
		_debugDrawer.world = _box2D.world;
		_debugDrawer.scale = _box2D.scale;
	}

	function destroy(evt : Event) : Void {
		removeEventListener(Event.ADDED, handleAddedToParent);
		removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		removeEventListener(Event.REMOVED, destroy);
	}

	function handleEnterFrame(evt : Event) : Void {
		_debugDrawer.Draw();
	}

}

