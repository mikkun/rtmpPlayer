////////////////////////////////////////////////////////////////////////////////
//
//  Player.hx
//  Copyright 2013 KUSANAGI Mitsuhisa
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package rtmpPlayer;

import flash.Lib;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class Player extends Sprite
{
	private static inline var BUFFER_TIME:Float = 5.0;

	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _source:String;
	private var _server:String;
	private var _netConnection:NetConnection;
	private var _video:Video;
	private var _videoAspectRatio:Float;
	private var _videoStopped:Bool;
	private var _metaDataReceived:Bool;
	private var _aspectRatio:Float;
	private var _position:Float;
	private var _duration:Float;
	private var _maskSprite:Sprite;

	public function new(source:String, ?server:String = null)
	{
		super();

		_stage = Lib.current.stage;
		_movieClip = Lib.current;

		_source = source;
		_server = (server != null && server != "") ? server : null;

		_netConnection = new NetConnection();
		_netConnection.addEventListener(
			NetStatusEvent.NET_STATUS, netStatusHandler);
		_netConnection.client = this;

		_video = new Video(_stage.stageWidth, _stage.stageHeight);
		addChild(_video);
		_videoAspectRatio = _stage.stageWidth / _stage.stageHeight;

		_videoStopped = true;
		_metaDataReceived = false;
		_aspectRatio = _videoAspectRatio;
		_position = 0.0;
		_duration = 0.0;

		_maskSprite = new Sprite();
		addChild(_maskSprite);

		_movieClip.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		_stage.addEventListener(Event.RESIZE, resizeHandler);
	}

	private var netStream:NetStream;

	public function getPosition():Float
	{
		return _position;
	}

	public function getDuration():Float
	{
		return _duration;
	}

	public function isVideoStopped():Bool
	{
		return _videoStopped;
	}

	public function play():Void
	{
		_videoStopped = false;
		_netConnection.connect(_server);
	}

	public function pause():Void
	{
		netStream.pause();
	}

	public function resume():Void
	{
		_videoStopped = false;
		netStream.resume();
	}

	public function stop():Void
	{
		_videoStopped = true;
		netStream.pause();
		netStream.seek(0.0);
	}

	public function seek(offset:Float):Void
	{
		_videoStopped = false;
		netStream.seek(offset);
	}

	public function controlVolume(volume:Float):Void
	{
		if (volume < 0.0)
			volume = 0.0;
		else if (volume > 1.0)
			volume = 1.0;

		netStream.soundTransform = new SoundTransform(volume);
	}

	public function changeAspectRatio(?aspectRatioString:String = null):Void
	{
		switch (aspectRatioString)
		{
			case "4:3":
			{
				_aspectRatio = 4 / 3;
			}

			case "16:9":
			{
				_aspectRatio = 16 / 9;
			}

			default:
			{
				_aspectRatio = _videoAspectRatio;
			}
		}

		resize();
	}

	private function resize():Void
	{
		if (_stage.stageWidth / _stage.stageHeight > 4 / 3)
		{
			_video.width = _stage.stageHeight * _aspectRatio;
			_video.height = _stage.stageHeight;
			_video.x = (_stage.stageWidth - _video.width) / 2;
			_video.y = 0;
		}
		else
		{
			_video.width = _stage.stageWidth;
			_video.height = _stage.stageWidth / _aspectRatio;
			_video.x = 0;
			_video.y = (_stage.stageHeight - _video.height) / 2;
		}

		_maskSprite.graphics.clear();
		_maskSprite.graphics.lineStyle();
		_maskSprite.graphics.beginFill(0x000000, 0.0);
		_maskSprite.graphics.drawRect(
			_video.x, _video.y, _video.width, _video.height);
		_maskSprite.graphics.endFill();
	}

	@:keep public function onCuePoint(info:Dynamic):Void
	{
		// To prevent an asyncError event...
	}

	@:keep public function onMetaData(info:Dynamic):Void
	{
		if (_metaDataReceived)
			return;

		_metaDataReceived = true;

		if (info.width > 0 && info.height > 0)
			_videoAspectRatio = info.width / info.height;
		else
			_videoAspectRatio = _stage.stageWidth / _stage.stageHeight;

		_aspectRatio = _videoAspectRatio;
		_duration = info.duration != null ? info.duration : 0.0;

		resize();
	}

	@:keep public function onPlayStatus(info:Dynamic):Void
	{
		switch (info.code)
		{
			case "NetStream.Play.Complete":
			{
				if (_server != null)
					stop();
			}
		}
	}

	private function netStatusHandler(event:NetStatusEvent):Void
	{
		switch (event.info.code)
		{
			case "NetConnection.Connect.Success":
			{
				netStream = new NetStream(_netConnection);
				netStream.addEventListener(
					NetStatusEvent.NET_STATUS, netStatusHandler);
				netStream.client = this;
				netStream.bufferTime = BUFFER_TIME;

				_video.attachNetStream(netStream);
				netStream.play(_source);
			}

			case "NetStream.Play.Stop":
			{
				if (_server == null)
					stop();
			}
		}
	}

	private function enterFrameHandler(event:Event):Void
	{
		if (_duration <= 0.0)
			return;

		_position = !_videoStopped ? netStream.time : 0.0;
	}

	private function resizeHandler(event:Event):Void
	{
		resize();
	}
}
