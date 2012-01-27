/**
 * This is the class that all art objects use for the SpriteView state view. If you are using the SpriteView (as opposed to the blitting view, for instance),
 * then all your graphics will be an instance of this class. This class does the following things:
 * 
 * 1) Creates the appropriate graphic depending on your CitrusObject's view property (loader, sprite, or bitmap), and loads it if it is a non-embedded graphic.
 * 2) Aligns the graphic with the appropriate registration (topLeft or center).
 * 3) Calls the MovieClip's appropriate frame label based on the CitrusObject's animation property.
 * 4) Updates the graphic's properties to be in-synch with the CitrusObject's properties once per frame.
 * 
 * These objects will be created by the Citrus Engine's SpriteView, so you should never make them yourself. When you use state.getArt() to gain access to your game's graphics
 * (for adding click events, for instance), you will get an instance of this object. It extends Sprite, so you can do all the expected stuff with it, 
 * such as add click listeners, change the alpha, etc.
 * 
 * 
 **/
package com.citrusengine.view.spriteview;

import com.citrusengine.view.ISpriteView;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.FrameLabel;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.GetDefinitionByName;

class SpriteArt extends Sprite {
	public var registration(getRegistration, setRegistration) : String;
	public var view(getView, setView) : Dynamic;
	public var animation(getAnimation, setAnimation) : String;
	public var group(getGroup, setGroup) : Int;
	public var citrusObject(getCitrusObject, never) : ISpriteView;

	/**
	 * The content property is the actual display object that your game object is using. For graphics that are loaded at runtime
	 * (not embedded), the content property will not be available immediately. You can listen to the COMPLETE event on the loader
	 * (or rather, the loader's contentLoaderInfo) if you need to know exactly when the graphic will be loaded.
	 */
	public var content : DisplayObject;
	/**
	 * For objects that are loaded at runtime, this is the object that loades them. Then, once they are loaded, the content
	 * property is assigned to loader.content.
	 */
	public var loader : Loader;
	var _citrusObject : ISpriteView;
	var _registration : String;
	var _view : Dynamic;
	var _animation : String;
	var _group : Int;
	public function new(object : ISpriteView) {
		_citrusObject = object;
	}

	public function getRegistration() : String {
		return _registration;
	}

	public function setRegistration(value : String) : String {
		if(_registration == value || !content) return;
		_registration = value;
		if(_registration == "topLeft")  {
			content.x = 0;
			content.y = 0;
		}

		else if(_registration == "center")  {
			content.x = -content.width / 2;
			content.y = -content.height / 2;
		}
		return value;
	}

	public function getView() : Dynamic {
		return _view;
	}

	public function setView(value : Dynamic) : Dynamic {
		if(_view == value) return;
		_view = value;
		if(_view)  {
			if(Std.is(_view, String))  {
				// view property is a path to an image?
				var classString : String = _view;
				var suffix : String = classString.substring(classString.length - 4).toLowerCase();
				if(suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg")  {
					loader = new Loader();
					addChild(loader);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
					loader.load(new URLRequest(classString));
				}

				else  {
					var artClass : Class<Dynamic> = Type.getClass(getDefinitionByName(classString));
					content = new ArtClass();
					addChild(content);
				}

			}

			else if(Std.is(_view, Class))  {
				//view property is a class reference
				content = new citrusobject.View();
				addChild(content);
			}

			else  {
				throw new Error("SpriteArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
				return;
			}

			if(content && content.hasOwnProperty("initialize")) content["initialize"](_citrusObject);
		}
		return value;
	}

	public function getAnimation() : String {
		return _animation;
	}

	public function setAnimation(value : String) : String {
		if(_animation == value) return;
		_animation = value;
		if(Std.is(content, MovieClip))  {
			var mc : MovieClip = try cast(content, MovieClip) catch(e) null;
			if(_animation != null && _animation != "" && hasAnimation(_animation)) mc.gotoAndStop(_animation);
		}
		return value;
	}

	public function getGroup() : Int {
		return _group;
	}

	public function setGroup(value : Int) : Int {
		_group = value;
		return value;
	}

	public function getCitrusObject() : ISpriteView {
		return _citrusObject;
	}

	public function update(stateView : SpriteView) : Void {
		//position = object position + (camera position * inverse parallax)
		x = _citrusObject.x + (-stateView.viewRoot.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX;
		y = _citrusObject.y + (-stateView.viewRoot.y * (1 - _citrusObject.parallax)) + _citrusObject.offsetY;
		rotation = _citrusObject.rotation;
		visible = _citrusObject.visible;
		scaleX = (_citrusObject.inverted) ? -1 : 1;
		registration = _citrusObject.registration;
		view = _citrusObject.view;
		animation = _citrusObject.animation;
		group = _citrusObject.group;
	}

	public function hasAnimation(animation : String) : Bool {
		for(var anim : FrameLabel in cast((content), MovieClip).currentLabels) {
			if(anim.name == animation) return true;
		}

		return false;
	}

	function handleContentLoaded(e : Event) : Void {
		content = e.target.loader.content;
		if(Std.is(content, Bitmap)) cast((content), Bitmap).smoothing = true;
	}

	function handleContentIOError(e : IOErrorEvent) : Void {
		throw new Error(e.text);
	}

}

