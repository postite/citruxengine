/**
 * This is the primary class for creating graphical game objects.
 * You should override this class to create a visible game object such as a Spaceship, Hero, or Backgrounds. This is the equivalent
 * of the Flash Sprite. It has common properties that are required for properly displaying and
 * positioning objects. You can also add your logic to this sprite.
 * 
 * <p>With a CitrusSprite, there is only simple collision and velocity logic. If you'd like to take advantage of Box2D physics,
 * you should extend the PhysicsObject class instead.</p>
 */
package com.citrusengine.objects;

import com.citrusengine.core.CitrusObject;
import com.citrusengine.math.MathVector;
import com.citrusengine.view.ISpriteView;
import com.citrusengine.view.SpriteDebugArt;
import org.osflash.signals.Signal;
import flash.utils.Dictionary;

class CitrusSprite extends CitrusObject, implements ISpriteView {
	public var x(getX, setX) : Float;
	public var y(getY, setY) : Float;
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var parallax(getParallax, setParallax) : Float;
	public var rotation(getRotation, setRotation) : Float;
	public var group(getGroup, setGroup) : Float;
	public var visible(getVisible, setVisible) : Bool;
	public var view(getView, setView) : Dynamic;
	public var inverted(getInverted, setInverted) : Bool;
	public var animation(getAnimation, setAnimation) : String;
	public var offsetX(getOffsetX, setOffsetX) : Float;
	public var offsetY(getOffsetY, setOffsetY) : Float;
	public var registration(getRegistration, setRegistration) : String;

	public var velocity : MathVector;
	public var collisions : Dictionary;
	public var onCollide : Signal;
	public var onPersist : Signal;
	public var onSeparate : Signal;
	var _x : Float;
	var _y : Float;
	var _width : Float;
	var _height : Float;
	var _parallax : Float;
	var _rotation : Float;
	var _group : Float;
	var _visible : Bool;
	var _view : Dynamic;
	var _inverted : Bool;
	var _animation : String;
	var _offsetX : Float;
	var _offsetY : Float;
	var _registration : String;
	static public function Make(name : String, x : Float, y : Float, view : Dynamic, parallax : Float = 1) : CitrusSprite {
		return new CitrusSprite(name, {
			x : x
			y : y,
			view : view,
			parallax : parallax,

		});
	}

	public function new(name : String, params : Dynamic = null) {
		velocity = new MathVector();
		collisions = new Dictionary();
		onCollide = new Signal(CitrusSprite, CitrusSprite, MathVector, Number);
		onPersist = new Signal(CitrusSprite, CitrusSprite, MathVector);
		onSeparate = new Signal(CitrusSprite, CitrusSprite);
		_x = 0;
		_y = 0;
		_width = 30;
		_height = 30;
		_parallax = 1;
		_rotation = 0;
		_group = 0;
		_visible = true;
		_view = SpriteDebugArt;
		_inverted = false;
		_animation = "";
		_offsetX = 0;
		_offsetY = 0;
		_registration = "topLeft";
		super(name, params);
	}

	override public function destroy() : Void {
		onCollide.removeAll();
		onPersist.removeAll();
		onSeparate.removeAll();
		collisions = null;
		super.destroy();
	}

	public function getX() : Float {
		return _x;
	}

	@:meta(Property(value="0"))
	public function setX(value : Float) : Float {
		_x = value;
		return value;
	}

	public function getY() : Float {
		return _y;
	}

	@:meta(Property(value="0"))
	public function setY(value : Float) : Float {
		_y = value;
		return value;
	}

	public function getWidth() : Float {
		return _width;
	}

	@:meta(Property(value="30"))
	public function setWidth(value : Float) : Float {
		_width = value;
		return value;
	}

	public function getHeight() : Float {
		return _height;
	}

	@:meta(Property(value="30"))
	public function setHeight(value : Float) : Float {
		_height = value;
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
		return _rotation;
	}

	@:meta(Property(value="0"))
	public function setRotation(value : Float) : Float {
		_rotation = value;
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

	public function getInverted() : Bool {
		return _inverted;
	}

	public function setInverted(value : Bool) : Bool {
		_inverted = value;
		return value;
	}

	public function getAnimation() : String {
		return _animation;
	}

	public function setAnimation(value : String) : String {
		_animation = value;
		return value;
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

	@:meta(Property(value="topLeft"))
	public function setRegistration(value : String) : String {
		_registration = value;
		return value;
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		x += (velocity.x * timeDelta);
		y += (velocity.y * timeDelta);
	}

}

