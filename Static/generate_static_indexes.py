#!/usr/bin/env python3
import os
import argparse
import io
import shutil
from zipfile import ZipFile
from pathlib import Path
from json import loads
# from hashlib import file_digest
from subprocess import run

URL_FORMAT = "https://decentgamesx.github.io/objects/%@"

def getInfo(zip_file):
	try:
		return loads(ZipFile(zip_file).read("package.json").decode('utf-8'))
	except:
		return None

def getUrlForName(filename):
	return URL_FORMAT.replace("%@", filename)

def encodeBinary(items):
	if (len(items) < 1):
		return b""
	
	# HACK: just use first item for keys :3
	keys = items[0].keys()
	
	class BinaryWriter:
		def __init__(self):
			self.data = bytearray()
		
		def additem(self, d):
			if self.data != b"": self.data += b"\x00"
			self.data += str(d).encode('utf-8')
		
		def getdata(self):
			return self.data
	
	data = BinaryWriter()
	
	# Add key map
	for key in keys:
		data.additem(key)
	
	# Key map ends with *END*
	data.additem("*END*")
	
	# Add object data
	for item in items:
		for key in keys:
			if item[key] == "":
				data.additem("*NONE*")
			else:
				data.additem(item[key])
	
	return bytes(data.getdata())

def getItems():
	items = []
	
	for obj in os.scandir("objects"):
		st = obj.stat()
		info = getInfo(obj.path)
		
		if not info:
			print(f"Could not load package info for {obj.name}, will not include. Maybe its not a valid ZIP file?")
			continue
		
		items.append({
			"level": info["org.knot126.smashhit.tulip"]["level"],
			"name": info["name"],
			"creator": info["creator"],
			"uploaded_by": info["creator"],
			"orig_filename": obj.name,
			"filename": obj.name,
			"created_at": st.st_birthtime_ns // 1000000 if hasattr(st, "st_birthtime_ns") else min(st.st_atime_ns, st.st_ctime_ns, st.st_mtime_ns) // 1000000,
			"updated_at": st.st_mtime_ns // 1000000,
			"version_code": info["verid"],
			"version": info["version"],
			"start_streak": info["org.knot126.smashhit.tulip"]["streak"],
			"start_balls": info["org.knot126.smashhit.tulip"]["balls"],
			"url": getUrlForName(obj.name),
		})
	
	return items

def buildIndex(name, *, limit=None, filter=None, sort_key=None, sort_reverse=False):
	items = getItems()
	
	if filter:
		new_items = []
		
		for item in items:
			if filter(item):
				new_items.append(item)
		
		items = new_items
	
	if sort_key:
		items = sorted(items, key=sort_key, reverse=sort_reverse)
	
	if limit:
		items = items[:limit]
	
	Path(f"{name}.bin").write_bytes(encodeBinary(items))

def main():
	# Featured levels
	if not os.path.isfile("featured.txt"):
		open("featured.txt", "w").close()
	
	featured_levels = Path("featured.txt").read_text().split()
	
	def isFeatured(item):
		return item["filename"] in featured_levels
	
	buildIndex("featured", filter=isFeatured, sort_key=lambda x: x["created_at"], sort_reverse=True)
	
	# Recent levels
	buildIndex("recent", sort_key=lambda x: x["updated_at"], sort_reverse=True)
	
	# commit it!
	if shutil.which('git'):
		run(['git', 'add', '.'])
		run(['git', '-c', 'commit.gpgsign=false', 'commit', '-am', 'Update'])

if __name__ == "__main__":
	main()
