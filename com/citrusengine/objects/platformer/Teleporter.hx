/**	 * A Teleporter, moves an object to a destination. The waiting time is more or less long.	 * It is a Sensor which can be activate after a contact.	 * Properties:	 * endX : the object's x destination after teleportation.	 * endY : the object's y destination after teleportation.	 * object : the PhysicsObject teleported.	 * waitingTime : how many time before teleportation, master ?	 * teleport : set it to true to teleport your object.	 */
package com.citrusengine.objects.platformer;

import box2das.dynamics.ContactEvent;
import com.citrusengine.objects.PhysicsObject;
import flash.utils.ClearTimeout;
import flash.utils.SetTimeout;

class Teleporter extends Sensor {

	/**		 * the object's x destination after teleportation.		 */
	@:meta(Property(value="0"))
	public var endX : Float;
	/**		 * the object's y destination after teleportation.		 */
	@:meta(Property(value="0"))
	public var endY : Float;
	/**		 * the PhysicsObject teleported.		 */
	@:meta(Property(value=""))
	public var object : PhysicsObject;
	/**		 * how many time before teleportation, master ?		 */
	@:meta(Property(value="0"))
	public var waitingTime : Float;
	/**		 * set it to true to teleport your object.		 */
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

