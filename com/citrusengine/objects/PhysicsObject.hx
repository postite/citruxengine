/**
 * You should extend this class to take advantage of Box2D. This class provides template methods for defining
 * and creating Box2D bodies, fixtures, shapes, and joints. If you are not familiar with Box2D, you should first
 * learn about it via the <a href="http://www.box2d.org/manual.html">Box2D Manual</a>.
 */
package com.citrusengine.objects;

import box2das.collision.shapes.B2CircleShape;
import box2das.collision.shapes.B2PolygonShape;
import box2das.collision.shapes.B2Shape;
import box2das.common.V2;
import box2das.dynamics.B2Body;
import box2das.dynamics.B2BodyDef;
import box2das.dynamics.B2Fixture;
import box2das.dynamics.B2FixtureDef;
import com.citrusengine.core.CitrusEngine;
import com.citrusengine.core.CitrusObject;
import com.citrusengine.physics.Box2D;
import com.citrusengine.physics.CollisionCategories;
import com.citrusengine.view.ISpriteView;
import flash.display.MovieClip;

class PhysicsObject extends CitrusObject, implements ISpriteView {
	public var x(getX, setX) : Float;
	public var y(getY, setY) : Float;
	public var parallax(getParallax, setParallax) : Float;
	public var rotation(getRotation, setRotation) : Float;
	public var group(getGroup, setGroup) : Float;
	public var visible(getVisible, setVisible) : Bool;
	public var view(getView, setView) : Dynamic;
	public var animation(getAnimation, never) : String;
	public var inverted(getInverted, never) : Bool;
	public var offsetX(getOffsetX, setOffsetX) : Float;
	public var offsetY(getOffsetY, setOffsetY) : Float;
	public var registration(getRegistration, setRegistration) : String;
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var radius(getRadius, setRadius) : Float;
	public var body(getBody, never) : B2Body;

	/**
	 * The speed at which this object will be affected by gravity. 
	 */
	@:meta(Property(value="1.6"))
	public var gravity : Float;
	var _ce : CitrusEngine;
	var _box2D : Box2D;
	var _bodyDef : B2BodyDef;
	var _body : B2Body;
	var _shape : B2Shape;
	var _fixtureDef : B2FixtureDef;
	var _fixture : B2Fixture;
	var _inverted : Bool;
	var _parallax : Float;
	var _animation : String;
	var _visible : Bool;
	var _x : Float;
	var _y : Float;
	var _view : Dynamic;
	var _rotation : Float;
	var _width : Float;
	var _height : Float;
	var _radius : Float;
	var _group : Float;
	var _offsetX : Float;
	var _offsetY : Float;
	var _registration : String;
	static public function Make(name : String, x : Float, y : Float, width : Float, height : Float, view : Dynamic) : PhysicsObject {
		if(!view) view = MovieClip;
		return new PhysicsObject(name, {
			x : x
			y : y,
			width : width,
			height : height,
			view : view,

		});
	}

	/**
	 * Creates an instance of a PhysicsObject. Natively, this object does not default to any graphical representation,
	 * so you will need to set the "view" property in the params parameter.
	 * 
	 * <p>You'll notice that the PhysicsObject constructor calls a bunch of functions that start with "define" and "create".
	 * This is how the Box2D objects are created. You should override these methods in your own PhysicsObject implementation
	 * if you need additional Box2D functionality. Please see provided examples of classes that have overridden
	 * the PhysicsObject.</p>
	 */
	public function new(name : String, params : Dynamic = null) {
		gravity = 1.6;
		_inverted = false;
		_parallax = 1;
		_animation = "";
		_visible = true;
		_x = 0;
		_y = 0;
		_view = MovieClip;
		_rotation = 0;
		_width = 1;
		_height = 1;
		_group = 0;
		_offsetX = 0;
		_offsetY = 0;
		_registration = "center";
		_ce = CitrusEngine.getInstance();
		_box2D = try cast(_ce.state.getFirstObjectByType(Box2D), Box2D) catch(e) null;
		super(name, params);
		if(!_box2D)  {
			throw new Error("Cannot create PhysicsObject when a Box2D object has not been added to the state.");
			return;
		}
		defineBody();
		createBody();
		createShape();
		defineFixture();
		createFixture();
		defineJoint();
		createJoint();
	}

	override public function destroy() : Void {
		_body.destroy();
		_fixtureDef.destroy();
		_shape.destroy();
		_bodyDef.destroy();
		super.destroy();
	}

	/**
	 * You should override this method to extend the functionality of your physics object. This is where you will 
	 * want to do any velocity/force logic. By default, this method also updates the gravitatonal effect on the object.
	 * I have chosen to implement gravity in each individual object instead of globally via Box2D so that it is easy
	 * to create objects that defy gravity (like birds or bullets). This is difficult to do naturally in Box2D. Instead,
	 * you can simply set your PhysicsObject's gravity property to 0, and baddabing: no gravity. 
	 */
	override public function update(timeDelta : Float) : Void {
		if(_bodyDef.type == b2Body.b2_dynamicBody)  {
			var velocity : V2 = _body.GetLinearVelocity();
			velocity.y += gravity;
			_body.SetLinearVelocity(velocity);
		}
	}

	public function getX() : Float {
		if(_body) return _body.GetPosition().x * _box2D.scale
		else return _x * _box2D.scale;
	}

	@:meta(Property(value="0"))
	public function setX(value : Float) : Float {
		_x = value / _box2D.scale;
		if(_body)  {
			var pos : V2 = _body.GetPosition();
			pos.x = _x;
			_body.SetTransform(pos, _body.GetAngle());
		}
		return value;
	}

