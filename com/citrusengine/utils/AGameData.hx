/**
 * This is an (optional) abstract class to store your game's data such as lives, score, levels...
 * You should extend this class & instantiate it into your main class using the gameData variable.
 * You can dispatch a signal, dataChanged, if you update one of your data.
 * For more information, watch the example below. 
 */
package com.citrusengine.utils;

import hxs.Signal2;
/// has to move to hsl or hxs 
//import org.osflash.signals.Signal;

class AGameData {
	public var lives(getLives, setLives) : Int;
	public var score(getScore, setScore) : Int;
	public var timeleft(getTimeleft, setTimeleft) : Int;

	public var dataChanged : Signal2<String,Int>;
	var _lives : Int;
	var _score : Int;
	var _timeleft : Int;
	var _levels : Array<Dynamic>;
	public function new() {
		_lives = 3;
		_score = 0;
		_timeleft = 300;
		dataChanged = new Signal2<String,Int>();
	}

	public function getLives() : Int {
		return _lives;
	}

	public function setLives(lives : Int) : Int {
		_lives = lives;
		dataChanged.dispatch("lives", _lives);
		return lives;
	}

	public function getScore() : Int {
		return _score;
	}

	public function setScore(score : Int) : Int {
		_score = score;
		dataChanged.dispatch("score", _score);
		return score;
	}

	public function getTimeleft() : Int {
		return _timeleft;
	}

	public function setTimeleft(timeleft : Int) : Int {
		_timeleft = timeleft;
		dataChanged.dispatch("timeleft", _timeleft);
		return timeleft;
	}

	public function destroy() : Void {
		dataChanged.removeAll();
	}

}

