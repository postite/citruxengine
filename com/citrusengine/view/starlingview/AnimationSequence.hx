/**
 * The Animation Sequence class represents all object animations in one sprite sheet. You have to create your texture atlas in your state class.
 * Example : var hero:Hero = new Hero("Hero", {x:400, width:60, height:130, view:new AnimationSequence(textureAtlas, ["walk", "duck", "idle", "jump"], "idle")});
 * 
 * @param textureAtlas : a TextureAtlas object with all your object's animations
 * @param animations : an array with all your object's animations as a String
 * @param firstAnimation : a string of your default animation at its creation
 */
package com.citrusengine.view.starlingview;

import starling.core.Starling;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.textures.TextureAtlas;
import flash.utils.Dictionary;

class AnimationSequence extends Sprite {

	var _textureAtlas : TextureAtlas;
	var _animations : Array<Dynamic>;
	var _mcSequences : Dictionary;
	var _previousAnimation : String;
	public function new(textureAtlas : TextureAtlas, animations : Array<Dynamic>, firstAnimation : String) {
		super();
		_textureAtlas = textureAtlas;
		_animations = animations;
		_mcSequences = new Dictionary();
		for(var animation : String in animations) {
			if(_textureAtlas.getTextures(animation).length == 0)  {
				throw new Error("One object doesn't have the " + animation + " animation in its TextureAtlas");
			}
			_mcSequences[animation] = new MovieClip(_textureAtlas.getTextures(animation));
		}

		addChild(_mcSequences[firstAnimation]);
		Starling.juggler.add(_mcSequences[firstAnimation]);
		_previousAnimation = firstAnimation;
	}

	/**
	 * Called by StarlingArt, managed the MC's animations.
	 * @param animation : the MC's animation
	 * @param fps : the MC's fps
	 * @param animLoop : true if the MC is a loop
	 */
	public function changeAnimation(animation : String, fps : Float, animLoop : Bool) : Void {
		if(!(_mcSequences[animation]))  {
			throw new Error("One object doesn't have the " + animation + " animation set up in its initial array");
			return;
		}
		removeChild(_mcSequences[_previousAnimation]);
		Starling.juggler.remove(_mcSequences[_previousAnimation]);
		addChild(_mcSequences[animation]);
		Starling.juggler.add(_mcSequences[animation]);
		_mcSequences[animation].fps = fps;
		_mcSequences[animation].loop = animLoop;
		_previousAnimation = animation;
	}

	public function destroy() : Void {
		removeChild(_mcSequences[_previousAnimation]);
		Starling.juggler.remove(_mcSequences[_previousAnimation]);
		for(var animation : String in _animations)_mcSequences[animation].dispose();
		_textureAtlas.dispose();
		_mcSequences = null;
	}

}

