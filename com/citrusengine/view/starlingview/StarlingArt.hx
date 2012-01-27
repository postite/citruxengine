/**
 * This is the class that all art objects use for the StarlingView state view. If you are using the StarlingView (as opposed to the blitting view, for instance),
 * then all your graphics will be an instance of this class. There are 2 ways to manage MovieClip :
 * - specify a "object.swf" in the view property of your object's creation.
 * - add an AnimationSequence to your view property of your object's creation, see the AnimationSequence for more informations about it.
 * The AnimationSequence is more optimized than the .swf which creates textures "on the fly" thanks to the DynamicAtlas class.
 * 
 * This class does the following things:
 * 
 * 1) Creates the appropriate graphic depending on your CitrusObject's view property (loader, sprite, or bitmap), and loads it if it is a non-embedded graphic.
 * 2) Aligns the graphic with the appropriate registration (topLeft or center).
 * 3) Calls the MovieClip's appropriate frame label based on the CitrusObject's animation property.
 * 4) Updates the graphic's properties to be in-synch with the CitrusObject's properties once per frame.
 * 
 * These objects will be created by the Citrus Engine's StarlingView, so you should never make them yourself. When you use state.getArt() to gain access to your game's graphics
 * (for adding click events, for instance), you will get an instance of this object. It extends Sprite, so you can do all the expected stuff with it, 
 * such as add click listeners, change the alpha, etc.
 **/
package com.citrusengine.view.starlingview;

import box2das.dynamics.B2DebugDraw;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.extensions.textureatlas.DynamicAtlas;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Deg2rad;
import com.citrusengine.view.ISpriteView;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.GetDefinitionByName;

class StarlingArt extends Sprite {
	static public var loopAnimation(getLoopAnimation, never) : Dictionary;
	public var registration(getRegistration, setRegistration) : String;
	public var view(getView, setView) : Dynamic;
	public var animation(getAnimation, setAnimation) : String;
	public var group(getGroup, setGroup) : Int;
	public var fpsMC(getFpsMC, setFpsMC) : UInt;
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
	// properties :
	// determines animations playing in loop. You can add one in your state class : StarlingArt.setLoopAnimations(["walk", "climb"]);
	static var _loopAnimation : Dictionary = new Dictionary();
	var _citrusObject : ISpriteView;
	var _registration : String;
	var _view : Dynamic;
	var _animation : String;
	var _group : Int;
	// fps for this MovieClip, it can be different between objects, to set it : view.getArt(myHero).fpsMC = 25;
	var _fpsMC : UInt;
	var _texture : Texture;
	var _textureAtlas : TextureAtlas;
	public function new(object : ISpriteView) {
		_fpsMC = 30;
		_citrusObject = object;
		if(_loopAnimation["walk"] != true)  {
			_loopAnimation["walk"] = true;
		}
	}

	public function destroy() : Void {
		if(Std.is(content, MovieClip))  {
			Starling.juggler.remove(try cast(content, MovieClip) catch(e) null);
			_textureAtlas.dispose();
			content.dispose();
		}

		else if(Std.is(content, AnimationSequence))  {
			(try cast(content, AnimationSequence) catch(e) null).destroy();
			content.dispose();
		}

		else if(Std.is(content, Image))  {
			_texture.dispose();
			content.dispose();
		}
	}

	/**
	 * Add a loop animation to the Dictionnary.
	 * @param tab an array with all the loop animation names.
	 */
	static public function setLoopAnimations(tab : Array<Dynamic>) : Void {
		for(var animation : String in tab) {
			_loopAnimation[animation] = true;
		}

	}

	static public function getLoopAnimation() : Dictionary {
		return _loopAnimation;
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
				// view property is a class reference
				content = new citrusobject.View();
				addChild(content);
			}

