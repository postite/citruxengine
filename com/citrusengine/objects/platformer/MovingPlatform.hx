/**
 * A platform that moves between two points. The MovingPlatform has several properties that
 * can customize it.
 * 
 * Properties:
 * speed - The speed at which the moving platform travels. 
 * enabled - Whether or not the MovingPlatform can move, no matter the condition.
 * startX -  The initial starting X position of the MovingPlatform, and the place it returns to when it reaches the end destination.
 * startY -  The initial starting Y position of the MovingPlatform, and the place it returns to when it reaches the end destination.
 * endX -  The ending X position of the MovingPlatform, and the place it returns to when it reaches the start destination.
 * endY -  The ending Y position of the MovingPlatform, and the place it returns to when it reaches the start destination.
 * waitForPassenger - If set to true, MovingPlatform will not move unless there is a passenger. If set to false, it continually moves.
 */
package com.citrusengine.objects.platformer;

import box2das.common.V2;
import box2das.dynamics.ContactEvent;
import box2das.dynamics.B2Body;
import com.citrusengine.math.MathVector;
import flash.display.MovieClip;

class MovingPlatform extends Platform {
	public var startX(getStartX, setStartX) : Float;
	public var startY(getStartY, setStartY) : Float;
	public var endX(getEndX, setEndX) : Float;
	public var endY(getEndY, setEndY) : Float;

	/**
	 * The speed at which the moving platform travels. 
	 */
	@:meta(Property(value="1"))
	public var speed : Float;
	/**
	 * Whether or not the MovingPlatform can move, no matter the condition. 
	 */
	public var enabled : Bool;
	/**
	 * If set to true, the MovingPlatform will not move unless there is a passenger. 
	 */
	@:meta(Property(value="false"))
	public var waitForPassenger : Bool;
	var _start : MathVector;
	var _end : MathVector;
	var _forward : Bool;
	var _passengers : Array<B2Body>;
	static public function Make(name : String, x : Float, y : Float, width : Float, height : Float, endX : Float, endY : Float, view : Dynamic = null, speed : Float = 1, waitForPassenger : Bool = false) : MovingPlatform {
		if(view == null) view = MovieClip;
		return new MovingPlatform(name, {
			x : x
			y : y,
			width : width,
			height : height,
			endX : endX,
			endY : endY,
			view : view,
			speed : speed,
			waitForPassenger : waitForPassenger,

		});
	}

	public function new(name : String, params : Dynamic = null) {
		speed = 1;
		enabled = true;
		waitForPassenger = false;
		_start = new MathVector();
		_end = new MathVector();
		_forward = true;
		_passengers = new Array<B2Body>();
		super(name, params);
	}

	override public function destroy() : Void {
		_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
		_passengers.length = 0;
		super.destroy();
	}

	@:meta(Property(value="0"))
	override public function setX(value : Float) : Float {
		super.x = value;
		_start.x = value / _box2D.scale;
		return value;
	}

	@:meta(Property(value="0"))
	override public function setY(value : Float) : Float {
		super.y = value;
		_start.y = value / _box2D.scale;
		return value;
	}

	/**
	 * The initial starting X position of the MovingPlatform, and the place it returns to when it reaches
	 * the end destination.
	 */
	public function getStartX() : Float {
		return _start.x * _box2D.scale;
	}

	public function setStartX(value : Float) : Float {
		_start.x = value / _box2D.scale;
		return value;
	}

	/**
	 * The initial starting Y position of the MovingPlatform, and the place it returns to when it reaches
	 * the end destination.
	 */
	public function getStartY() : Float {
		return _start.y * _box2D.scale;
	}

	public function setStartY(value : Float) : Float {
		_start.y = value / _box2D.scale;
		return value;
	}

	/**
	 * The ending X position of the MovingPlatform.
	 */
	public function getEndX() : Float {
		return _end.x * _box2D.scale;
	}

	@:meta(Property(value="0"))
	public function setEndX(value : Float) : Float {
		_end.x = value / _box2D.scale;
		return value;
	}

	/**
	 * The ending Y position of the MovingPlatform.
	 */
	public function getEndY() : Float {
		return _end.y * _box2D.scale;
	}

	@:meta(Property(value="0"))
	public function setEndY(value : Float) : Float {
		_end.y = value / _box2D.scale;
		return value;
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		var velocity : V2 = _body.GetLinearVelocity();
		if((waitForPassenger && _passengers.length == 0) || !enabled)  {
			//Platform should not move
			velocity.zero();
		}

		else  {
			//Move the platform according to its destination
			var destination : V2 = new V2(_end.x, _end.y);
			if(!_forward) destination = new V2(_start.x, _start.y);
			velocity = destination.subtract(_body.GetPosition());
			if(velocity.length() > speed / 30)  {
				//Still has further to go. Normalize the velocity to the max speed
				velocity = velocity.normalize(speed);
			}

			else  {
				//Destination is very close. Switch the travelling direction
				_forward = !_forward;
			}

		}

		_body.SetLinearVelocity(velocity);
	}

	override function defineBody() : Void {
		super.defineBody();
		_bodyDef.type = b2Body.b2_kinematicBody;
		//Kinematic bodies don't respond to outside forces, only velocity.
		_bodyDef.allowSleep = false;
	}

	override function createFixture() : Void {
		super.createFixture();
		_fixture.m_reportBeginContact = true;
		_fixture.m_reportEndContact = true;
		_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
	}

	function handleBeginContact(e : ContactEvent) : Void {
		_passengers.push(e.other.GetBody());
	}

	function handleEndContact(e : ContactEvent) : Void {
		_passengers.splice(_passengers.indexOf(e.other.GetBody()), 1);
	}

}

