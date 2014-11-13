DeltaMap Readme
13 November 2014
===========================================================================
DESCRIPTION:


DeltaMap is based on the TileMap project from WWDC2010's presentation, Customizing Maps with Overlays.
You can find the presentation at https://developer.apple.com/videos/wwdc/2010/
And I found the referenced code athttps://github.com/klokantech/Apple-WWDC10-TileMap

I've replaced the Tiles directory with the directory plate22_1.  This is a directory of map tile images generated from rectified images of the mississipi river basin plates drawn by Harold Fisk.  The plates were found at http://lmvmapping.erdc.usace.army.mil/
I also rewrote the code, updating depreciated classes and methods and touched up the interface a bit.

=============================================================================
GOALS:

Improve loading time
Isolate what is causing occasional crashes

=============================================================================
REFERENCES:
The tiled images were created using gdal2tiles.py
(http://www.gdal.org/gdal2tiles.html) 

Other sources used to learn about how to go about this:
http://weblog.invasivecode.com/post/53869832686/apple-map-overlay-and-aerial-images-overlay
http://nelsonslog.wordpress.com/2011/05/16/notes-on-building-a-slippy-map-of-the-fisk-maps/

And some great articles on why this overlay is interesting in particular:
http://www.npr.org/blogs/inside/2010/07/14/128511984/twisted-history-the-wily-mississippi-cuts-new-paths
https://medium.com/matter/louisiana-loses-its-boot-b55b3bd52d1e

===========================================================================
BUILD REQUIREMENTS:

Xcode 5.1 or later, Mac OS X v10.6 or later, iPhone SDK 7.0 or later

===========================================================================
RUNTIME REQUIREMENTS:

iPhone OS 7.0

===========================================================================
PACKAGING LIST:

TileOverlay
    - MKOverlay model class representing a tiled raster map overlay described by a directory hierarchy of tile images.

TileOverlayView
    - MKOverlayView subclass to display a raster tiled map overlay.
    
===========================================================================
