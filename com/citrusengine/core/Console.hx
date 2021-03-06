/**
 * You can use the console to perform any type of command at your game's runtime. Press the key that opens it, then type a
 * command into the console, then press enter. If your command is recognized, the command's handler function will fire.
 * 
 * <p>You can create your own console commands by using the <code>addCommand</code> method.</p>
 * 
 * <p>When the console is open, it does not disable game input. You can manually toggle game input by listening for
 * the <code>onShowConsole</code> and <code>onHideConsole</code> Signals.</p>
 * 
 * <p>When the console is open, you can press the up key to step backwards through your executed command history, 
 * even after you've closed your SWF. Pressing the down key will step forward through your history.
 * Use this to quickly access commonly executed commands.</p>
 * 
 * <p>Each command follows this pattern: <code>commandName param1 param2 param3...</code>. First, you call the 
 * command name that you want to execute, then you pass any parameters into the command. For instance, you can
 * set the jumpHeight property on a Hero object using the following command: "set myHero jumpHeight 20". That
 * command finds an object named "myHero" and sets its jumpHeight property to 20.</p>
 * 
 * <p>Make sure and see the <code>addCommand</code> definition to learn how to add your own console commands.</p>
 */

//youhou 
package com.citrusengine.core;

import nme.display.Sprite;
import nme.events.Event;
import nme.events.FocusEvent;
import nme.events.KeyboardEvent;
import nme.net.SharedObject;
import nme.text.TextField;
import nme.text.TextFieldType;
import nme.text.TextFormat;
import nme.ui.Keyboard;
import com.citrusengine.utils.ObjectHash;
//import nme.utils.Dictionary;
//PORTODO signals
//import org.osflash.signals.Signal;
import hxs.Signal;


//PORTODO temporary tYpedef
typedef ArgumentError=Dynamic;
	


class Console extends Sprite {
	public var onShowConsole(getOnShowConsole, never) : Signal;
	public var onHideConsole(getOnHideConsole, never) : Signal;
	public var enabled(getEnabled, setEnabled) : Bool;

	public var openKey : Int;
	var _inputField : TextField;
	var _openKey : Int;
	var _executeKey : Int;
	var _prevHistoryKey : Int;
	var _nextHistoryKey : Int;
	var _commandHistory : Array<Dynamic>;
	var _historyMax : Float;
	var _showing : Bool;
	var _currHistoryIndex : Int;
	var _numCommandsInHistory : Int;

