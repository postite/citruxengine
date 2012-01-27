/**
package com.citrusengine.objects.platformer;

import box2das.dynamics.ContactEvent;
import com.citrusengine.objects.PhysicsObject;
import flash.utils.ClearTimeout;
import flash.utils.SetTimeout;

class Teleporter extends Sensor {

	/**
	@:meta(Property(value="0"))
	public var endX : Float;
	/**
	@:meta(Property(value="0"))
	public var endY : Float;
	/**
	@:meta(Property(value=""))
	public var object : PhysicsObject;
	/**
	@:meta(Property(value="0"))
	public var waitingTime : Float;
	/**
	public var teleport : Bool;
	var _teleporting : Bool;
	var _teleportTimeoutID : UInt;
	public function new(name : String, params : Dynamic = null) {
		endX = 0;
		endY = 0;
		waitingTime = 0;
		teleport = false;
		_teleporting = false;
		super(name, params);
	}

	override public function destroy() : Void {
		clearTimeout(_teleportTimeoutID);
		super.destroy();
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		if(teleport)  {
			_teleporting = true;
			_teleportTimeoutID = setTimeout(_teleport, waitingTime);
			teleport = false;
		}
		_updateAnimation();
	}

	override function handleBeginContact(e : ContactEvent) : Void {
		onBeginContact.dispatch(e);
		teleport = true;
	}

	function _teleport() : Void {
		_teleporting = false;
		object.x = endX;
		object.y = endY;
		clearTimeout(_teleportTimeoutID);
	}

	function _updateAnimation() : Void {
		if(_teleporting)  {
			_animation = "teleport";
		}

		else  {
			_animation = "normal";
		}

	}

}
