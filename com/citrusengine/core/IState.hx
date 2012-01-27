/**
 * Take a look on the 2 respective states to have some information on the functions.
 */
package com.citrusengine.core;

import com.citrusengine.view.CitrusView;

interface IState {
	var view(getView, never) : CitrusView;

	function destroy() : Void;
	function getView() : CitrusView;
	function initialize() : Void;
	function update(timeDelta : Float) : Void;
	function add(object : CitrusObject) : CitrusObject;
	function remove(object : CitrusObject) : Void;
	function getObjectByName(name : String) : CitrusObject;
	function getFirstObjectByType(type : Class<Dynamic>) : CitrusObject;
	function getObjectsByType(type : Class<Dynamic>) : Array<CitrusObject>;
}

