/**
 * A very simple physics object. I just needed to add bullet mode and zero restitution
 * to make it more stable, otherwise it gets very jittery. 
 */
package com.citrusengine.objects.platformer;

import com.citrusengine.objects.PhysicsObject;
import flash.display.MovieClip;

class Crate extends PhysicsObject {

	static public function Make(name : String, x : Float, y : Float, width : Float, height : Float, view : Dynamic = null) : Crate {
		if(view == null) view = MovieClip;
		return new Crate(name, {
			x : x
			y : y,
			width : width,
			height : height,
			view : view,

		});
	}

	public function new(name : String, params : Dynamic = null) {
		super(name, params);
	}

	override function defineBody() : Void {
		super.defineBody();
		_bodyDef.bullet = true;
	}

	override function defineFixture() : Void {
		super.defineFixture();
		_fixtureDef.density = 0.1;
		_fixtureDef.restitution = 0;
	}

	//This is only used to register the crate with the Level Architect
	@:meta(Property(value="30"))
	override public function setWidth(value : Float) : Float {
		super.width = value;
		return value;
	}

}