	public function getY() : Float {
		if(_body) return _body.GetPosition().y * _box2D.scale
		else return _y * _box2D.scale;
	}

	@:meta(Property(value="0"))
	public function setY(value : Float) : Float {
		_y = value / _box2D.scale;
		if(_body)  {
			var pos : V2 = _body.GetPosition();
			pos.y = _y;
			_body.SetTransform(pos, _body.GetAngle());
		}
		return value;
	}

	public function getParallax() : Float {
		return _parallax;
	}

	@:meta(Property(value="1"))
	public function setParallax(value : Float) : Float {
		_parallax = value;
		return value;
	}

	public function getRotation() : Float {
		if(_body) return _body.GetAngle() * 180 / Math.PI
		else return _rotation * 180 / Math.PI;
	}

	@:meta(Property(value="0"))
	public function setRotation(value : Float) : Float {
		_rotation = value * Math.PI / 180;
		if(_body) _body.SetTransform(_body.GetPosition(), _rotation);
		return value;
	}

	public function getGroup() : Float {
		return _group;
	}

	@:meta(Property(value="0"))
	public function setGroup(value : Float) : Float {
		_group = value;
		return value;
	}

	public function getVisible() : Bool {
		return _visible;
	}

	public function setVisible(value : Bool) : Bool {
		_visible = value;
		return value;
	}

	public function getView() : Dynamic {
		return _view;
	}

	@:meta(Property(value="",browse="true"))
	public function setView(value : Dynamic) : Dynamic {
		_view = value;
		return value;
	}

	public function getAnimation() : String {
		return _animation;
	}

	public function getInverted() : Bool {
		return _inverted;
	}

	public function getOffsetX() : Float {
		return _offsetX;
	}

	@:meta(Property(value="0"))
	public function setOffsetX(value : Float) : Float {
		_offsetX = value;
		return value;
	}

	public function getOffsetY() : Float {
		return _offsetY;
	}

	@:meta(Property(value="0"))
	public function setOffsetY(value : Float) : Float {
		_offsetY = value;
		return value;
	}

	public function getRegistration() : String {
		return _registration;
	}

	@:meta(Property(value="center"))
	public function setRegistration(value : String) : String {
		_registration = value;
		return value;
	}

	/**
	 * This can only be set in the constructor parameters. 
	 */
	public function getWidth() : Float {
		return _width * _box2D.scale;
	}

	@:meta(Property(value="30"))
	public function setWidth(value : Float) : Float {
		_width = value / _box2D.scale;
		if(_initialized)  {
			trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
		}
		return value;
	}

	/**
	 * This can only be set in the constructor parameters. 
	 */
	public function getHeight() : Float {
		return _height * _box2D.scale;
	}

	@:meta(Property(value="30"))
	public function setHeight(value : Float) : Float {
		_height = value / _box2D.scale;
		if(_initialized)  {
			trace("Warning: You cannot set " + this + " height after it has been created. Please set it in the constructor.");
		}
		return value;
	}

	/**
	 * This can only be set in the constructor parameters. 
	 */
	public function getRadius() : Float {
		return _radius * _box2D.scale;
	}

	/**
	 * The object has a radius or a width & height. It can't have both.
	 */
	@:meta(Property(value=""))
	public function setRadius(value : Float) : Float {
		_radius = value / _box2D.scale;
		if(_initialized)  {
			trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
		}
		return value;
	}

	/**
	 * A direction reference to the Box2D body associated with this object.
	 */
	public function getBody() : B2Body {
		return _body;
	}

	/**
	 * This method will often need to be overriden to provide additional definition to the Box2D body object. 
	 */
	function defineBody() : Void {
		_bodyDef = new B2BodyDef();
		_bodyDef.type = b2Body.b2_dynamicBody;
		_bodyDef.position.v2 = new V2(_x, _y);
		_bodyDef.angle = _rotation;
	}

	/**
	 * This method will often need to be overriden to customize the Box2D body object. 
	 */
	function createBody() : Void {
		_body = _box2D.world.CreateBody(_bodyDef);
		_body.SetUserData(this);
	}

	/**
	 * This method will often need to be overriden to customize the Box2D shape object.
	 * The PhysicsObject creates a rectangle by default if the radius it not defined, but you can replace this method's
	 * definition and instead create a custom shape, such as a line or circle.
	 */
	function createShape() : Void {
		if(_radius)  {
			_shape = new B2CircleShape();
			b2CircleShape(_shape).m_radius = _radius;
		}

		else  {
			_shape = new B2PolygonShape();
			b2PolygonShape(_shape).SetAsBox(_width / 2, _height / 2);
		}

	}

	/**
	 * This method will often need to be overriden to provide additional definition to the Box2D fixture object. 
	 */
	function defineFixture() : Void {
		_fixtureDef = new B2FixtureDef();
		_fixtureDef.shape = _shape;
		_fixtureDef.density = 1;
		_fixtureDef.friction = 0.6;
		_fixtureDef.restitution = 0.3;
		_fixtureDef.filter.categoryBits = CollisionCategories.Get("Level");
		_fixtureDef.filter.maskBits = CollisionCategories.GetAll();
	}

	/**
	 * This method will often need to be overriden to customize the Box2D fixture object. 
	 */
	function createFixture() : Void {
		_fixture = _body.CreateFixture(_fixtureDef);
	}

	/**
	 * This method will often need to be overriden to provide additional definition to the Box2D joint object.
	 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
	 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
	 * and b2Joint object.
	 */
	function defineJoint() : Void {
	}

	/**
	 * This method will often need to be overriden to customize the Box2D joint object. 
	 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
	 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
	 * and b2Joint object.
	 */
	function createJoint() : Void {
	}

}

