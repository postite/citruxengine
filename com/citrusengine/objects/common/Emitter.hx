/**
 * An emitter creates particles at a specified rate with specified distribution properties. You can set the emitter's x and y
 * location at any time as well as change the graphic of the particles that the emitter makes.
 */
package com.citrusengine.objects.common;

import com.citrusengine.core.CitrusEngine;
import com.citrusengine.core.CitrusObject;
import com.citrusengine.view.blittingview.BlittingArt;
import com.citrusengine.view.blittingview.BlittingView;

class Emitter extends CitrusObject {
	public var graphic(getGraphic, setGraphic) : Dynamic;

	/**
	 * The X position where the particles will emit from.
	 */
	public var x : Float;
	/**
	 * The Y position where the particles will emit from.
	 */
	public var y : Float;
	/**
	 * In milliseconds, how often the emitter will release new particles.
	 */
	public var emitFrequency : Float;
	/**
	 * The number of particles that the emitter will release during each emission.
	 */
	public var emitAmount : UInt;
	/**
	 * In milliseconds, how long the particles will last before being recycled.
	 */
	public var particleLifeSpan : Float;
	/**
	 * The X force applied to particle velocity, in pixels per frame.
	 */
	public var gravityX : Float;
	/**
	 * The Y force applied to particle velocity, in pixels per frame.
	 */
	public var gravityY : Float;
	/**
	 * A number between 0 and 1 to create air resistence. Lower numbers create slow floatiness like a feather.
	 */
	public var dampingX : Float;
	/**
	 * A number between 0 and 1 to create air resistence. Lower numbers create slow floatiness like a feather.
	 */
	public var dampingY : Float;
	/**
	 * The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
	 */
	public var minImpulseX : Float;
	/**
	 * The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
	 */
	public var maxImpulseX : Float;
	/**
	 * The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
	 */
	public var minImpulseY : Float;
	/**
	 * The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
	 */
	public var maxImpulseY : Float;
	/**
	 * In miliseconds, how long the emitter lasts before destroying itself. If the value is -1, it lasts forever.
	 */
	public var emitterLifeSpan : Int;
	/**
	 * The width deviation from the x position that a particle can be created via a randomly generated number.
	 */
	public var emitAreaWidth : Float;
	/**
	 * The height deviation from the y position that a particle can be created via a randomly generated number.
	 */
	public var emitAreaHeight : Float;
	var _particles : Array<EmitterParticle>;
	var _recycle : Array<Dynamic>;
	var _graphic : Dynamic;
	var _particlesCreated : UInt;
	var _lastEmission : Float;
	var _birthTime : Float;
	var _ce : CitrusEngine;
	/**
	 * Makes a particle emitter. 
	 * @param	name The name of the emitter.
	 * @param	graphic The graphic class to use to create each particle.
	 * @param	x The X position where the particles will emit from.
	 * @param	y The Y position where the particles will emit from.
	 * @param	emitFrequency In milliseconds, how often the emitter will release new particles.
	 * @param	emitAmount The number of particles that the emitter will release during each emission.
	 * @param	particleLifeSpan In milliseconds, how long the particles will last before being recycled.
	 * @param	gravityX The X force applied to particle velocity, in pixels per frame.
	 * @param	gravityY The Y force applied to particle velocity, in pixels per frame.
	 * @param	dampingX A number between 0 and 1 to create air resistence. Lower numbers create slow floatiness like a feather.
	 * @param	dampingY A number between 0 and 1 to create air resistence. Lower numbers create slow floatiness like a feather.
	 * @param	minImpulseX The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
	 * @param	maxImpulseX The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
	 * @param	minImpulseY The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
	 * @param	maxImpulseY The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
	 * @param	emitterLifeSpan In miliseconds, how long the emitter lasts before destroying itself. If the value is -1, it lasts forever.
	 * @param	emitAreaWidth The width deviation from the x position that a particle can be created via a randomly generated number.
	 * @param	emitAreaHeight The height deviation from the y position that a particle can be created via a randomly generated number.
	 * @return An emitter.
	 */
	static public function Make(name : String, graphic : Dynamic, x : Float, y : Float, emitFrequency : Float, emitAmount : Float, particleLifeSpan : Float, gravityX : Float, gravityY : Float, dampingX : Float, dampingY : Float, minImpulseX : Float, maxImpulseX : Float, minImpulseY : Float, maxImpulseY : Float, emitterLifeSpan : Float = -1, emitAreaWidth : Float = 0, emitAreaHeight : Float = 0) : Emitter {
		return new Emitter(name, {
			graphic : graphic
			x : x,
			y : y,
			emitFrequency : emitFrequency,
			emitAmount : emitAmount,
			particleLifeSpan : particleLifeSpan,
			gravityX : gravityX,
			gravityY : gravityY,
			dampingX : dampingX,
			dampingY : dampingY,
			minImpulseX : minImpulseX,
			maxImpulseX : maxImpulseX,
			minImpulseY : minImpulseY,
			maxImpulseY : maxImpulseY,
			emitterLifeSpan : emitterLifeSpan,
			emitAreaWidth : emitAreaWidth,
			emitAreaHeight : emitAreaHeight,

		});
	}

