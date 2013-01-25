rtmpPlayer - a small and simple flv player
==========================================

Introduction
------------

The **rtmpPlayer** is an open source flash flv player made using **Haxe**.
It is **free** for both commercial and non-commerical use.

Compile
-------

To build the **rtmpPlayer**, you will need the following:

* **MinimalCompsHX**: <https://github.com/Beeblerox/MinimalCompsHX>
* **NME**: <http://www.nme.io> (or <https://github.com/haxenme/NME>)

To compile with **Haxe**, enter the following command:

    $ cd rtmpPlayer/src
    $ haxe --dead-code-elimination -main rtmpPlayer.Main -swf rtmpPlayer.swf

Embed
-----

Here is a basic example to embed the player:

    <object data="rtmpPlayer.swf"
            id="rtmpPlayer"
            type="application/x-shockwave-flash"
            width="640"
            height="480">
        <param value="false" name="menu" />
        <param value="noScale" name="scale" />
        <param value="true" name="allowFullscreen" />
        <param value="always" name="allowScriptAccess" />
        <param value="#000000" name="bgcolor" />
        <param value="high" name="quality" />
        <param value="opaque" name="wmode" />
        <!-- To play flv over RTMP without preview -->
        <param value="source=video&amp;server=rtmp://example.com/vod"
               name="flashvars" />
    </object>

Flashvars
---------

Here is the list of variables that you can pass to the player:

* **source**: The actual path of the media (flv or mp4) to play.
* **server**: The location of the RTMP server.
* **poster**: The path to the image (png, jpg or gif) as preview.

Examples of *flashvars*:

    <!-- To play mp4 over RTMP without preview -->
    <param value="source=mp4:video.mp4&amp;server=rtmp://example.com/vod"
           name="flashvars" />

    <!-- To play flv over HTTP with preview -->
    <param value="source=http://example.com/video.flv&amp;poster=poster.png"
           name="flashvars" />

License
-------

Copyright (C) 2013 KUSANAGI Mitsuhisa (<mikkun@mbg.nifty.com>)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
