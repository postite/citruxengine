/**
 * The Reward class is meant to pop out of a RewardBox when the player bumps it. A Reward object is the equivelant of a "mushroom"
 * "fire flower", or "invincible star" in the Mario games.
 * 
 * For each reward that you want in your game, you should make a class that extends this Reward class. If you want an ExtraLifeReward,
 * you should make a class called ExtraLifeReward that extends Reward. Then hardcode your view, speed, impulseX, and impulseY properties.
 * Of course, you can also add additional functionality as well by doing this.
 * 
 * When you create a RewardBox, you will pass the name of this class into the rewardClass property of RewardBox. That will make the RewardBox
 * generate a Reward.
 * 
 * You can specify the <code>speed</code> property to set the speed that the reward moves at.
 * 
 * You can specify the <code>impulseX</code> and <code>impulseY</code> properties to make the reward "jump" out of the box.
 * 
 * You can specify the <code>collectorClass</code> property to tell the object who can collect it. It is set to <code>Hero</code> class by default.
 * 
 * Events:
 * The <code>onCollect</code> Signal is dispatched when the reward is collected. Since the RewardBox generates the reward, you probably won't
 * get a reference to the reward. Thus, you can instead listen for RewardBox.onRewardCollect to find out when the reward is collected. Nevertheless,
 * if you listen for Reward.OnCollect, it passes a reference to itself when it dispatches.
 * 
 * Animation:
 * The reward object only has a default animation.
 * 
 */
package com.citrusengine.objects.platformer;

import box2das.common.V2;
import box2das.dynamics.ContactEvent;
import box2das.dynamics.B2Fixture;
import box2das.dynamics.B2FixtureDef;
import com.citrusengine.math.MathVector;
import com.citrusengine.objects.PhysicsObject;
import com.citrusengine.physics.CollisionCategories;
import org.osflash.signals.Signal;
import flash.utils.GetDefinitionByName;

class Reward extends PhysicsObject {
	public var collectorClass(getCollectorClass, setCollectorClass) : Dynamic;

	/**
	 * The speed at which the reward moves. It will turn around when it hits a wall.
	 */
	public var speed : Float;
	/**
	 * The speed on the x axis that the reward will fly out of the box.
	 */
	public var impulseX : Float;
	/**
	 * The speed on the y axis that the reward will fly out of the box.
	 */
	public var impulseY : Float;
	/**
	 * Dispatches when the reward gets collected. Also see RewardBox.onRewardCollect for a possibly more convenient event.
	 */
	public var onCollect : Signal;
	var _collectFixtureDef : B2FixtureDef;
	var _collectFixture : B2Fixture;
	var _movingLeft : Bool;
	var _collectorClass : Class<Dynamic>;
	var _isNew : Bool;
	public function new(name : String, params : Dynamic = null) {
		speed = 1;
		impulseX = 0;
		impulseY = -10;
		_movingLeft = false;
		_collectorClass = Hero;
		_isNew = true;
		super(name, params);
		onCollect = new Signal(Reward);
	}

	override public function destroy() : Void {
		_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handlePlatformContact);
		_collectFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleCollectContact);
		onCollect.removeAll();
		_collectFixtureDef.destroy();
		super.destroy();
	}

	/**
	 * Specify the class of the object that you want the reward to be collected by.
	 * You can specify the collectorClass in String form (collectorClass = "com.myGame.MyHero") or via direct reference 
	 * (collectorClass = MyHero). You should use the String form when creating Rewards in an external level editor. Make sure and
	 * specify the entire classpath.
	 */
	public function getCollectorClass() : Dynamic {
		return _collectorClass;
	}

	public function setCollectorClass(value : Dynamic) : Dynamic {
		if(Std.is(value, String)) _collectorClass = Type.getClass(getDefinitionByName(value))
		else if(Std.is(value, Class)) _collectorClass = value;
		return value;
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		var velocity : V2 = _body.GetLinearVelocity();
		if(_isNew)  {
			_isNew = false;
			velocity.x += impulseX;
			velocity.y += impulseY;
		}

		else  {
			if(_movingLeft) velocity.x = -speed
			else velocity.x = speed;
		}

		_body.SetLinearVelocity(velocity);
	}

	override function defineBody() : Void {
		super.defineBody();
		_bodyDef.fixedRotation = true;
	}

	override function defineFixture() : Void {
		super.defineFixture();
		_fixtureDef.friction = 0;
		_fixtureDef.restitution = 0;
		_fixtureDef.filter.categoryBits = CollisionCategories.Get("Items");
		_fixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("GoodGuys", "BadGuys");
		_collectFixtureDef = new B2FixtureDef();
		_collectFixtureDef.shape = _shape;
		_collectFixtureDef.isSensor = true;
		_collectFixtureDef.filter.categoryBits = CollisionCategories.Get("Items");
		_collectFixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("BadGuys");
	}

	override function createFixture() : Void {
		super.createFixture();
		_fixture.m_reportBeginContact = true;
		_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handlePlatformContact);
		_collectFixture = _body.CreateFixture(_collectFixtureDef);
		_collectFixture.m_reportBeginContact = true;
		_collectFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleCollectContact);
	}

	function handleCollectContact(e : ContactEvent) : Void {
		var collider : PhysicsObject = try cast(e.other.GetBody().GetUserData(), PhysicsObject) catch(e) null;
		if(Std.is(collider, _collectorClass))  {
			kill = true;
			onCollect.dispatch(this);
		}
	}

	function handlePlatformContact(e : ContactEvent) : Void {
		if(e.normal)  {
			var collisionAngle : Float = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
			if(collisionAngle < 45 || collisionAngle > 135) _movingLeft = !_movingLeft;
		}
	}

}

