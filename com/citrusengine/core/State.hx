/**
 * The State class is very important. It usually contains the logic for a particular state the game is in.
 * There can only ever be one state running at a time. You should extend the State class
 * to create logic and scripts for your levels. You can build one state for each level, or
 * create a state that represents all your levels. You can get and set the reference to your active
 * state via the CitrusEngine class.
 */
package com.citrusengine.core;

import com.citrusengine.view.CitrusView;
import com.citrusengine.view.spriteview.SpriteView;
import flash.display.Sprite;

class State extends Sprite, implements IState {
	public var view(getView, never) : CitrusView;

	var _objects : Array<CitrusObject>;
	var _view : CitrusView;
	var _input : Input;
	public function new() {
		_objects = new Array<CitrusObject>();
	}

	/**
	 * Called by the Citrus Engine.
	 */
	public function destroy() : Void {
		//Call destroy on all objects, and remove all art from the stage.
		var n : Float = _objects.length;
		var i : Int = n - 1;
		while(i >= 0) {
			var object : CitrusObject = _objects[i];
			object.destroy();
			_view.removeArt(object);
			i--;
		}
		_objects.length = 0;
		_view.destroy();
	}

	/**
	 * Gets a reference to this state's view manager. Take a look at the class definition for more information about this. 
	 */
	public function getView() : CitrusView {
		return _view;
	}

	/**
	 * You'll most definitely want to override this method when you create your own State class. This is where you should
	 * add all your CitrusObjects and pretty much make everything. Please note that you can't successfully call add() on a 
	 * state in the constructur. You should call it in this initialize() method. 
	 */
	public function initialize() : Void {
		_view = createView();
		_input = CitrusEngine.getInstance().input;
	}

	/**
	 * This method calls update on all the CitrusObjects that are attached to this state.
	 * The update method also checks for CitrusObjects that are ready to be destroyed and kills them.
	 * Finally, this method updates the Input and View managers. 
	 */
	public function update(timeDelta : Float) : Void {
		//Call update on all objects
		var garbage : Array<Dynamic> = [];
		var n : Float = _objects.length;
		var i : Int = 0;
		while(i < n) {
			var object : CitrusObject = _objects[i];
			if(object.kill) garbage.push(object)
			else object.update(timeDelta);
			i++;
		}
		//Destroy all objects marked for destroy
		//TODO There might be a limit on the number of Box2D bodies that you can destroy in one tick?
		n = garbage.length;
		i = 0;
		while(i < n) {
			var garbageObject : CitrusObject = garbage[i];
			_objects.splice(_objects.indexOf(garbageObject), 1);
			garbageObject.destroy();
			_view.removeArt(garbageObject);
			i++;
		}
		//Update the input object
		_input.update();
		//Update the state's view
		_view.update();
	}

	/**
	 * Call this method to add a CitrusObject to this state. All visible game objects and physics objects
	 * will need to be created and added via this method so that they can be properly creatd, managed, updated, and destroyed. 
	 * @return The CitrusObject that you passed in. Useful for linking commands together.
	 */
	public function add(object : CitrusObject) : CitrusObject {
		_objects.push(object);
		_view.addArt(object);
		return object;
	}

	/**
	 * When you are ready to remove an object from getting updated, viewed, and generally being existent, call this method.
	 * Alternatively, you can just set the object's kill property to true. That's all this method does at the moment. 
	 */
	public function remove(object : CitrusObject) : Void {
		object.kill = true;
	}

	/**
	 * Gets a reference to a CitrusObject by passing that object's name in.
	 * Often the name property will be set via a level editor such as the Flash IDE. 
	 * @param name The name property of the object you want to get a reference to.
	 */
	public function getObjectByName(name : String) : CitrusObject {
		for(var object : CitrusObject in _objects) {
			if(object.name == name) return object;
		}

		return null;
	}

	/**
	 * Returns the first instance of a CitrusObject that is of the class that you pass in. 
	 * This is useful if you know that there is only one object of a certain time in your state (such as a "Hero").
	 * @param type The class of the object you want to get a reference to.
	 */
	public function getFirstObjectByType(type : Class<Dynamic>) : CitrusObject {
		for(var object : CitrusObject in _objects) {
			if(Std.is(object, type)) return object;
		}

		return null;
	}

	/**
	 * This returns an array of all objects of a particular type. This is useful for adding an event handler
	 * to all similar objects. For instance, if you want to track the collection of coins, you can get all objects
	 * of type "Coin" via this method. Then you'd loop through the returned array to add your listener to the coins' event. 
	 */
	public function getObjectsByType(type : Class<Dynamic>) : Array<CitrusObject> {
		var objects : Array<CitrusObject> = new Array<CitrusObject>();
		for(var object : CitrusObject in _objects) {
			if(Std.is(object, type))  {
				objects.push(object);
			}
		}

		return objects;
	}

	/**
	 * Override this method if you want a state to create an instance of a custom view. 
	 */
	function createView() : CitrusView {
		return new SpriteView(this);
	}

}