	//PORTODO Dictionary stuff
	//could be simpleHash
	var _commandDelegates : ObjectHash<Dynamic>;
	var _shared : SharedObject;
	var _enabled : Bool;
	//events
	var _onShowConsole : Signal;
	var _onHideConsole : Signal;
	/**
	 * Creates the instance of the console. This is a display object, so it is also added to the stage. 
	 */
	public function new(openKey : Int = 9) {
		super();
		openKey = 9;
		_enabled = true;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		_shared = SharedObject.getLocal("history");
		this.openKey = openKey;
		_executeKey = nme.ui.Keyboard.ENTER;
		_prevHistoryKey = nme.ui.Keyboard.UP;
		_nextHistoryKey = nme.ui.Keyboard.DOWN;
		_historyMax = 25;
		_showing = false;
		_currHistoryIndex = 0;
		_numCommandsInHistory = 0;
		if(_shared.data.history!=null)  {
			_commandHistory = cast(_shared.data.history, Array<Dynamic>) ;
			_numCommandsInHistory = _commandHistory.length;
		}

		else  {
			_commandHistory = new Array<Dynamic>();
			_shared.data.history = _commandHistory;
		}

		_commandDelegates = new ObjectHash<Dynamic>();
		_inputField = cast(addChild(new TextField()), TextField) ;
		_inputField.type = TextFieldType.INPUT;
		_inputField.addEventListener(FocusEvent.FOCUS_OUT, onConsoleFocusOut);
		_inputField.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF, false, false, false);
		visible = false;
		_onShowConsole = new Signal();
		_onHideConsole = new Signal();
	}

	/**
	 * Gets dispatched when the console is shown. Handler accepts 0 params.
	 */
	public function getOnShowConsole() : Signal {
		return _onShowConsole;
	}

	/**
	 * Gets dispatched when the console is hidden. Handler accepts 0 params.
	 */
	public function getOnHideConsole() : Signal {
		return _onHideConsole;
	}

	/**
	 * Determines whether the console can be used. Set this property to false before releasing your final game. 
	 */
	public function getEnabled() : Bool {
		return _enabled;
	}

	public function setEnabled(value : Bool) : Bool {
		if(_enabled == value) return value;
		_enabled = value;
		if(_enabled)  {
			stage.addEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
		}

		else  {
			stage.removeEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
			hideConsole();
		}

		return value;
	}

	/**
	 * Can be called to clear the command history. 
	 */
	public function clearStoredHistory() : Void {
		_shared.clear();
	}

	/**
	 * Adds a command to the console. Use this method to create your own commands. The <code>name</code> parameter
	 * is the word that you must type into the console to fire the command handler. The <code>func</code> parameter
	 * is the function that will fire when the console command is executed.
	 * 
	 * <p>Your command handler should accept the parameters that are expected to be passed into the command. All
	 * of them should be typed as a String. As an example, this is a valid handler definition for the "set" command.</p>
	 * 
	 * <p><code>private function handleSetPropertyCommand(objectName:String, propertyName:String, propertyValue:String):void</code></p>
	 * 
	 * <p>You can then create logic for your command using the arguments.</p>
	 *  
	 * @param name The word you want to use to execute your command in the console.
	 * @param func The handler function that will get called when the command is executed. This function should accept the commands parameters as arguments.
	 * 
	 */
	 //PORTODO get Type of function ?
	public function addCommand(name : String, func :Dynamic /* Function*/) : Void {
		//PORTODO dictionary
		_commandDelegates.set(name,func);
		//_commandDelegates[name] = func;
	}

	public function addCommandToHistory(command : String) : Void {
		var commandIndex : Int = Lambda.indexOf(_commandHistory,command);
		if(commandIndex != -1)  {
			_commandHistory.splice(commandIndex, 1);
			_numCommandsInHistory--;
		}
		_commandHistory.push(command);
		_numCommandsInHistory++;
		if(_commandHistory.length > _historyMax)  {
			_commandHistory.shift();
			_numCommandsInHistory--;
		}
		_shared.flush();
	}

	public function getPreviousHistoryCommand() : String {
		if(_currHistoryIndex > 0) _currHistoryIndex--;
		return getCurrentCommand();
	}

	public function getNextHistoryCommand() : String {
		if(_currHistoryIndex < _numCommandsInHistory) _currHistoryIndex++;
		return getCurrentCommand();
	}

	public function getCurrentCommand() : String {
		var command : String = _commandHistory[_currHistoryIndex];
		if(command==null)  {
			return "";
		}
		return command;
	}

	public function toggleConsole() : Void {
		if(_showing) hideConsole()
		else showConsole();
	}

	public function showConsole() : Void {
		if(!_showing)  {
			_showing = true;
			visible = true;
			stage.focus = _inputField;
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPressInConsole);
			_currHistoryIndex = _numCommandsInHistory;
			_onShowConsole.dispatch();
		}
	}

	public function hideConsole() : Void {
		if(_showing)  {
			_showing = false;
			visible = false;
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPressInConsole);
			_onHideConsole.dispatch();
		}
	}

	public function clearConsole() : Void {
		_inputField.text = "";
	}

	function onAddedToStage(event : Event) : Void {
		graphics.beginFill(0x000000, .8);
		graphics.drawRect(0, 0, this.stage.stageWidth, 30);
		graphics.endFill();
		_inputField.width = this.stage.stageWidth;
		_inputField.y = 4;
		_inputField.x = 4;
		this.stage.addEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
	}

	function onConsoleFocusOut(event : FocusEvent) : Void {
		hideConsole();
	}

	function onToggleKeyPress(event : KeyboardEvent) : Void {
		if(cast(event.keyCode,Int) == openKey)  {
			toggleConsole();
		}
	}

	function onKeyPressInConsole(event : KeyboardEvent) : Void {
		if(cast (event.keyCode,Int) == _executeKey)  {
			if(_inputField.text == "" || _inputField.text == " ") return ;
			addCommandToHistory(_inputField.text);
			var args : Array<Dynamic> = _inputField.text.split(" ");
			var command : String = args.shift();
			clearConsole();
			hideConsole();
			//PORTODO Dictionary
			var func = _commandDelegates.get(command);
			if(func != null)  {
				try {

					//PORTODO callmethod?
					func.apply(this, args);
				}
				catch(e : ArgumentError) {
					if(e.errorID == 1063) //Argument count mismatch on [some function]. Expected [x], got [y]

					 {
						trace(e.message);

						//PORTODO lastIndexOf?
						var expected : Int = Std.parseInt(e.message.slice(e.message.indexOf("Expected ") + 9, e.message.lastIndexOf(","))) 
						/* WARNING check type */;
						var lessArgs : Array<Dynamic> = args.slice(0, expected);
						//PORTODO callmethod?
						func.apply(this, lessArgs);
					}

				}

			}
		}

		else if(cast (event.keyCode,Int) == _prevHistoryKey)  {
			_inputField.text = getPreviousHistoryCommand();
			event.preventDefault();
			_inputField.setSelection(_inputField.text.length, _inputField.text.length);
		}

		else if(cast (event.keyCode,Int) == _nextHistoryKey)  {
			_inputField.text = getNextHistoryCommand();
			event.preventDefault();
			_inputField.setSelection(_inputField.text.length, _inputField.text.length);
		}
	}

}

