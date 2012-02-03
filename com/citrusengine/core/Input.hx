package com.citrusengine.core;

import flash.events.KeyboardEvent;
//PORTODO DICTIONARY
import flash.utils.Dictionary;

class Input {
	public var enabled(getEnabled, setEnabled) : Bool;

	static public var JUST_PRESSED : UInt = 0;
	static public var DOWN : UInt = 1;
	static public var JUST_RELEASED : UInt = 2;
	static public var UP : UInt = 3;
	var _keys : Dictionary;
	var _keysReleased : Array<Int>;
	var _initialized : Bool;
	var _enabled : Bool;
	public function new() {
		_enabled = true;
		_keys = new Dictionary();
		_keysReleased = new Array<Int>();
	}

	/**
	 * Sets and determines whether or not keypresses will be
	 * registered through the Input class. 
	 */
	public function getEnabled() : Bool {
		return _enabled;
	}

	public function setEnabled(value : Bool) : Bool {
		if(_enabled == value) return;
		_enabled = value;
		var ce : CitrusEngine = CitrusEngine.getInstance();
		if(_enabled)  {
			ce.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			ce.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		else  {
			ce.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			ce.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		return value;
	}

	/**
	 * This method should be called AFTER everything has gathered input data from it for this tick.
	 * Implementors, you don't need to call this function. Citrus Engine does it for you.
	 */
	public function update() : Void {
		if(!_enabled) return;
		for(key in Reflect.fields(_keys)) {
			if(Reflect.field(_keys,key) == JUST_PRESSED) Reflect.setField(_keys,key , DOWN);
		}

		_keysReleased.length = 0;
	}

	/**
	 * Citrus engine calls this function for you. 
	 */
	public function initialize() : Void {
		if(_initialized) return;
		_initialized = true;
		var ce : CitrusEngine = CitrusEngine.getInstance();
		ce.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		ce.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	/**
	 * Says YES! if the key you requested is being pressed. Says nah if naht. 
	 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
	 */
	public function isDown(keyCode : Int) : Bool {
		return _keys[keyCode] == DOWN;
	}

	/**
	 * Says YES! if the key you requested was pressed between last tick and this tick. Says nah if naht. 
	 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
	 */
	public function justPressed(keyCode : Int) : Bool {
		return _keys[keyCode] == JUST_PRESSED;
	}

	/**
	 * Says YES! if the key you requested was released between last keick and this tick. Says nah if naht. 
	 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
	 */
	public function justReleased(keyCode : Int) : Bool {
		return _keysReleased.indexOf(keyCode) != -1;
	}

	/**
	 * Returns an unsigned integer representing the key's current state.
	 * @param keyCode a "code" representing a key on the keyboard. Use Flash's Keyboard class constants if you please. 
	 */
	public function getState(keyCode : Int) : UInt {
		if(_keys[keyCode]) return _keys[keyCode]
		else if(_keysReleased.indexOf(keyCode) != -1) return JUST_RELEASED
		else return UP;
	}

	function onKeyDown(e : KeyboardEvent) : Void {
		if(!_keys[e.keyCode]) _keys[e.keyCode] = JUST_PRESSED;
	}

	function onKeyUp(e : KeyboardEvent) : Void {

		delete	_keys[e.keyCode];

		_keysReleased.push(e.keyCode);
	}

}

