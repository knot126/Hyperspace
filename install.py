#!/usr/bin/env python3

import shutil
import os

apk_path = f"/tmp/apk-editor-studio/apk/{os.listdir('/tmp/apk-editor-studio/apk')[0]}"

print(f"Found apk: {apk_path}")

assets_path = f"{apk_path}/assets"

def install_dir(name, to_root=False):
	os.makedirs(f"{assets_path}/{name.lower()}", exist_ok=True)
	
	for filename in os.listdir(f'./{name}'):
		print(f'install {name.lower()}/{filename}.mp3')
		shutil.copy(f'./{name}/{filename}', f'{assets_path}/{name.lower() + '/' if not to_root else ''}{filename}.mp3')

# copy menu stuff
install_dir("Menu")
install_dir("Fonts")
install_dir("Common")
install_dir("Default", True)
