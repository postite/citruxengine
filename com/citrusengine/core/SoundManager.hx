package com.citrusengine.core;

import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import com.citrusengine.utils.ObjectHash;



class SoundManager {

	static var _instance : SoundManager;
	//PORTODO DICTIONARIES
	//PORTODO ObjectHash could be simple Hash here !
	//PORTODO Reflect for assign .channel in HAsh with Reflect ?
	public var sounds : ObjectHash<Dynamic>;
	public var currPlayingSounds : ObjectHash<Dynamic>;
	public function new(pvt : PrivateClass) {
		sounds = new ObjectHash<Dynamic>();
		currPlayingSounds = new ObjectHash<Dynamic>();
	}

	static public function getInstance() : SoundManager {
		if(_instance==null) _instance = new SoundManager(new PrivateClass());
		return _instance;
	}

	/*
	 * The sound is a path to a file or an embedded sound 
	 */
	public function addSound(id : String, url : String = "", embeddedClass : Class<Dynamic> = null) : Void {
		if(url != "") sounds.set(id, url);
		else sounds.set(id, embeddedClass);
	}

	public function removeSound(id : String) : Void {
		var currID : String;
		for(currID in currPlayingSounds) {
			if(currID == id)  {
				
				currPlayingSounds.remove(id);
				break;
			}
		}

		for(currID in sounds) {
			if(currID == id)  {
				
				sounds.remove(id);
				break;
			}
		}

	}

	public function hasSound(id : String) : Bool {
		//return cast((sounds[id]), Boolean);
		return sounds.exists(id);
	}

	public function playSound(id : String, volume : Float = 1.0, timesToRepeat : Int = 999) : Void {
		// Check for an existing sound, and play it.
		var t : SoundTransform;
		for(currID  in currPlayingSounds) {
			if(currID == id)  {

				//PORTODO Reflect?
				var c : SoundChannel = cast(currPlayingSounds.get(id).channel, SoundChannel) ;
				//PORTODO Reflect?
				var s : Sound = cast(currPlayingSounds.get(id).sound, Sound) ;
				t = new SoundTransform(volume);
				c = s.play(0, timesToRepeat);
				c.soundTransform = t;
				currPlayingSounds.set(id,{
					channel : c,
					sound : s,
					volume : volume});
				
				return;
			}
		}

		// Create a new sound
		var soundFactory : Sound;
		if(Std.is(sounds.get(id), Class))  {

			soundFactory=cast(Type.createInstance(sounds.get(id),[]),Sound);
			
		}

		else  {
			soundFactory = new Sound();
			soundFactory.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
			soundFactory.load(new URLRequest(sounds.get(id)));
		}

		var channel : SoundChannel = new SoundChannel();
		channel = soundFactory.play(0, timesToRepeat);
		t = new SoundTransform(volume);
		channel.soundTransform = t;
		currPlayingSounds.set(id,  {
			channel : channel,
			sound : soundFactory,
			volume : volume

		});
	}

	public function stopSound(id : String) : Void {
		for( currID  in currPlayingSounds) {
			if(currID == id) 
			cast(currPlayingSounds.get(id).channel, SoundChannel).stop();
		}

	}

	public function setGlobalVolume(volume : Float) : Void {
		for(currID  in currPlayingSounds) {
			var s : SoundTransform = new SoundTransform(volume);
			cast(currPlayingSounds.get(currID).channel, SoundChannel).soundTransform = s;
				currPlayingSounds.get(currID).volume = volume;
		}

	}

	public function muteAll(mute : Bool = true) : Void {
		if(mute)  {
			setGlobalVolume(0);
		}

		else  {
			for(currID  in currPlayingSounds) {
				var s : SoundTransform = new SoundTransform(currPlayingSounds.get(currID).volume);
				cast(currPlayingSounds.get(currID).channel, SoundChannel).soundTransform = s;
			}

		}

	}

	public function setVolume(id : String, volume : Float) : Void {
		for(currID in  currPlayingSounds) {
			if(currID == id)  {
				var s : SoundTransform = new SoundTransform(volume);
				cast(currPlayingSounds.get(id).channel, SoundChannel).soundTransform = s;
				currPlayingSounds.get(id).volume = volume;
			}
		}

	}

	public function getSoundChannel(id : String) : SoundChannel {
		for( currID in currPlayingSounds) {
			if(currID == id) return cast(currPlayingSounds.get(id).channel, SoundChannel);
		}

		throw ("You are trying to get a non-existent soundChannel. Play it first in order to assign a channel");
		return null;
	}

	public function getSoundTransform(id : String) : SoundTransform
	 {
		for(currID in currPlayingSounds) {
			if(currID == id) return cast(currPlayingSounds.get(id).channel, SoundChannel).soundTransform;
		}

		throw ("You are trying to get a non-existent soundTransform. Play it first in order to assign a transform");
		return null;
	}

	public function getSoundVolume(id : String) : Float {
		for(currID in currPlayingSounds) {
			if(currID == id) return currPlayingSounds.get(id).volume;
		}

		throw ("You are trying to get a non-existent volume. Play it first in order to assign a volume.");
		return Math.NaN;
	}

	function handleLoadError(e : IOErrorEvent) : Void {
		trace("Sound manager failed to load a sound: " + e.text);
	}

}

class PrivateClass {
 	public function new() 
 	{
 		
 	}
}

