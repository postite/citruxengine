/**
 * This is a common, simple, yet solid implementation of a side-scrolling Hero. 
 * The hero can run, jump, get hurt, and kill enemies. It dispatches signals
 * when significant events happen. The game state's logic should listen for those signals
 * to perform game state updates (such as increment coin collections).
 * 
 * Don't store data on the hero object that you will need between two or more levels (such
 * as current coin count). The hero should be re-created each time a state is created or reset.
 */
package com.citrusengine.objects.platformer;

import box2das.common.V2;
import box2das.dynamics.ContactEvent;
import box2das.dynamics.B2Fixture;
import com.citrusengine.math.MathVector;
import com.citrusengine.objects.PhysicsObject;
import com.citrusengine.physics.CollisionCategories;
import com.citrusengine.utils.Box2DShapeMaker;
import org.osflash.signals.Signal;
import flash.display.MovieClip;
import flash.ui.Keyboard;
import flash.utils.ClearTimeout;
import flash.utils.GetDefinitionByName;
import flash.utils.SetTimeout;

class Hero extends PhysicsObject {
	public var controlsEnabled(getControlsEnabled, setControlsEnabled) : Bool;
	public var onGround(getOnGround, never) : Bool;
	public var enemyClass(never, setEnemyClass) : Dynamic;
	public var friction(getFriction, setFriction) : Float;

	//properties
	/**
	 * This is the rate at which the hero speeds up when you move him left and right. 
	 */
	@:meta(Property(value="1"))
	public var acceleration : Float;
	/**
	 * This is the fastest speed that the hero can move left or right. 
	 */
	@:meta(Property(value="8"))
	public var maxVelocity : Float;
	/**
	 * This is the initial velocity that the hero will move at when he jumps.
	 */
	@:meta(Property(value="14"))
	public var jumpHeight : Float;
	/**
	 * This is the amount of "float" that the hero has when the player holds the jump button while jumping. 
	 */
	@:meta(Property(value="0.9"))
	public var jumpAcceleration : Float;
	/**
	 * This is the y velocity that the hero must be travelling in order to kill a Baddy.
	 */
	@:meta(Property(value="3"))
	public var killVelocity : Float;
	/**
	 * The y velocity that the hero will spring when he kills an enemy. 
	 */
	@:meta(Property(value="10"))
	public var enemySpringHeight : Float;
	/**
	 * The y velocity that the hero will spring when he kills an enemy while pressing the jump button. 
	 */
	@:meta(Property(value="12"))
	public var enemySpringJumpHeight : Float;
	/**
	 * How long the hero is in hurt mode for. 
	 */
	@:meta(Property(value="1000"))
	public var hurtDuration : Float;
	/**
	 * The amount of kick-back that the hero jumps when he gets hurt. 
	 */
	@:meta(Property(value="6"))
	public var hurtVelocityX : Float;
	/**
	 * The amount of kick-back that the hero jumps when he gets hurt. 
	 */
	@:meta(Property(value="10"))
	public var hurtVelocityY : Float;
	/**
	 * Determines whether or not the hero's ducking ability is enabled.
	 */
	@:meta(Property(value="true"))
	public var canDuck : Bool;
	//events
	/**
	 * Dispatched whenever the hero jumps. 
	 */
	public var onJump : Signal;
	/**
	 * Dispatched whenever the hero gives damage to an enemy. 
	 */
	public var onGiveDamage : Signal;
	/**
	 * Dispatched whenever the hero takes damage from an enemy. 
	 */
	public var onTakeDamage : Signal;
	/**
	 * Dispatched whenever the hero's animation changes. 
	 */
	public var onAnimationChange : Signal;
	var _groundContacts : Array<Dynamic>;
	//Used to determine if he's on ground or not.
	var _enemyClass : Class<Dynamic>;
	var _onGround : Bool;
	var _springOffEnemy : Float;
	var _hurtTimeoutID : Float;
	var _hurt : Bool;
	var _friction : Float;
	var _playerMovingHero : Bool;
	var _controlsEnabled : Bool;
	var _ducking : Bool;
	var _combinedGroundAngle : Float;
	static public function Make(name : String, x : Float, y : Float, width : Float, height : Float, view : Dynamic = null) : Hero {
		if(view == null) view = MovieClip;
		return new Hero(name, {
			x : x
			y : y,
			width : width,
			height : height,
			view : view,

		});
	}

