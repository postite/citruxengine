/**
 * The CitrusSolver is a simple math-based collision-detection system built for doing simple collision detection in games where physics needs are light
 * and Box2D is overkill (also useful for mobile). The Citrus Solver works with the CitrusSprite objects, and uses their x, y, width, and height properties to 
 * report and adjust for collisions.
 * 
 * The CitrusSolver is not useful for the following cases: 1) Rotated (non-axis-aligned) objects, angular velocity, mass-based collision reactions, and dynamic-to-dynamic object
 * collisions (only static-to-dynamic works). If you need any of those physics features, you should use Box2D instead.
 * If you only need to know if an overlap occured and you don't need to solve the collision, then you may test collisions between two dynamic
 * (moving) objects.
 * 
 * After you create your CitrusSolver instance, you will want to call the collide() and/or overlap() methods to tell the solver which object types to test for collisions/overlaps
 * against. See the documentation for those two classes for more info.
 */
package com.citrusengine.physics.simple;

import com.citrusengine.core.CitrusEngine;
import com.citrusengine.core.CitrusObject;
import com.citrusengine.math.MathVector;
import com.citrusengine.objects.CitrusSprite;

class CitrusSolver extends CitrusObject {

	var _ce : CitrusEngine;
	var _collideChecks : Array<Dynamic>;
	var _overlapChecks : Array<Dynamic>;
	public function new(name : String, params : Dynamic = null) {
		_collideChecks = new Array<Dynamic>();
		_overlapChecks = new Array<Dynamic>();
		super(name, params);
		_ce = CitrusEngine.getInstance();
	}

	/**
	 * Call this method once after the CitrusSolver constructor to tell the solver to report (and solve) collisions between the two specified objects.
	 * The CitrusSolver will then automatically test collisions between any game object of the specified type once per frame.
	 * You can only test collisions between a dynamic (movable) object and a static (non-moviable) object.
	 * @param	dynamicObjectType The object that will be moved away from overlapping during a collision (probably your hero or something else that moves).
	 * @param	staticObjectType The object that does not move (probably your platform or wall, etc).
	 */
	public function collide(dynamicObjectType : Class<Dynamic>, staticObjectType : Class<Dynamic>) : Void {
		_collideChecks.push({
			a : dynamicObjectType
			b : staticObjectType,

		});
	}

	/**
	 * Call this method once after the CitrusSolver constructor to tell the solver to report overlaps between the two specified objects.
	 *  The CitrusSolver will then automatically test overlaps between any game object of the specified type once per frame.
	 * With overlaps, you ARE allowed to test between two dynamic (moving) objects.
	 * @param	typeA The first type of object you want to test for collisions against the second object type.
	 * @param	typeB The second type of object you want to test for collisions against the first object type.
	 */
	public function overlap(typeA : Class<Dynamic>, typeB : Class<Dynamic>) : Void {
		_overlapChecks.push({
			a : typeA
			b : typeB,

		});
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		for(var pair : Dynamic in _collideChecks) {
			if(pair.a == pair.b)  {
				throw new Error("CitrusSolver does not test collisions against objects of the same type.");
			}

			else  {
				// compare A's to B's
				var groupA : Array<CitrusObject> = _ce.state.getObjectsByType(pair.a);
				var i : UInt = 0;
				while(i < groupA.length) {
					var itemA : CitrusSprite = try cast(groupA[i], CitrusSprite) catch(e) null;
					var groupB : Array<CitrusObject> = _ce.state.getObjectsByType(pair.b);
					var j : UInt = 0;
					while(j < groupB.length) {
						var itemB : CitrusSprite = try cast(groupB[j], CitrusSprite) catch(e) null;
						collideOnce(itemA, itemB);
						++j;
					}
					++i;
				}
			}

		}

		for(pair in _overlapChecks) {
			if(pair.a == pair.b)  {
				// compare A's to each other
				//PORTODO var group:Vector.<CitrusObject> = _ce.state.getObjectsByType(pair.a);
				i = 0;
				while(i < groupA.length) {
					itemA = try cast(group[i], CitrusSprite) catch(e) null;
					j = i + 1;
					while(j < group.length) {
						itemB = try cast(group[j], CitrusSprite) catch(e) null;
						overlapOnce(itemA, itemB);
						++j;
					}
					++i;
				}
			}

			else  {
				// compare A's to B's
				groupA = _ce.state.getObjectsByType(pair.a);
				i = 0;
				while(i < groupA.length) {
					itemA = try cast(groupA[i], CitrusSprite) catch(e) null;
					groupB = _ce.state.getObjectsByType(pair.b);
					j = 0;
					while(j < groupB.length) {
						itemB = try cast(groupB[j], CitrusSprite) catch(e) null;
						overlapOnce(itemA, itemB);
						++j;
					}
					++i;
				}
			}

		}

	}

