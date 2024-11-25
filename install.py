#!/usr/bin/env python3

import shutil
import os

apk_path = f"/tmp/apk-editor-studio/apk/{os.listdir('/tmp/apk-editor-studio/apk')[0]}"

print(f"Found apk: {apk_path}")

assets_path = f"{apk_path}/assets"

# copy menu stuff
for filename in os.listdir('./Menu'):
	print(f'install menu/{filename}.mp3')
	shutil.copy(f'./Menu/{filename}', f'{assets_path}/menu/{filename}.mp3')
