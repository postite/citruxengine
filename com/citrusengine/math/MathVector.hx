package com.citrusengine.math;

class MathVector {
	public var angle(getAngle, setAngle) : Float;
	public var normal(getNormal, never) : MathVector;
	public var length(getLength, setLength) : Float;

	public var x : Float;
	public var y : Float;
	public function new(x : Float = 0, y : Float = 0) {
		this.x = x;
		this.y = y;
	}

	public function copy() : MathVector {
		return new MathVector(x, y);
	}

	public function getAngle() : Float {
		return Math.atan2(y, x);
	}

	public function setAngle(value : Float) : Float {
		x = length * Math.cos(value);
		y = length * Math.sin(value);
		return value;
	}

	public function rotate(angle : Float) : Void {
		var ca : Float = Math.cos(angle);
		var sa : Float = Math.sin(angle);
		x = x * ca - y * sa;
		y = x * sa + y * ca;
	}

	public function scaleEquals(value : Float) : Void {
		x *= value;
		y *= value;
	}

	public function scale(value : Float) : MathVector {
		return new MathVector(x * value, y * value);
	}

	public function getNormal() : MathVector {
		return new MathVector(-y, x);
	}

	public function setLength(value : Float) : Float {
		this.scaleEquals(value / length);
		return value;
	}

	public function plusEquals(vector : MathVector) : Void {
		x += vector.x;
		y += vector.y;
	}

	public function plus(vector : MathVector) : MathVector {
		return new MathVector(x + vector.x, y + vector.y);
	}

	public function minusEquals(vector : MathVector) : Void {
		x -= vector.x;
		y -= vector.y;
	}

	public function minus(vector : MathVector) : MathVector {
		return new MathVector(x - vector.x, y - vector.y);
	}

	public function getLength() : Float {
		return Math.sqrt((x * x) + (y * y));
	}

	public function toString() : String {
		return "[" + x + ", " + y + "]";
	}

}

