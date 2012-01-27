/**
 * Coin is basically a sensor that destroys itself when a particular class type touches it. 
 */
package com.citrusengine.objects.platformer;

import box2das.dynamics.ContactEvent;
import com.citrusengine.utils.Box2DShapeMaker;
import flash.display.MovieClip;
import flash.utils.GetDefinitionByName;

class Coin extends Sensor {
	public var collectorClass(never, setCollectorClass) : Dynamic;

	var _collectorClass : Class<Dynamic>;
	static public function Make(name : String, x : Float, y : Float, view : Dynamic = null) : Coin {
		if(view == null) view = MovieClip;
		return new Coin(name, {
			x : x
			y : y,
			view : view,

		});
	}

	public function new(name : String, params : Dynamic = null) {
		_collectorClass = Hero;
		super(name, params);
	}

	/**
	 * The Coin uses the collectorClass parameter to know who can collect it.
	 * Use this setter to to pass in which base class the collector should be, in String form
	 * or Object notation.
	 * For example, if you want to set the "Hero" class as your hero's enemy, pass
	 * "com.citrusengine.objects.platformer.Hero" or Hero directly (no quotes). Only String
	 * form will work when creating objects via a level editor.
	 */
	@:meta(Property(value="com.citrusengine.objects.platformer.Hero"))
	public function setCollectorClass(value : Dynamic) : Dynamic {
		if(Std.is(value, String)) _collectorClass = Type.getClass(getDefinitionByName(try cast(value, String) catch(e) null))
		else if(Std.is(value, Class)) _collectorClass = value;
		return value;
	}

	override function createShape() : Void {
		_shape = Box2DShapeMaker.Circle(_width, _height);
	}

	override function handleBeginContact(e : ContactEvent) : Void {
		super.handleBeginContact(e);
		if(_collectorClass && Std.is(e.other.GetBody().GetUserData(), _collectorClass))  {
			kill = true;
		}
	}

}

