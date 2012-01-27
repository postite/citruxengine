/**
 * This is a common example of a side-scrolling bad guy. He has limited logic, basically
 * only turning around when he hits a wall.
 * 
 * When controlling collision interactions between two objects, such as a Horo and Baddy,
 * I like to let each object perform its own actions, not control one object's action from the other object.
 * For example, the Hero doesn't contain the logic for killing the Baddy, and the Baddy doesn't contain the
 * logic for making the hero "Spring" when he kills him. 
 */
package com.citrusengine.objects.platformer;

import box2das.collision.shapes.B2PolygonShape;
import box2das.common.V2;
import box2das.dynamics.ContactEvent;
import box2das.dynamics.B2Fixture;
import box2das.dynamics.B2FixtureDef;
import com.citrusengine.objects.PhysicsObject;
import com.citrusengine.physics.CollisionCategories;
import com.citrusengine.utils.Box2DShapeMaker;
import flash.display.MovieClip;
import flash.utils.ClearTimeout;
import flash.utils.GetDefinitionByName;
import flash.utils.SetTimeout;

class Baddy extends PhysicsObject {
	public var enemyClass(getEnemyClass, setEnemyClass) : Dynamic;

	@:meta(Property(value="1.3"))
	public var speed : Float;
	@:meta(Property(value="3"))
	public var enemyKillVelocity : Float;
	@:meta(Property(value="left"))
	public var startingDirection : String;
	@:meta(Property(value="400"))
	public var hurtDuration : Float;
	@:meta(Property(value="-100000"))
	public var leftBound : Float;
	@:meta(Property(value="100000"))
	public var rightBound : Float;
	@:meta(Citrus(value="10"))
	public var wallSensorOffset : Float;
	@:meta(Citrus(value="2"))
	public var wallSensorWidth : Float;
	@:meta(Citrus(value="2"))
	public var wallSensorHeight : Float;
	var _hurtTimeoutID : Float;
	var _hurt : Bool;
	var _enemyClass : Dynamic;
	var _lastXPos : Float;
	var _lastTimeTurnedAround : Float;
	var _waitTimeBeforeTurningAround : Float;
	var _leftSensorShape : B2PolygonShape;
	var _rightSensorShape : B2PolygonShape;
	var _leftSensorFixture : B2Fixture;
	var _rightSensorFixture : B2Fixture;
	var _sensorFixtureDef : B2FixtureDef;
	static public function Make(name : String, x : Float, y : Float, width : Float, height : Float, speed : Float, view : Dynamic = null, leftBound : Float = -100000, rightBound : Float = 100000, startingDirection : String = "left") : Baddy {
		if(view == null) view = MovieClip;
		return new Baddy(name, {
			x : x
			y : y,
			width : width,
			height : height,
			speed : speed,
			view : view,
			leftBound : leftBound,
			rightBound : rightBound,
			startingDirection : startingDirection,

		});
	}

	public function new(name : String, params : Dynamic = null) {
		speed = 1.3;
		enemyKillVelocity = 3;
		startingDirection = "left";
		hurtDuration = 400;
		leftBound = -100000;
		rightBound = 100000;
		wallSensorOffset = 10;
		wallSensorWidth = 2;
		wallSensorHeight = 2;
		_hurtTimeoutID = 0;
		_hurt = false;
		_enemyClass = Hero;
		_lastTimeTurnedAround = 0;
		_waitTimeBeforeTurningAround = 1000;
		super(name, params);
		if(startingDirection == "left")  {
			_inverted = true;
		}
	}

	override public function destroy() : Void {
		_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_leftSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
		_rightSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
		clearTimeout(_hurtTimeoutID);
		_sensorFixtureDef.destroy();
		_leftSensorShape.destroy();
		_rightSensorShape.destroy();
		super.destroy();
	}

	public function getEnemyClass() : Dynamic {
		return _enemyClass;
	}

	@:meta(Property(value="com.citrusengine.objects.platformer.Hero"))
	public function setEnemyClass(value : Dynamic) : Dynamic {
		if(Std.is(value, String)) _enemyClass = Type.getClass(getDefinitionByName(value))
		else if(Std.is(value, Class)) _enemyClass = value;
		return value;
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		var position : V2 = _body.GetPosition();
		_lastXPos = position.x;
		//Turn around when they pass their left/right bounds
		if((_inverted && position.x * 30 < leftBound) || (!_inverted && position.x * 30 > rightBound)) turnAround();
		var velocity : V2 = _body.GetLinearVelocity();
		if(!_hurt)  {
			if(_inverted) velocity.x = -speed
			else velocity.x = speed;
		}
		_body.SetLinearVelocity(velocity);
		updateAnimation();
	}

	public function hurt() : Void {
		_hurt = true;
		_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
	}

	public function turnAround() : Void {
		_inverted = !_inverted;
		_lastTimeTurnedAround = new Date().time;
	}

	override function createBody() : Void {
		super.createBody();
		_body.SetFixedRotation(true);
	}

	override function createShape() : Void {
		_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.2);
		var sensorWidth : Float = wallSensorWidth / _box2D.scale;
		var sensorHeight : Float = wallSensorHeight / _box2D.scale;
		var sensorOffset : V2 = new V2(-_width / 2 - (sensorWidth / 2), _height / 2 - (wallSensorOffset / _box2D.scale));
		_leftSensorShape = new B2PolygonShape();
		_leftSensorShape.SetAsBox(sensorWidth, sensorHeight, sensorOffset);
		sensorOffset.x = -sensorOffset.x;
		_rightSensorShape = new B2PolygonShape();
		_rightSensorShape.SetAsBox(sensorWidth, sensorHeight, sensorOffset);
	}

	override function defineFixture() : Void {
		super.defineFixture();
		_fixtureDef.friction = 0;
		_fixtureDef.filter.categoryBits = CollisionCategories.Get("BadGuys");
		_fixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("Items");
		_sensorFixtureDef = new B2FixtureDef();
		_sensorFixtureDef.shape = _leftSensorShape;
		_sensorFixtureDef.isSensor = true;
		_sensorFixtureDef.filter.categoryBits = CollisionCategories.Get("BadGuys");
		_sensorFixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("Items");
	}

	override function createFixture() : Void {
		super.createFixture();
		_fixture.m_reportBeginContact = true;
		_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_leftSensorFixture = body.CreateFixture(_sensorFixtureDef);
		_leftSensorFixture.m_reportBeginContact = true;
		_leftSensorFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
		_sensorFixtureDef.shape = _rightSensorShape;
		_rightSensorFixture = body.CreateFixture(_sensorFixtureDef);
		_rightSensorFixture.m_reportBeginContact = true;
		_rightSensorFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
	}

	function handleBeginContact(e : ContactEvent) : Void {
		var collider : PhysicsObject = e.other.GetBody().GetUserData();
		if(Std.is(collider, _enemyClass && collider.body.GetLinearVelocity().y > enemyKillVelocity)) hurt();
	}

	function handleSensorBeginContact(e : ContactEvent) : Void {
		if(_body.GetLinearVelocity().x < 0 && e.fixture == _rightSensorFixture) return;
		if(_body.GetLinearVelocity().x > 0 && e.fixture == _leftSensorFixture) return;
		var collider : PhysicsObject = e.other.GetBody().GetUserData();
		if(Std.is(collider, Platform || Std.is(collider, Baddy)))  {
			turnAround();
		}
	}

	function updateAnimation() : Void {
		if(_hurt) _animation = "die"
		else _animation = "walk";
	}

	function endHurtState() : Void {
		_hurt = false;
		kill = true;
	}

}