	/**
	 * Creates a new hero object.
	 */
	public function new(name : String, params : Dynamic = null) {
		acceleration = 1;
		maxVelocity = 8;
		jumpHeight = 14;
		jumpAcceleration = 0.9;
		killVelocity = 3;
		enemySpringHeight = 10;
		enemySpringJumpHeight = 12;
		hurtDuration = 1000;
		hurtVelocityX = 6;
		hurtVelocityY = 10;
		canDuck = true;
		_groundContacts = [];
		_enemyClass = Baddy;
		_onGround = false;
		_springOffEnemy = -1;
		_hurt = false;
		_friction = 0.75;
		_playerMovingHero = false;
		_controlsEnabled = true;
		_ducking = false;
		_combinedGroundAngle = 0;
		super(name, params);
		onJump = new Signal();
		onGiveDamage = new Signal();
		onTakeDamage = new Signal();
		onAnimationChange = new Signal();
	}

	override public function destroy() : Void {
		_fixture.removeEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
		_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
		clearTimeout(_hurtTimeoutID);
		onJump.removeAll();
		onGiveDamage.removeAll();
		onTakeDamage.removeAll();
		onAnimationChange.removeAll();
		super.destroy();
	}

	/**
	 * Whether or not the player can move and jump with the hero. 
	 */
	public function getControlsEnabled() : Bool {
		return _controlsEnabled;
	}

	public function setControlsEnabled(value : Bool) : Bool {
		_controlsEnabled = value;
		if(!_controlsEnabled) _fixture.SetFriction(_friction);
		return value;
	}

	/**
	 * Returns true if the hero is on the ground and can jump. 
	 */
	public function getOnGround() : Bool {
		return _onGround;
	}

	/**
	 * The Hero uses the enemyClass parameter to know who he can kill (and who can kill him).
	 * Use this setter to to pass in which base class the hero's enemy should be, in String form
	 * or Object notation.
	 * For example, if you want to set the "Baddy" class as your hero's enemy, pass
	 * "com.citrusengine.objects.platformer.Baddy", or Baddy (with no quotes). Only String
	 * form will work when creating objects via a level editor.
	 */
	@:meta(Property(value="com.citrusengine.objects.platformer.Baddy"))
	public function setEnemyClass(value : Dynamic) : Dynamic {
		if(Std.is(value, String)) _enemyClass = Type.getClass(getDefinitionByName(try cast(value, String) catch(e) null))
		else if(Std.is(value, Class)) _enemyClass = value;
		return value;
	}

	/**
	 * This is the amount of friction that the hero will have. Its value is multiplied against the
	 * friction value of other physics objects.
	 */
	public function getFriction() : Float {
		return _friction;
	}

	@:meta(Property(value="0.75"))
	public function setFriction(value : Float) : Float {
		_friction = value;
		if(_fixture)  {
			_fixture.SetFriction(_friction);
		}
		return value;
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		var velocity : V2 = _body.GetLinearVelocity();
		if(controlsEnabled)  {
			var moveKeyPressed : Bool = false;
			_ducking = (_ce.input.isDown(Keyboard.DOWN) && _onGround && canDuck);
			if(_ce.input.isDown(Keyboard.RIGHT) && !_ducking)  {
				velocity = V2.add(velocity, getSlopeBasedMoveAngle());
				moveKeyPressed = true;
			}
			if(_ce.input.isDown(Keyboard.LEFT) && !_ducking)  {
				velocity = V2.subtract(velocity, getSlopeBasedMoveAngle());
				moveKeyPressed = true;
			}
			if(moveKeyPressed && !_playerMovingHero)  {
				_playerMovingHero = true;
				_fixture.SetFriction(0);
				//Take away friction so he can accelerate.
			}

			else if(!moveKeyPressed && _playerMovingHero)  {
				_playerMovingHero = false;
				_fixture.SetFriction(_friction);
				//Add friction so that he stops running
			}
			if(_onGround && _ce.input.justPressed(Keyboard.SPACE) && !_ducking)  {
				velocity.y = -jumpHeight;
				onJump.dispatch();
			}
			if(_ce.input.isDown(Keyboard.SPACE) && !_onGround && velocity.y < 0)  {
				velocity.y -= jumpAcceleration;
			}
			if(_springOffEnemy != -1)  {
				if(_ce.input.isDown(Keyboard.SPACE)) velocity.y = -enemySpringJumpHeight
				else velocity.y = -enemySpringHeight;
				_springOffEnemy = -1;
			}
			if(velocity.x > (maxVelocity)) velocity.x = maxVelocity
			else if(velocity.x < (-maxVelocity)) velocity.x = -maxVelocity;
			_body.SetLinearVelocity(velocity);
		}
		updateAnimation();
	}

