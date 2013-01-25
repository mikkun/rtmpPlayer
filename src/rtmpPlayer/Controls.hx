////////////////////////////////////////////////////////////////////////////////
//
//  Controls.hx
//  Copyright 2013 KUSANAGI Mitsuhisa
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package rtmpPlayer;

import flash.Lib;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import com.bit101.components.HSlider;
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import com.bit101.components.Style;
import rtmpPlayer.Player;
import rtmpPlayer.Poster;

class Controls extends Sprite
{
	private static inline var STYLE:String = "dark";
	private static inline var EMBED_FONTS:Bool = false;
	private static inline var FONT_SIZE:Float = 11;

	private var _stage:Stage;
	private var _movieClip:MovieClip;
	private var _player:Player;
	private var _poster:Poster;
	private var _container:Sprite;
	private var _maskRectangle:Rectangle;
	private var _videoSeeking:Bool;
	private var _position:Float;
	private var _duration:Float;

	public function new(player:Player, ?poster:Poster = null)
	{
		super();

		_stage = Lib.current.stage;
		_movieClip = Lib.current;

		_player = player;
		_poster = poster;

		_container = new Sprite();
		addChild(_container);
		_container.graphics.lineStyle();
		_container.graphics.beginFill(0x000000, 0.5);
		_container.graphics.drawRect(0, 0, 315, 45);
		_container.graphics.endFill();
		_container.graphics.beginFill(0x000000, 1.0);
		_container.graphics.drawRect(0, 45, 315, 45);
		_container.graphics.endFill();

		_maskRectangle = new Rectangle(0, 0, 315, 90);

		_videoSeeking = false;
		_position = 0.0;
		_duration = 0.0;
		initializeComponents();

		_movieClip.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		_stage.addEventListener(Event.RESIZE, resizeHandler);
		resize();
	}

	private var togglePlayButton:PushButton;
	private var rewindButton:PushButton;
	private var toggleVolumeButton:PushButton;
	private var toggleAspectRatioButton:PushButton;
	private var toggleFullScreenButton:PushButton;
	private var positionLabel:Label;
	private var positionSlider:HSlider;
	private var durationLabel:Label;
	private var indicatorLabel:Label;

	private function initializeComponents():Void
	{
		com.bit101.components.Style.setStyle(STYLE);
		com.bit101.components.Style.embedFonts = EMBED_FONTS;
		com.bit101.components.Style.fontSize = FONT_SIZE;

		togglePlayButton = new PushButton(
			_container, 0, 45, "> PLAY", togglePlayButton_clickHandler);
		togglePlayButton.width = 75;
		togglePlayButton.height = 45;
		togglePlayButton.addEventListener(
			MouseEvent.ROLL_OVER, togglePlayButton_rollOverHandler);
		togglePlayButton.addEventListener(
			MouseEvent.ROLL_OUT, togglePlayButton_rollOutHandler);

		rewindButton = new PushButton(
			_container, 75, 45, "|< REWIND", rewindButton_clickHandler);
		rewindButton.width = 75;
		rewindButton.height = 45;
		rewindButton.addEventListener(
			MouseEvent.ROLL_OVER, rewindButton_rollOverHandler);
		rewindButton.addEventListener(
			MouseEvent.ROLL_OUT, rewindButton_rollOutHandler);

		toggleVolumeButton = new PushButton(
			_container, 150, 45, "||||| 100%", toggleVolumeButton_clickHandler);
		toggleVolumeButton.width = 75;
		toggleVolumeButton.height = 45;
		toggleVolumeButton.addEventListener(
			MouseEvent.ROLL_OVER, toggleVolumeButton_rollOverHandler);
		toggleVolumeButton.addEventListener(
			MouseEvent.ROLL_OUT, toggleVolumeButton_rollOutHandler);

		toggleAspectRatioButton = new PushButton(
			_container, 225, 45, "--:--", toggleAspectRatioButton_clickHandler);
		toggleAspectRatioButton.width = 45;
		toggleAspectRatioButton.height = 45;
		toggleAspectRatioButton.addEventListener(
			MouseEvent.ROLL_OVER, toggleAspectRatioButton_rollOverHandler);
		toggleAspectRatioButton.addEventListener(
			MouseEvent.ROLL_OUT, toggleAspectRatioButton_rollOutHandler);

		toggleFullScreenButton = new PushButton(
			_container, 270, 45, "[< >]", toggleFullScreenButton_clickHandler);
		toggleFullScreenButton.width = 45;
		toggleFullScreenButton.height = 45;
		toggleFullScreenButton.addEventListener(
			MouseEvent.ROLL_OVER, toggleFullScreenButton_rollOverHandler);
		toggleFullScreenButton.addEventListener(
			MouseEvent.ROLL_OUT, toggleFullScreenButton_rollOutHandler);

		positionLabel = new Label(_container, 0, 15, "00:00:00");
		positionLabel.width = 60;
		positionLabel.height = 15;
		positionLabel.align = "center";

		positionSlider = new HSlider(
			_container, 60, 15, positionSlider_changeHandler);
		positionSlider.width = 195;
		positionSlider.height = 15;
		positionSlider.minimum = 0.0;
		positionSlider.maximum = 1.0;
		positionSlider.addEventListener(
			MouseEvent.MOUSE_DOWN, positionSlider_mouseDownHandler);
		positionSlider.addEventListener(
			MouseEvent.MOUSE_UP, positionSlider_mouseUpHandler);

		durationLabel = new Label(_container, 255, 15, "00:00:00");
		durationLabel.width = 60;
		durationLabel.height = 15;
		durationLabel.align = "center";

		indicatorLabel = new Label(_container, 0, 30, "");
		indicatorLabel.width = 315;
		indicatorLabel.height = 15;
		indicatorLabel.align = "center";
	}

