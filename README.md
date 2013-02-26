ADGraphView
=============
-------------

ADGraphView is an iOS drop-in classes that displays scrollable and zoomable with user friendly pinch gesture graph.

[![](https://dl.dropbox.com/u/25847340/ADGraphView/screenshot1-thumb.png)](https://dl.dropbox.com/u/25847340/ADGraphView/screenshot1.png)

------------
Requirements
============

ADGraphView works on any iOS version only greater or equal than 5.0 and is compatible with only ARC projects. It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* Foundation.framework
* UIKit.framework
* CoreGraphics.framework

You will need LLVM 3.0 or later in order to build ADGraphView. 

------------------------------------
Adding ADGraphView to your project
====================================

Source files
------------

The simplest way to add the ADGraphView to your project is to directly add the source files and resources to your project.

1. Download the [latest code version](https://github.com/Antondomashnev/ADGraphView/downloads) or add the repository as a git submodule to your git-tracked project. 
2. Open your project in Xcode, than drag and drop all files from Source directory and GraphResources onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project. 
3. Include ADGraphView wherever you need it with `#import "GraphView.h"`.

-----
Usage
=====

In ADGraphView project there is a demo UIViewController (as viewController.m) which show a simple usage example.

-------
License
=======

This code is distributed under the terms and conditions of the MIT license. 

----------
Change-log
==========

**Version 0.51** @ 25.2.13

- Fix incorrect anchor points bug.

**Version 0.5** @ 25.2.13

- Initial release.
