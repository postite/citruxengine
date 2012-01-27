/**	 * A Treadmill is a MovingPlatform with some new options.	 * Properties:	 * speedTread : the speed of the tread.	 * startingDirection : the tread's direction.	 * enableTreadmill : activate it or not.	 */
package com.citrusengine.objects.platformer;

import box2das.dynamics.B2Body;
import com.citrusengine.objects.platformer.MovingPlatform;

class Treadmill extends MovingPlatform {

	/**		 * The speed of the tread.		 */
	@:meta(Property(value="3"))
	public var speedTread : Float;
	/**		 * The tread's direction.		 */
	@:meta(Property(value="right"))
	public var startingDirection : String;
	/** 		 * Activate it or not. 		 */
	@:meta(Property(value="true"))
	public var enableTreadmill : Bool;
	public function new(name : String, params : Dynamic = null) {
		speedTread = 3;
		startingDirection = "right";
		enableTreadmill = true;
		super(name, params);
		if(startingDirection == "left")  {
			_inverted = true;
		}
	}

	override public function destroy() : Void {
		super.destroy();
	}

	override public function update(timeDelta : Float) : Void {
		super.update(timeDelta);
		if(enableTreadmill)  {
			for(var passengers : B2Body in _passengers) {
				if(startingDirection == "right")  {
					passengers.GetUserData().x += speedTread;
				}

				else  {
					passengers.GetUserData().x -= speedTread;
				}

			}

		}
		_updateAnimation();
	}

	function _updateAnimation() : Void {
		if(enableTreadmill)  {
			_animation = "move";
		}

		else  {
			_animation = "normal";
		}

	}

}