	private function resize():Void
	{
		_container.x = (_stage.stageWidth - 315) / 2;
		_container.y = _stage.stageHeight - 90;

		_maskRectangle.x = _container.x;
		_maskRectangle.y = _container.y;
	}

	private function formatTime(seconds:Float):String
	{
		var hour:String = Std.string(Std.int(seconds / 3600));
		var minute:String = Std.string(Std.int((seconds % 3600) / 60));
		var second:String = Std.string(Std.int((seconds % 3600) % 60));

		hour = hour.length > 2 ? hour.substr(-2, 2) : hour;
		hour = hour.length == 1 ? "0" + hour : hour;
		minute = minute.length == 1 ? "0" + minute : minute;
		second = second.length == 1 ? "0" + second : second;

		return hour + ":" + minute + ":" + second;
	}

	private function enterFrameHandler(event:Event):Void
	{
		_position = _player.getPosition();
		_duration = _player.getDuration();

		if (_player.isVideoStopped())
		{
			if (_poster != null)
				_poster.visible = true;

			_container.visible = true;

			if (togglePlayButton.label != "> PLAY")
			{
				_position = 0.0;
				togglePlayButton.label = "> RESUME";
			}
		}
		else
		{
			if (_poster != null)
				_poster.visible = false;

			if (_maskRectangle.contains(mouseX, mouseY))
				_container.visible = true;
			else
				_container.visible = false;
		}

		if (_duration <= 0.0)
			return;

		if (!_videoSeeking)
			positionSlider.value = _position / _duration;

		positionLabel.text = formatTime(_position);
		durationLabel.text = formatTime(_duration);

		if (indicatorLabel.text == "NOW LOADING...")
			indicatorLabel.text = "";
	}

	private function resizeHandler(event:Event):Void
	{
		resize();

		if (_stage.displayState == StageDisplayState.NORMAL)
			toggleFullScreenButton.label = "[< >]";
	}

	private function togglePlayButton_clickHandler(event:MouseEvent):Void
	{
		_videoSeeking = false;

		if (indicatorLabel.text != "NOW LOADING...")
			indicatorLabel.text = "";

		switch (togglePlayButton.label)
		{
			case "> PLAY":
			{
				_player.play();
				togglePlayButton.label = "|| PAUSE";
				indicatorLabel.text = "NOW LOADING...";
			}

			case "|| PAUSE":
			{
				_player.pause();
				togglePlayButton.label = "> RESUME";
			}

			case "> RESUME":
			{
				_player.resume();
				togglePlayButton.label = "|| PAUSE";
			}
		}
	}

