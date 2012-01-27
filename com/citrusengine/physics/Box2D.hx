/**
 * This is a simple wrapper class that allows you to add a Box2D Alchemy world to your game's state.
 * Add an instance of this class to your State before you create any phyiscs bodies. It will need to 
 * exist first, or your physics bodies will throw an error when they try to create themselves.
 */
package com.citrusengine.physics;

import box2das.common.V2;
import box2das.common.B2Base;
import box2das.dynamics.B2World;
import com.citrusengine.core.CitrusObject;
import com.citrusengine.view.ISpriteView;
import com.citrusengine.view.spriteview.Box2DDebugArt;

class Box2D extends CitrusObject, implements ISpriteView {
	public var world(getWorld, never) : B2World;
	public var scale(getScale, never) : Float;
	public var x(getX, never) : Float;
	public var y(getY, never) : Float;
	public var parallax(getParallax, never) : Float;
	public var rotation(getRotation, never) : Float;
	public var group(getGroup, setGroup) : Float;
	public var visible(getVisible, setVisible) : Bool;
	public var animation(getAnimation, never) : String;
	public var view(getView, setView) : Dynamic;
	public var inverted(getInverted, never) : Bool;
	public var offsetX(getOffsetX, never) : Float;
	public var offsetY(getOffsetY, never) : Float;
	public var registration(getRegistration, never) : String;

	var _visible : Bool;
	var _scale : Float;
	var _world : B2World;
	var _group : Float;
	var _view : Dynamic;
	static public function Make(name : String, visible : Bool) : Box2D {
		return new Box2D(name, {
			visible : visible

		});
	}

	/**
	 * Creates and initializes a Box2D world. 
	 */
	public function new(name : String, params : Dynamic = null) {
		_visible = false;
		_scale = 30;
		_group = 1;
		_view = Box2DDebugArt;
		super(name, params);
		_world = new B2World(new V2(0, 0));
		b2Base.initialize();
		//Set up collision categories
		CollisionCategories.Add("GoodGuys");
		CollisionCategories.Add("BadGuys");
		CollisionCategories.Add("Level");
		CollisionCategories.Add("Items");
	}

	override public function destroy() : Void {
		_world.destroy();
		super.destroy();
	}

	/**
	 * Gets a reference to the actual Box2D world object. 
	 */
	public function getWorld() : B2World {
		return _world;
	}

	/**
	 * This is hard to grasp, but Box2D does not use pixels for its physics values. Cutely, it uses meters
	 * and forces us to convert those meter values to pixels by multiplying by 30. If you don't multiple Box2D
	 * values by 30, your objecs will look very small and will appear to move very slowly, if at all.
	 * This is a reference to the scale number by which you must multiply your values to properly display physics objects. 
	 */
	public function getScale() : Float {
		return _scale;
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		_world.Step(1 / 20, 8, 8);
	}

	public function getX() : Float {
		return 0;
	}

	public function getY() : Float {
		return 0;
	}

	public function getParallax() : Float {
		return 1;
	}

	public function getRotation() : Float {
		return 0;
	}

	public function getGroup() : Float {
		return _group;
	}

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

	public function getAnimation() : String {
		return "";
	}

	public function getView() : Dynamic {
		return _view;
	}

	public function setView(value : Dynamic) : Dynamic {
		_view = value;
		return value;
	}

	public function getInverted() : Bool {
		return false;
	}

	public function getOffsetX() : Float {
		return 0;
	}

	public function getOffsetY() : Float {
		return 0;
	}

	public function getRegistration() : String {
		return "topLeft";
	}

}

