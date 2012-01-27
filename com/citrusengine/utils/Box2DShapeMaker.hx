package com.citrusengine.utils;

import box2das.collision.shapes.B2CircleShape;
import box2das.collision.shapes.B2PolygonShape;
import box2das.common.V2;

class Box2DShapeMaker {

	static public function BeveledRect(width : Float, height : Float, bevel : Float) : B2PolygonShape {
		var halfWidth : Float = width * 0.5;
		var halfHeight : Float = height * 0.5;
		var shape : B2PolygonShape = new B2PolygonShape();
		var vertices : Array<V2> = new Array<V2>();
		vertices.push(new V2(-halfWidth + bevel, -halfHeight));
		vertices.push(new V2(halfWidth - bevel, -halfHeight));
		vertices.push(new V2(halfWidth, -halfHeight + bevel));
		vertices.push(new V2(halfWidth, halfHeight - bevel));
		vertices.push(new V2(halfWidth - bevel, halfHeight));
		vertices.push(new V2(-halfWidth + bevel, halfHeight));
		vertices.push(new V2(-halfWidth, halfHeight - bevel));
		vertices.push(new V2(-halfWidth, -halfHeight + bevel));
		shape.Set(vertices);
		return shape;
	}

	static public function Rect(width : Float, height : Float) : B2PolygonShape {
		var shape : B2PolygonShape = new B2PolygonShape();
		shape.SetAsBox(width * 0.5, height * 0.5);
		return shape;
	}

	static public function Circle(width : Float, height : Float) : B2CircleShape {
		var radius : Float = (width + height) * 0.25;
		var shape : B2CircleShape = new B2CircleShape();
		shape.m_radius = radius;
		return shape;
	}

}

