/**
 * Sensors simply listen for when an object begins and ends contact with them. They disaptch a signal
 * when contact is made or ended, and this signal can be used to perform custom game logic such as
 * triggering a scripted event, ending a level, popping up a dialog box, and virtually anything else.
 * 
 * Remember that signals dispatch events when ANY Box2D object collides with them, so you will want
 * your collision handler to ignore collisions with objects that it is not interested in, or extend
 * the sensor and use maskBits to ignore collisions altogether.  
 * 
 * Events
 * onBeginContact - Dispatches on first contact with the sensor.
 * onEndContact - Dispatches when the object leaves the sensor.
 */
package com.citrusengine.objects.platformer;

import box2das.dynamics.ContactEvent;
import box2das.dynamics.B2Body;
import com.citrusengine.objects.PhysicsObject;
import org.osflash.signals.Signal;
import flash.display.MovieClip;

class Sensor extends PhysicsObject {

	/**
	 * Dispatches on first contact with the sensor.
	 */
	public var onBeginContact : Signal;
	/**
	 * Dispatches when the object leaves the sensor.
	 */
	public var onEndContact : Signal;
	static public function Make(name : String, x : Float, y : Float, width : Float, height : Float, view : Dynamic = null) : Sensor {
		if(view == null) view = MovieClip;
		return new Sensor(name, {
			x : x
			y : y,
			width : width,
			height : height,
			view : view,

		});
	}

	public function new(name : String, params : Dynamic = null) {
		super(name, params);
		onBeginContact = new Signal(ContactEvent);
		onEndContact = new Signal(ContactEvent);
	}

	override public function destroy() : Void {
		onBeginContact.removeAll();
		onEndContact.removeAll();
		_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
		super.destroy();
	}

	@:meta(Property(value="30"))
	override public function setWidth(value : Float) : Float {
		super.width = value;
		return value;
	}

	override function defineBody() : Void {
		super.defineBody();
		_bodyDef.type = b2Body.b2_staticBody;
	}

	override function defineFixture() : Void {
		super.defineFixture();
		_fixtureDef.isSensor = true;
	}

	override function createFixture() : Void {
		super.createFixture();
		_fixture.m_reportBeginContact = true;
		_fixture.m_reportEndContact = true;
		_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
	}

	function handleBeginContact(e : ContactEvent) : Void {
		onBeginContact.dispatch(e);
	}

	function handleEndContact(e : ContactEvent) : Void {
		onEndContact.dispatch(e);
	}

}

