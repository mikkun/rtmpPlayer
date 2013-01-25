////////////////////////////////////////////////////////////////////////////////
//
//  Main.hx
//  Copyright 2013 KUSANAGI Mitsuhisa
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package rtmpPlayer;

import flash.Lib;
import flash.display.MovieClip;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import rtmpPlayer.Controls;
import rtmpPlayer.Player;
import rtmpPlayer.Poster;

class Main
{
	static var stage:Stage;
	static var movieClip:MovieClip;
	static var player:Player;
	static var poster:Poster;
	static var controls:Controls;

	public static function main():Void
	{
		stage = Lib.current.stage;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		movieClip = Lib.current;

		var parameters:Dynamic<String> = Lib.current.loaderInfo.parameters;

		player = new Player(parameters.source, parameters.server);
		movieClip.addChild(player);

		if (parameters.poster != null && parameters.poster != "")
		{
			poster = new Poster(parameters.poster);
			movieClip.addChild(poster);
		}

		controls = new Controls(player, poster);
		movieClip.addChild(controls);
	}
}
