package com.citrusengine.objects.common;

import com.citrusengine.objects.CitrusSprite;

class EmitterParticle extends CitrusSprite {

	public var velocityX : Float;
	public var velocityY : Float;
	public var birthTime : Float;
	public var canRecycle : Bool;
	public function new(name : String, params : Dynamic = null) {
		velocityX = 0;
		velocityY = 0;
		birthTime = 0;
		canRecycle = true;
		super(name, params);
		if(birthTime == 0) birthTime = new Date().time;
	}

}

