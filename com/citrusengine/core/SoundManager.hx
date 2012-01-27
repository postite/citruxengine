package com.citrusengine.core;

import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.Dictionary;

class SoundManager {

	static var _instance : SoundManager;
	public var sounds : Dictionary;
	public var currPlayingSounds : Dictionary;
	public function new(pvt : PrivateClass) {
		sounds = new Dictionary();
		currPlayingSounds = new Dictionary();
	}

	static public function getInstance() : SoundManager {
		if(!_instance) _instance = new SoundManager(new PrivateClass());
		return _instance;
	}

	/*
	 * The sound is a path to a file or an embedded sound 
	 */
	public function addSound(id : String, url : String = "", embeddedClass : Class<Dynamic> = null) : Void {
		if(url != "") sounds[id] = url
		else sounds[id] = embeddedClass;
	}

	public function removeSound(id : String) : Void {
		var currID : String;
		for(currID in Reflect.fields(currPlayingSounds)) {
			if(currID == id)  {
				delete;
				currPlayingSounds[id];
				break;
			}
		}

		for(currID in Reflect.fields(sounds)) {
			if(currID == id)  {
				delete;
				sounds[id];
				break;
			}
		}

	}

	public function hasSound(id : String) : Bool {
		return cast((sounds[id]), Boolean);
	}

	public function playSound(id : String, volume : Float = 1.0, timesToRepeat : Int = 999) : Void {
		// Check for an existing sound, and play it.
		var t : SoundTransform;
		for(var currID : String in Reflect.fields(currPlayingSounds)) {
			if(currID == id)  {
				var c : SoundChannel = try cast(currPlayingSounds[id].channel, SoundChannel) catch(e) null;
				var s : Sound = try cast(currPlayingSounds[id].sound, Sound) catch(e) null;
				t = new SoundTransform(volume);
				c = s.play(0, timesToRepeat);
				c.soundTransform = t;
				currPlayingSounds[id] = {
					channel : c
					sound : s,
					volume : volume,

				};
				return;
			}
		}

		// Create a new sound
		var soundFactory : Sound;
		if(Std.is(sounds[id], Class))  {
			soundFactory = try cast(new Sounds()[id](), Sound) catch(e) null;
		}

		else  {
			soundFactory = new Sound();
			soundFactory.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
			soundFactory.load(new URLRequest(sounds[id]));
		}

		var channel : SoundChannel = new SoundChannel();
		channel = soundFactory.play(0, timesToRepeat);
		t = new SoundTransform(volume);
		channel.soundTransform = t;
		currPlayingSounds[id] = {
			channel : channel
			sound : soundFactory,
			volume : volume,

		};
	}

	public function stopSound(id : String) : Void {
		for(var currID : String in Reflect.fields(currPlayingSounds)) {
			if(currID == id) cast((currPlayingSounds[id].channel), SoundChannel).stop();
		}

	}

	public function setGlobalVolume(volume : Float) : Void {
		for(var currID : String in Reflect.fields(currPlayingSounds)) {
			var s : SoundTransform = new SoundTransform(volume);
			cast((currPlayingSounds[currID].channel), SoundChannel).soundTransform = s;
			currPlayingSounds[currID].volume = volume;
		}

	}

	public function muteAll(mute : Bool = true) : Void {
		if(mute)  {
			setGlobalVolume(0);
		}

		else  {
			for(var currID : String in Reflect.fields(currPlayingSounds)) {
				var s : SoundTransform = new SoundTransform(currPlayingSounds[currID].volume);
				cast((currPlayingSounds[currID].channel), SoundChannel).soundTransform = s;
			}

		}

	}

	public function setVolume(id : String, volume : Float) : Void {
		for(var currID : String in Reflect.fields(currPlayingSounds)) {
			if(currID == id)  {
				var s : SoundTransform = new SoundTransform(volume);
				cast((currPlayingSounds[id].channel), SoundChannel).soundTransform = s;
				currPlayingSounds[id].volume = volume;
			}
		}

	}

	public function getSoundChannel(id : String) : SoundChannel {
		for(var currID : String in Reflect.fields(currPlayingSounds)) {
			if(currID == id) return cast((currPlayingSounds[id].channel), SoundChannel);
		}

		throw cast(("You are trying to get a non-existent soundChannel. Play it first in order to assign a channel"), Error);
		return null;
	}

	public function getSoundTransform(id : String) : SoundTransform {
		for(var currID : String in Reflect.fields(currPlayingSounds)) {
			if(currID == id) return cast((currPlayingSounds[id].channel), SoundChannel).soundTransform;
		}

		throw cast(("You are trying to get a non-existent soundTransform. Play it first in order to assign a transform"), Error);
		return null;
	}

	public function getSoundVolume(id : String) : Float {
		for(var currID : String in Reflect.fields(currPlayingSounds)) {
			if(currID == id) return currPlayingSounds[id].volume;
		}

		throw cast(("You are trying to get a non-existent volume. Play it first in order to assign a volume."), Error);
		return NaN;
	}

	function handleLoadError(e : IOErrorEvent) : Void {
		trace("Sound manager failed to load a sound: " + e.text);
	}

}

class PrivateClass {

}

