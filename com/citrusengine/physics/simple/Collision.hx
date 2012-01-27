package com.citrusengine.physics.simple;

import com.citrusengine.math.MathVector;
import com.citrusengine.objects.CitrusSprite;

class Collision {

	static public var BEGIN : UInt = 0;
	static public var PERSIST : UInt = 1;
	public var self : CitrusSprite;
	public var other : CitrusSprite;
	public var normal : MathVector;
	public var impact : Float;
	public var type : UInt;
	public function new(self : CitrusSprite, other : CitrusSprite, normal : MathVector, impact : Float, type : UInt) {
		this.self = self;
		this.other = other;
		this.normal = normal;
		this.impact = impact;
		this.type = type;
	}

}