	private function togglePlayButton_rollOverHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		switch (togglePlayButton.label)
		{
			case "> PLAY":
			{
				indicatorLabel.text = "PLAY";
			}

			case "|| PAUSE":
			{
				indicatorLabel.text = "PAUSE";
			}

			case "> RESUME":
			{
				indicatorLabel.text = "RESUME";
			}
		}
	}

	private function togglePlayButton_rollOutHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "";
	}

	private function rewindButton_clickHandler(event:MouseEvent):Void
	{
		_videoSeeking = false;

		if (indicatorLabel.text != "NOW LOADING...")
			indicatorLabel.text = "";

		if (positionLabel.text == "00:00:00")
			return;

		switch (togglePlayButton.label)
		{
			case "|| PAUSE":
			{
				_player.pause();
				_player.seek(0.0);
				_player.resume();
			}

			case "> RESUME":
			{
				_player.resume();
				_player.pause();
				_player.seek(0.0);
			}
		}
	}

	private function rewindButton_rollOverHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "REWIND";
	}

	private function rewindButton_rollOutHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "";
	}

	private function toggleVolumeButton_clickHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text != "NOW LOADING...")
			indicatorLabel.text = "";

		if (togglePlayButton.label == "> PLAY")
			return;

		switch (toggleVolumeButton.label)
		{
			case "||||| 100%":
			{
				_player.controlVolume(0.0);
				toggleVolumeButton.label = ".....   0%";
			}

			case ".....   0%":
			{
				_player.controlVolume(0.2);
				toggleVolumeButton.label = "|....  20%";
			}

			case "|....  20%":
			{
				_player.controlVolume(0.4);
				toggleVolumeButton.label = "||...  40%";
			}

			case "||...  40%":
			{
				_player.controlVolume(0.6);
				toggleVolumeButton.label = "|||..  60%";
			}

			case "|||..  60%":
			{
				_player.controlVolume(0.8);
				toggleVolumeButton.label = "||||.  80%";
			}

			case "||||.  80%":
			{
				_player.controlVolume(1.0);
				toggleVolumeButton.label = "||||| 100%";
			}
		}
	}

	private function toggleVolumeButton_rollOverHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "VOLUME";
	}

	private function toggleVolumeButton_rollOutHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "";
	}

	private function toggleAspectRatioButton_clickHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text != "NOW LOADING...")
			indicatorLabel.text = "";

		if (togglePlayButton.label == "> PLAY")
			return;

		switch (toggleAspectRatioButton.label)
		{
			case "--:--":
			{
				_player.changeAspectRatio("4:3");
				toggleAspectRatioButton.label = " 4: 3";
			}

			case " 4: 3":
			{
				_player.changeAspectRatio("16:9");
				toggleAspectRatioButton.label = "16: 9";
			}

			case "16: 9":
			{
				_player.changeAspectRatio();
				toggleAspectRatioButton.label = "--:--";
			}
		}
	}

	private function toggleAspectRatioButton_rollOverHandler(
		event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "ASPECT RATIO";
	}

	private function toggleAspectRatioButton_rollOutHandler(
		event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "";
	}

	private function toggleFullScreenButton_clickHandler(event:MouseEvent):Void
	{
		if (indicatorLabel.text != "NOW LOADING...")
			indicatorLabel.text = "";

		switch (toggleFullScreenButton.label)
		{
			case "[< >]":
			{
				_stage.displayState = StageDisplayState.FULL_SCREEN;
				toggleFullScreenButton.label = ">[ ]<";
			}

			case ">[ ]<":
			{
				_stage.displayState = StageDisplayState.NORMAL;
				toggleFullScreenButton.label = "[< >]";
			}
		}
	}

	private function toggleFullScreenButton_rollOverHandler(
		event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		switch (toggleFullScreenButton.label)
		{
			case "[< >]":
			{
				indicatorLabel.text = "FULL SCREEN MODE";
			}

			case ">[ ]<":
			{
				indicatorLabel.text = "EXIT FULL SCREEN MODE";
			}
		}
	}

	private function toggleFullScreenButton_rollOutHandler(
		event:MouseEvent):Void
	{
		if (indicatorLabel.text == "NOW LOADING...")
			return;

		indicatorLabel.text = "";
	}

	private function positionSlider_changeHandler(event:Event):Void
	{
		if (_duration <= 0.0)
			return;

		switch (togglePlayButton.label)
		{
			case "|| PAUSE":
			{
				_player.pause();
				_player.seek(_duration * positionSlider.value);
				_player.resume();
			}

			case "> RESUME":
			{
				_player.resume();
				_player.pause();
				_player.seek(_duration * positionSlider.value);
			}
		}
	}

	private function positionSlider_mouseDownHandler(event:MouseEvent):Void
	{
		_videoSeeking = true;
	}

	private function positionSlider_mouseUpHandler(event:MouseEvent):Void
	{
		_videoSeeking = false;
	}
}
