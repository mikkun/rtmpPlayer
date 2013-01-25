////////////////////////////////////////////////////////////////////////////////
//
//  Poster.hx
//  Copyright 2013 KUSANAGI Mitsuhisa
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package rtmpPlayer;

import flash.Lib;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.net.URLRequest;

class Poster extends Sprite
{
	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _loader:Loader;

	public function new(poster:String)
	{
		super();

		_stage = Lib.current.stage;
		_movieClip = Lib.current;

		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(
			Event.COMPLETE, completeHandler);
		_loader.load(new URLRequest(poster));
	}

	private var posterWidth:Float;
	private var posterHeight:Float;

	private function resize():Void
	{
		this.width = _stage.stageWidth;
		this.height = _stage.stageWidth / (posterWidth / posterHeight);
		this.x = 0;
		this.y = (_stage.stageHeight - this.height) / 2;
	}

	private function completeHandler(event:Event):Void
	{
		posterWidth = _loader.contentLoaderInfo.width;
		posterHeight = _loader.contentLoaderInfo.height;

		addChild(_loader);

		_stage.addEventListener(Event.RESIZE, resizeHandler);
		resize();
	}

	private function resizeHandler(event:Event):Void
	{
		resize();
	}
}
