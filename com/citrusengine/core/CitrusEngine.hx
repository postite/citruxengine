/**
 * CitrusEngine is the top-most class in the library. When you start your project, you should make your
 * document class extend this class.
 * 
 * <p>CitrusEngine is a singleton so that you can grab a reference to it anywhere, anytime. Don't abuse this power,
 * but use it wisely. With it, you can quickly grab a reference to the manager classes such as current State, Input and SoundManager.</p>
 * 
 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://starling-framework.org/">Starling Framework</a></p>
 */
/**
 * RootClass is the root of Starling, it is never destroyed and only accessed through <code>_starling.stage</code>.
 * It may display a Stats class instance which contains Memory & FPS informations.
 */
package com.citrusengine.core;

//import starling.core.Starling;
import com.citrusengine.utils.AGameData;
import com.citrusengine.utils.LevelManager;
import nme.display.MovieClip;
import nme.display.StageScaleMode;
import nme.display.StageAlign;
import nme.events.Event;
import nme.display.Sprite;
import nme.Lib;
//import starling.display.Sprite;
//import starling.extensions.utils.Stats;
import com.citrusengine.core.CitrusEngine;

class CitrusEngine extends MovieClip {
	public var levelManager(getLevelManager, setLevelManager) : LevelManager;
	public var state(getState, setState) : IState;
	public var playing(getPlaying, setPlaying) : Bool;
	public var gameData(getGameData, setGameData) : AGameData;
	public var input(getInput, never) : Input;
	public var sound(getSound, never) : SoundManager;
	public var console(getConsole, never) : Console;

	static public var VERSION : String = "haxe version 3.00.00 BETA 1";
	//static public var starlingDebugMode : Bool;
	static var _instance : CitrusEngine;
	//var _starling : Starling;
	var _levelManager : LevelManager;
	var _state : IState;
	var _newState : IState;
	var _stateDisplayIndex : Int;
	var _startTime : Float;
	var _gameTime : Float;
	var _playing : Bool;
	var _gameData : AGameData;
	var _input : Input;
	var _sound : SoundManager;
	var _console : Console;
	static public function getInstance() : CitrusEngine {
		return _instance;
	}

	/**
	 * Flash's innards should be calling this, because you should be extending your document class with it.
	 */
	public function new() {
		super();
		_stateDisplayIndex = 0;
		_playing = true;
		_instance = this;
		//Set up console
		_console = new Console(9);
		//Opens with tab key by default
		_console.onShowConsole.add(handleShowConsole);
		_console.addCommand("set", handleConsoleSetCommand);
		addChild(_console);
		//timekeeping
		_startTime = Date.now().getTime();
		_gameTime = _startTime;
		//Set up input
		_input = new Input();
		//Set up sound manager
		_sound = SoundManager.getInstance();
		addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
	}

	/**
	 * You should call this function to create your Starling view. The RootClass is internal, it is never used elsewhere. 
	 * StarlingState is added on the starling stage : <code>_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);</code>
	 * @param debugMode : if true, display a Stats class instance.
	 * @param antiAliasing : The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 1 is totally acceptable.
	 */
	// public function setUpStarling(debugMode : Bool = false, antiAliasing : UInt = 1) : Void {
	// 	starlingDebugMode = debugMode;
	// 	_starling = new Starling(RootClass, stage);
	// 	_starling.antiAliasing = antiAliasing;
	// 	_starling.start();
	// }

	/**
	 * Return the level manager, use it if you want. Take a look on its class for more information.
	 */
	public function getLevelManager() : LevelManager {
		return _levelManager;
	}

	/**
	 * You may use the Citrus Engine's level manager if you have several levels. Take a look on its class for more information.
	 */
	public function setLevelManager(value : LevelManager) : LevelManager {
		_levelManager = value;
		return value;
	}

	/**
	 * A reference to the active game state. Acutally, that's not entirely true. If you've recently changed states and a tick
	 * hasn't occured yet, then this will reference your new state; this is because actual state-changes only happen pre-tick.
	 * That way you don't end up changing states in the middle of a state's tick, effectively fucking stuff up. 
	 */
	public function getState() : IState {
		if(_newState!=null) return _newState
		else  {
			return _state;
		}

	}

	/**
	 * We only ACTUALLY change states on enter frame so that we don't risk changing states in the middle of a state update.
	 * However, if you use the state getter, it will grab the new one for you, so everything should work out just fine.
	 */
	public function setState(value : IState) : IState {
		_newState = value;
		return value;
	}

