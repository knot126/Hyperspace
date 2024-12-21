#!/usr/bin/env python3
"""
Convert an SVG file with rects that have shcmd attribs to smash hit uis
"""

import xml.etree.ElementTree as et
import pathlib
import sys
import os

def main():
	srcpath = pathlib.Path(sys.argv[1])
	
	root = et.fromstring(srcpath.read_text())
	
	print(f"<!-- Auto generated from {srcpath.name} -->")
	
	scale = int(root.attrib.get("{http://www.inkscape.org/namespaces/inkscape}export-xdpi", "96")) / 96
	
	if (scale != 1.0):
		print(f"<!-- Scale: {scale} -->")
	
	# TODO: Option to have a shade texture
	print(f'<ui texture="{srcpath.stem}.png" shade="true">')
	
	for e0 in root:
		# print(e0.tag)
		if (e0.tag == "{http://www.w3.org/2000/svg}g"):
			for e in e0:
				# print(e.tag)
				if (e.tag == "{http://www.w3.org/2000/svg}rect" and "shcmd" in e.attrib):
					x = float(e.attrib["x"])
					y = float(e.attrib["y"])
					
					# For some reason, shkbd has a scale transform that would
					# fuck up everything
					if "transform" in e.attrib:
						if e.attrib["transform"] == "scale(1,-1)":
							y = -(float(e.attrib["y"])) - (float(e.attrib["height"]))
						else:
							print(f"\t<!-- WARNING: Unknown transform {e.attrib['transform']} -->")
					
					width = float(e.attrib["width"])
					height = float(e.attrib["height"])
					
					x0 = round(x * scale)
					y0 = round(y * scale)
					x1 = round((x + width) * scale)
					y1 = round((y + height) * scale)
					
					print(f'\t<rect coords="{x0} {y0} {x1} {y1}" cmd="{e.attrib["shcmd"]}"/>')
	
	# TODO: Option to supress outside or use custom outside node
	print(f"\t<outside cmd=\"script:hide{srcpath.stem}\"/>")
	print(f"</ui>")

if __name__ == "__main__":
	main()
