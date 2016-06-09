<pre>Modifications to the acme editor, part of plan9port.
Build:
	Copy acme-l files into your plan9port directory, overwriting existing files.
	Rebuild the entire plan9port project.

Added keyboard shortcuts (based on http://plan9.bell-labs.com/sources/contrib/rminnich/):
	^b: left one char
	^f: right one char
	^d: delete next char
	^k: delete to end of line
	^l: redraw
	^n: move cursor to next line
	^p: move cursor to previous line

Added lisp style parenthesis highlighting:
	Execute "Lisp ON" to use parenthesis highlighting for that window.
	Execute "Lisp OFF" to disable it.

	Start acme with the "-p" arguement to use parenthesis highlighting for
	all windows by default.</pre>