			else if(Std.is(_view, DisplayObject))  {
				// view property is a Display Object reference
				content = _view;
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
		if(_animation != null && _animation != "")  {
			var animLoop : Bool = _loopAnimation[_animation];
			if(Std.is(content, MovieClip)) (try cast(content, MovieClip) catch(e) null).changeTextures(_textureAtlas.getTextures(_animation), _fpsMC, animLoop);
			if(Std.is(content, AnimationSequence)) (try cast(content, AnimationSequence) catch(e) null).changeAnimation(_animation, _fpsMC, animLoop);
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

	public function getFpsMC() : UInt {
		return _fpsMC;
	}

	public function setFpsMC(fpsMC : UInt) : UInt {
		_fpsMC = fpsMC;
		return fpsMC;
	}

	public function getCitrusObject() : ISpriteView {
		return _citrusObject;
	}

	public function update(stateView : StarlingView) : Void {
		if(Std.is(content, Box2DDebugArt))  {
			// Box2D view is not on the Starling display list, but on the classical flash display list.
			// So we need to move its view here, not in the StarlingView.
			var box2dDebugArt : B2DebugDraw = (try cast(Starling.current.nativeStage.getChildAt(1), b2DebugDraw) catch(e) null);
			if(stateView.cameraTarget)  {
				var diffX : Float = (-stateView.cameraTarget.x + stateView.cameraOffset.x) - box2dDebugArt.x;
				var diffY : Float = (-stateView.cameraTarget.y + stateView.cameraOffset.y) - box2dDebugArt.y;
				var velocityX : Float = diffX * stateView.cameraEasing.x;
				var velocityY : Float = diffY * stateView.cameraEasing.y;
				box2dDebugArt.x += velocityX;
				box2dDebugArt.y += velocityY;
				// Constrain to camera bounds
				if(stateView.cameraBounds)  {
					if(-box2dDebugArt.x <= stateView.cameraBounds.left || stateView.cameraBounds.width < stateView.cameraLensWidth) box2dDebugArt.x = -stateView.cameraBounds.left
					else if(-box2dDebugArt.x + stateView.cameraLensWidth >= stateView.cameraBounds.right) box2dDebugArt.x = -stateView.cameraBounds.right + stateView.cameraLensWidth;
					if(-box2dDebugArt.y <= stateView.cameraBounds.top || stateView.cameraBounds.height < stateView.cameraLensHeight) box2dDebugArt.y = -stateView.cameraBounds.top
					else if(-box2dDebugArt.y + stateView.cameraLensHeight >= stateView.cameraBounds.bottom) box2dDebugArt.y = -stateView.cameraBounds.bottom + stateView.cameraLensHeight;
				}
			}
			box2dDebugArt.visible = _citrusObject.visible;
		}

		else  {
			// The position = object position + (camera position * inverse parallax)
			x = _citrusObject.x + (-stateView.viewRoot.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX;
			y = _citrusObject.y + (-stateView.viewRoot.y * (1 - _citrusObject.parallax)) + _citrusObject.offsetY;
			visible = _citrusObject.visible;
			rotation = deg2rad(_citrusObject.rotation);
			scaleX = (_citrusObject.inverted) ? -1 : 1;
			registration = _citrusObject.registration;
			view = _citrusObject.view;
			animation = _citrusObject.animation;
			group = _citrusObject.group;
		}

	}

	function handleContentLoaded(evt : Event) : Void {
		if(Std.is(evt.target.loader.content, flash.display.MovieClip))  {
			_textureAtlas = DynamicAtlas.fromMovieClipContainer(evt.target.loader.content, 1, 0, true, true);
			content = new MovieClip(_textureAtlas.getTextures(animation), _fpsMC);
			Starling.juggler.add(try cast(content, MovieClip) catch(e) null);
		}
		if(Std.is(evt.target.loader.content, Bitmap))  {
			_texture = Texture.fromBitmap(evt.target.loader.content);
			content = new Image(_texture);
		}
		addChild(content);
	}

	function handleContentIOError(evt : IOErrorEvent) : Void {
		throw new Error(evt.text);
	}

}

