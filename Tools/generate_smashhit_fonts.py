#!/usr/bin/env python3
"""
Generate a font PNG/FNT for Smash Hit from a font
"""

import sys
import io
from PIL import Image, ImageFont, ImageDraw

if len(sys.argv) < 2:
	print("Please specify font file")
	sys._exit(127)

file_in = sys.argv[1]

image_size = 1024
font_size = 80.0

font_file = open(file_in, "rb")
image = Image.new("RGBA", (image_size, image_size), (0, 0, 0, 0))
draw = ImageDraw.Draw(image)
font = ImageFont.truetype(font_file, size=font_size, index=0, encoding='unic')

file_png = f"{font.getname()[0].lower().replace(' ', '_')}.png"
file_fnt = f"{font.getname()[0].lower().replace(' ', '_')}.fnt.mp3"

spacing = open(file_fnt, "wb")

from_left = int((39 / 1024) * image_size) # pixels from left of char to start of char
from_bottom = int((39 / 1024) * image_size) # pixels from bottom of char to baseline

for i in range(64):
	row = i // 8
	col = i % 8
	char = chr(0x20 + i).lower()
	
	x = int((col / 8) * image_size)
	y = int(((row + 1) / 8) * image_size)
	space = int(font.getlength(char))
	
	print(f"{x} {y} {repr(char)} {repr(space)}")
	
	# Write spacing
	spacing.write(bytes(str(space), "utf-8") + b"\n")
	draw.text((x + from_left, y - from_bottom), char, font=font, fill=(255, 255, 255, 255), anchor="ls", font_size=font_size)

spacing.close()
image.save(file_png, format="png")