	/**
	 * Returns the absolute walking speed, taking moving platforms into account.
	 * Isn't super performance-light, so use sparingly.
	 */
	public function getWalkingSpeed() : Float {
		var groundVelocityX : Float = 0;
		for(var groundContact : B2Fixture in _groundContacts) {
			groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
		}

		return _body.GetLinearVelocity().x - groundVelocityX;
	}

	/**
	 * Hurts the hero, disables his controls for a little bit, and dispatches the onTakeDamage signal. 
	 */
	public function hurt() : Void {
		_hurt = true;
		controlsEnabled = false;
		_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
		onTakeDamage.dispatch();
		//Makes sure that the hero is not frictionless while his control is disabled
		if(_playerMovingHero)  {
			_playerMovingHero = false;
			_fixture.SetFriction(_friction);
		}
	}

	override function defineBody() : Void {
		super.defineBody();
		_bodyDef.fixedRotation = true;
		_bodyDef.allowSleep = false;
	}

	override function createShape() : Void {
		_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.1);
	}

	override function defineFixture() : Void {
		super.defineFixture();
		_fixtureDef.friction = _friction;
		_fixtureDef.restitution = 0;
		_fixtureDef.filter.categoryBits = CollisionCategories.Get("GoodGuys");
		_fixtureDef.filter.maskBits = CollisionCategories.GetAll();
	}

	override function createFixture() : Void {
		super.createFixture();
		_fixture.m_reportPreSolve = true;
		_fixture.m_reportBeginContact = true;
		_fixture.m_reportEndContact = true;
		_fixture.addEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
		_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
	}

	function handlePreSolve(e : ContactEvent) : Void {
		if(!_ducking) return;
		var other : PhysicsObject = try cast(e.other.GetBody().GetUserData(), PhysicsObject) catch(e) null;
		var heroTop : Float = y;
		var objectBottom : Float = other.y + (other.height / 2);
		if(objectBottom < heroTop) e.contact.Disable();
	}

	function handleBeginContact(e : ContactEvent) : Void {
		var collider : PhysicsObject = e.other.GetBody().GetUserData();
		if(_enemyClass && Std.is(collider, _enemyClass))  {
			if(_body.GetLinearVelocity().y < killVelocity && !_hurt)  {
				hurt();
				//fling the hero
				var hurtVelocity : V2 = _body.GetLinearVelocity();
				hurtVelocity.y = -hurtVelocityY;
				hurtVelocity.x = hurtVelocityX;
				if(collider.x > x) hurtVelocity.x = -hurtVelocityX;
				_body.SetLinearVelocity(hurtVelocity);
			}

			else  {
				_springOffEnemy = collider.y - height;
				onGiveDamage.dispatch();
			}

		}
		if(e.normal) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
;
		 {
			var collisionAngle : Float = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
			if(collisionAngle > 45 && collisionAngle < 135)  {
				_groundContacts.push(e.other);
				_onGround = true;
				updateCombinedGroundAngle();
			}
		}

	}

	function handleEndContact(e : ContactEvent) : Void {
		//Remove from ground contacts, if it is one.
		var index : Int = _groundContacts.indexOf(e.other);
		if(index != -1)  {
			_groundContacts.splice(index, 1);
			if(_groundContacts.length == 0) _onGround = false;
			updateCombinedGroundAngle();
		}
	}

	function getSlopeBasedMoveAngle() : V2 {
		return new V2(acceleration, 0).rotate(_combinedGroundAngle);
	}

	function updateCombinedGroundAngle() : Void {
		_combinedGroundAngle = 0;
		if(_groundContacts.length == 0) return;
		for(var contact : B2Fixture in _groundContacts)var angle : Float = contact.GetBody().GetAngle();
		var turn : Float = 45 * Math.PI / 180;
		angle = angle % turn;
		_combinedGroundAngle += angle;
		_combinedGroundAngle /= _groundContacts.length;
	}

	function endHurtState() : Void {
		_hurt = false;
		controlsEnabled = true;
	}

	function updateAnimation() : Void {
		var prevAnimation : String = _animation;
		var velocity : V2 = _body.GetLinearVelocity();
		if(_hurt)  {
			_animation = "hurt";
		}

		else if(!_onGround)  {
			_animation = "jump";
		}

		else if(_ducking)  {
			_animation = "duck";
		}

		else  {
			var walkingSpeed : Float = getWalkingSpeed();
			if(walkingSpeed < -acceleration)  {
				_inverted = true;
				_animation = "walk";
			}

			else if(walkingSpeed > acceleration)  {
				_inverted = false;
				_animation = "walk";
			}

			else  {
				_animation = "idle";
			}

		}

		if(prevAnimation != _animation)  {
			onAnimationChange.dispatch();
		}
	}

}