	/**
	 * Runs and pauses the game loop. Assign this to false to pause the game and stop the
	 * <code>update()</code> methods from being called. 
	 */
	public function getPlaying() : Bool {
		return _playing;
	}

	public function setPlaying(value : Bool) : Bool {
		_playing = value;
		if(_playing) _gameTime = Date.now().getTime();
		
		return value;
	}

	/**
	 * A reference to the Abstract GameData instance. Use it if you want.
	 * It's a dynamic class, so you don't have problem to access informations in its extended class.
	 */
	public function getGameData() : AGameData {
		return _gameData;
	}

	/**
	 * You may use a class to store your game's data, there is already an abstract class for that :
	 */
	public function setGameData(gameData : AGameData) : AGameData {
		_gameData = gameData;
		return gameData;
	}

	/**
	 * You can get to my Input manager object from this reference so that you can see which keys are pressed and stuff. 
	 */
	public function getInput() : Input {
		return _input;
	}

	/**
	 * A reference to the SoundManager instance. Use it if you want.
	 */
	public function getSound() : SoundManager {
		return _sound;
	}

	/**
	 * A reference to the console, so that you can add your own console commands. See the class documentation for more info.
	 * The console can be opened by pressing the tilde key (It looks like this: "~" right below the escape key).
	 * There is one console command built-in by default, but you can add more by using the addCommand() method.
	 * 
	 * <p>To try it out, try using the "set" command to change a property on a CitrusObject. You can toggle Box2D's
	 * debug draw visibility like this "set Box2D visible false". If your Box2D CitrusObject instance is not named
	 * "Box2D", use the name you gave it instead.</p>
	 */
	public function getConsole() : Console {
		return _console;
	}

	/**
	 * Set up things that need the stage access.
	 */
	function handleAddedToStage(e : Event) : Void {
		removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.addEventListener(Event.DEACTIVATE, handleStageDeactivated);
		_input.initialize();
	}

	/**
	 * This is the game loop. It switches states if necessary, then calls update on the current state.
	 */
	//TODO The CE updates use the timeDelta to keep consistent speed during slow framerates. However, Box2D becomes unstable when changing timestep. Why?
	function handleEnterFrame(e : Event) : Void {
		//Change states if it has been requested
		if(_newState!=null)  {
			if(_state!=null)  {
				_state.destroy();
				//if(_starling)  {
					// _starling.stage.removeChild(try cast(_state, StarlingState) catch(e) null);
					// _starling.nativeStage.removeChildAt(1);
					// Remove Box2D view
				

				//}else  {
					removeChild(cast(_state, State));
				//}

			}
			_state = _newState;
			_newState = null;
			//if(_starling)  {
				// _starling.stage.addChildAt(try cast(_state, StarlingState) catch(e) null, _stateDisplayIndex);
			//}

			//}else  {
				addChildAt(cast(_state, State), _stateDisplayIndex);
			//}

			_state.initialize();
		}
		if(_state!=null && _playing)  {
			var nowTime : Float = Date.now().getTime();
			var timeSinceLastFrame : Float = nowTime - _gameTime;
			var timeDelta : Float = timeSinceLastFrame * 0.001;
			_gameTime = nowTime;
			_state.update(timeDelta);
		}
	}

	function handleStageDeactivated(e : Event) : Void {
		if(_playing)  {
			//if(_starling) _starling.stop();
			playing = false;
			stage.addEventListener(Event.ACTIVATE, handleStageActivated);
		}
	}

	function handleStageActivated(e : Event) : Void {
		//if(_starling) _starling.start();
		playing = true;
		stage.removeEventListener(Event.ACTIVATE, handleStageActivated);
	}

	function handleShowConsole() : Void {
		if(_input.enabled)  {
			_input.enabled = false;
			_console.onHideConsole.addOnce(handleHideConsole);
		}
	}

	function handleHideConsole() : Void {
		_input.enabled = true;
	}

	function handleConsoleSetCommand(objectName : String, paramName : String, paramValue : String) : Void {
		var object : CitrusObject = _state.getObjectByName(objectName);
		if(object==null)  {
			trace("Warning: There is no object named " + objectName);
			return;
		}
		var value : Dynamic;
		if(paramValue == "true") value = true
		else if(paramValue == "false") value = false
		else value = paramValue;
		//portodo hasOwnproperty issue
		if(untyped object.hasOwnProperty(paramName))
		Reflect.setField(object,paramName,value);
		// object[paramName] = value
		else trace("Warning: " + objectName + " has no parameter named " + paramName + ".");
	}

}

class RootClass extends Sprite {

	public function new() {
		//if(CitrusEngine.starlingDebugMode) addChild(new Stats());
		super();
	}

}