	public function new(name : String, params : Dynamic = null) {
		x = 0;
		y = 0;
		emitFrequency = 300;
		emitAmount = 1;
		particleLifeSpan = 3000;
		gravityX = 0;
		gravityY = 0;
		dampingX = 1;
		dampingY = 1;
		minImpulseX = -10;
		maxImpulseX = 10;
		minImpulseY = -10;
		maxImpulseY = 10;
		emitterLifeSpan = -1;
		emitAreaWidth = 0;
		emitAreaHeight = 0;
		_particles = new Array<EmitterParticle>();
		_recycle = new Array<Dynamic>();
		_particlesCreated = 0;
		_lastEmission = 0;
		_birthTime = -1;
		super(name, params);
		_ce = CitrusEngine.getInstance();
	}

	override public function destroy() : Void {
		for(var particle : EmitterParticle in _particles)particle.kill = true;
		_particles.length = 0;
		for(var particle : EmitterParticle in _recycle)particle.kill = true;
		_recycle.length = 0;
		super.destroy();
	}

	/**
	 * The graphic that will be generated for each particle. This works just like the CitrusObject's view property.
	 * The value can be 1) The path to an external image, 2) A DisplayObject class (not an instance) in String notation
	 * (view: "com.graphics.myParticle") or 3) A DisplayObject class (not an instance) in Object notation
	 * (view: MyParticle). See the documentation for ISpriteView.view for more info.
	 */
	public function getGraphic() : Dynamic {
		return _graphic;
	}

	public function setGraphic(value : Dynamic) : Dynamic {
		_graphic = value;
		destroyRecycle();
		//clear the reusable ones, they all have to be remade
		return value;
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		var now : Float = new Date().time;
		var particle : EmitterParticle;
		var emitterExpired : Bool = (emitterLifeSpan != -1 && _birthTime != -1 && _birthTime + emitterLifeSpan <= now);
		//check to see if any particles should be destroyed
		var i : Int = _particles.length - 1;
		while(i >= 0) {
			particle = _particles[i];
			if(particle.birthTime + particleLifeSpan <= now)  {
				if(particle.canRecycle)  {
					particle.visible = false;
					_recycle.push(particle);
				}

				else  {
					particle.kill = true;
				}

				_particles.splice(_particles.indexOf(particle), 1);
			}
			i--;
		}
		//generate more particles if necessary
		if(!emitterExpired && now - _lastEmission >= emitFrequency)  {
			_lastEmission = now;
			i = 0;
			while(i < emitAmount) {
				particle = getOrCreateParticle(now);
				i++;
			}
			//Set the emitter's birth time if this is the first emission.
			if(_birthTime == -1) _birthTime = now;
		}
		for(particle in _particles) {
			particle.velocityX += gravityX;
			particle.velocityY += gravityY;
			particle.velocityX *= dampingX;
			particle.velocityY *= dampingY;
			particle.x += (particle.velocityX * timeDelta);
			particle.y += (particle.velocityY * timeDelta);
		}

		//should we destroy the emitter?
		if(emitterExpired && _particles.length == 0) kill = true;
	}

	function getOrCreateParticle(birthTime : Float) : EmitterParticle {
		var particle : EmitterParticle = _recycle.pop();
		if(!particle)  {
			if(Std.is(_ce.state.view, BlittingView))  {
				particle = new EmitterParticle(name + "_" + _particlesCreated++, {
					view : new BlittingArt(graphic)

				});
			}

			else  {
				particle = new EmitterParticle(name + "_" + _particlesCreated++, {
					view : graphic

				});
			}

			_ce.state.add(particle);
		}
		_particles.push(particle);
		particle.x = Math.random() * emitAreaWidth + (x - emitAreaWidth / 2);
		particle.y = Math.random() * emitAreaHeight + (y - emitAreaHeight / 2);
		particle.velocityX = Math.random() * (maxImpulseX - minImpulseX) + minImpulseX;
		particle.velocityY = Math.random() * (maxImpulseY - minImpulseY) + minImpulseY;
		particle.birthTime = birthTime;
		particle.visible = true;
		return particle;
	}

	function destroyRecycle() : Void {
		for(var particle : EmitterParticle in _recycle)particle.kill = true;
		_recycle.length = 0;
		for(particle in _particles)particle.canRecycle = false;
	}

}