	public function collideOnce(a : CitrusSprite, b : CitrusSprite) : Bool {
		var diffX : Float = (a.width / 2 + b.width / 2) - Math.abs(a.x - b.x);
		if(diffX >= 0)  {
			var diffY : Float = (a.height / 2 + b.height / 2) - Math.abs(a.y - b.y);
			if(diffY >= 0)  {
				var collisionType : UInt;
				var impact : Float;
				var normal : Float;
				if(diffX < diffY)  {
					// horizontal collision
					if(a.x < b.x)  {
						a.x -= diffX;
						normal = 1;
						if(a.velocity.x > 0) a.velocity.x = 0;
					}

					else  {
						a.x += diffX;
						normal = -1;
						if(a.velocity.x < 0) a.velocity.x = 0;
					}

					impact = Math.abs(b.velocity.x - a.velocity.x);
					if(!a.collisions[b])  {
						a.collisions[b] = new Collision(a, b, new MathVector(normal, 0), -impact, Collision.BEGIN);
						a.onCollide.dispatch(a, b, new MathVector(0, normal), -impact);
						b.collisions[a] = new Collision(b, a, new MathVector(-normal, 0), impact, Collision.BEGIN);
						b.onCollide.dispatch(b, a, new MathVector(0, -normal), impact);
					}

					else  {
						a.collisions[b].type = Collision.PERSIST;
						a.collisions[b].impact = impact;
						a.collisions[b].normal.x = normal;
						a.collisions[b].normal.y = 0;
						a.onPersist.dispatch(a, b, a.collisions[b].normal);
						b.collisions[a].type = Collision.PERSIST;
						b.collisions[a].impact = -impact;
						b.collisions[a].normal.x = -normal;
						b.collisions[a].normal.y = 0;
						b.onPersist.dispatch(b, a, b.collisions[a].normal);
					}

				}

				else  {
					// vertical collision
					if(a.y < b.y)  {
						a.y -= diffY;
						normal = 1;
						if(a.velocity.y > 0) a.velocity.y = 0;
					}

					else  {
						a.y += diffY;
						normal = -1;
						if(a.velocity.y < 0) a.velocity.y = 0;
					}

					impact = Math.abs(b.velocity.y - a.velocity.y);
					if(!a.collisions[b])  {
						a.collisions[b] = new Collision(a, b, new MathVector(0, normal), -impact, Collision.BEGIN);
						a.onCollide.dispatch(a, b, new MathVector(0, normal), -impact);
						b.collisions[a] = new Collision(b, a, new MathVector(0, -normal), impact, Collision.BEGIN);
						b.onCollide.dispatch(b, a, new MathVector(0, -normal), impact);
					}

					else  {
						a.collisions[b].type = Collision.PERSIST;
						a.collisions[b].impact = impact;
						a.collisions[b].normal.x = 0;
						a.collisions[b].normal.y = normal;
						a.onPersist.dispatch(a, b, a.collisions[b].normal);
						b.collisions[a].type = Collision.PERSIST;
						b.collisions[a].impact = -impact;
						b.collisions[a].normal.x = 0;
						b.collisions[a].normal.y = -normal;
						b.onPersist.dispatch(b, a, b.collisions[a].normal);
					}

				}

				return true;
			}
		}
		if(a.collisions[b])  {
			a.onSeparate.dispatch(a, b);
			delete;
			a.collisions[b];
			b.onSeparate.dispatch(b, a);
			delete;
			b.collisions[a];
		}
		return false;
	}

	public function overlapOnce(a : CitrusSprite, b : CitrusSprite) : Bool {
		///PORTODO	var overlap:Boolean = (a.x + a.width / 2 >= b.x - b.width / 2 && a.x - a.width / 2 <= b.x + b.width / 2 && // x axis overlaps
		//		a.y + a.height / 2 >= b.y - b.height / 2 && a.y - a.height / 2 <= b.y + b.height / 2); // y axis overlaps
		if(overlap)  {
			a.onCollide.dispatch(a, b, null, 0);
			b.onCollide.dispatch(b, a, null, 0);
		}
		return overlap;
	}

}

