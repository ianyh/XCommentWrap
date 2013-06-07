XCommentWrap
============

XCode plugin for wrapping comments at 80 characters. I implemented it because I found myself not writing more comprehensive comments when I really should have simply because wrapping them was a pain in the ass.

How It Works
------------

It detects if you're currently typing a code comment and when your typing extends beyond 80 characters and then pipes it through an emacs script that formats it to `fill-column` 80.
