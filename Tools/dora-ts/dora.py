#!python3
'''
Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'''

import argparse
import requests
import os
import sys
import json

try:
	# Initialize the argument parser
	parser = argparse.ArgumentParser(description="Initialize, build and run Dora SSR TypeScript project")

	# Add command line arguments
	parser.add_argument('action', type=str, nargs='?', default='build', help='init|build|run|buildrun|stop')
	parser.add_argument('-l', '--language', nargs='?', type=str, default='zh-Hans', help='API language for initializing project, should be one of zh-Hans, en, default is zh-Hans')
	parser.add_argument('-f', '--file', nargs='?', type=str, help='File to build')

	# Parse command line arguments
	args = parser.parse_args()

	# get directory from current file
	path = os.path.dirname(os.path.abspath(__file__))

	validAction = False

	if args.action == 'init':
		validAction = True
		print("Initializing Dora SSR TypeScript project...")
		language = args.language
		if language not in ["zh-Hans", "en"]:
			print(f"Invalid language: {language}, should be one of zh-Hans, en")
			sys.exit(1)
		response = requests.post(
			f"http://localhost:8866/assets"
		)
		response.raise_for_status()
		json_response = response.json()
		builtin = json_response.get("children")[0]
		APIs = set([
			"BlocklyGen.d.ts",
			"flow.d.ts",
			"Config.d.ts",
			"Dora.d.ts",
			"DoraX.d.ts",
			"es6-subset.d.ts",
			"ImGui.d.ts",
			"InputManager.d.ts",
			"jsx.d.ts",
			"lua.d.ts",
			"nvg.d.ts",
			"Platformer.d.ts",
			"PlatformerX.d.ts",
			"YarnRunner.d.ts"
			"Button.d.ts",
			"CircleButton.d.ts",
			"Ruler.d.ts",
			"ScrollArea.d.ts",
			"Circle.d.ts",
			"LineRect.d.ts",
			"Rectangle.d.ts",
			"Star.d.ts",
			"Utils.d.ts",
		])
		API_list = []
		def visit(node):
			if node.get("dir"):
				for child in node.get("children"):
					visit(child)
			else:
				if node.get("title") in APIs:
					key = node.get("key")
					normalized_key = key.replace("\\", "/")
					if "Script/Lib/Dora" in normalized_key:
						if f"Script/Lib/Dora/{language}" in normalized_key:
							API_list.append({
								"local_key": os.path.join(path, "API", node.get("title")),
								"remote_key": key
							})
					else:
						relative_path = os.path.relpath(key, os.path.join(builtin.get("key"), "Script", "Lib"))
						API_list.append({
							"local_key": os.path.join(path, "API", relative_path),
							"remote_key": key
						})
		visit(builtin)
		os.makedirs(os.path.join(path, "API"), exist_ok=True)
		for api in API_list:
			os.makedirs(os.path.dirname(api["local_key"]), exist_ok=True)
			response = requests.post(
				f"http://localhost:8866/read",
				json={'path': api["remote_key"]}
			)
			response.raise_for_status()
			json_response = response.json()
			if json_response.get("success"):
				with open(api["local_key"], "w", encoding="utf-8") as f:
					f.write(json_response.get("content"))
			else:
				print(f"Failed to read {api['remote_key']}")
				sys.exit(1)

		with open(os.path.join(path, "tsconfig.json"), "w", encoding="utf-8") as f:
			f.write(json.dumps({
				"compilerOptions": {
					"jsx": "react",
					"target": "ESNext",
					"module": "ESNext",
					"strict": True,
					"esModuleInterop": False,
					"skipLibCheck": True,
					"forceConsistentCasingInFileNames": True,
					"allowSyntheticDefaultImports": True,
					"rootDir": "./",
					"typeRoots": ["API"],
					"types": ["Dora"],
				},
				"include": [
					"**/*.ts",
					"**/*.tsx"
				],
				"exclude": [
					"node_modules",
					"dist"
				]
			}, indent=2))

		print("API files set up.")
	if args.action == 'build' or args.action == 'buildrun':
		validAction = True
		# Compile the TypeScript project
		if not args.file:
			print("Compiling Dora SSR TypeScript project...")
		target = args.file or path
		try:
			response = requests.post(
				f"http://localhost:8866/ts/build",
				json={'path': target}
			)
			response.raise_for_status()
			json_response = response.json()
			if json_response.get("success"):
				print("Compilation complete.")
				messages = json_response.get("messages")
				if messages and len(messages) > 0:
					for message in messages:
						if message.get("success"):
							print(f"\033[92m[info]\033[0m {message.get('file')} built.")
						else:
							print(f"\033[91m[error]\033[0m {message.get('message')}")
				else:
					print("No files built.")
			else:
				message = json_response.get("message")
				print(f"Compilation failed. {message}")
				sys.exit(1)
		except requests.RequestException as e:
			print(f"Error during run request. {e}")
			sys.exit(1)
		except ValueError as e:
			print(f"Invalid response format.")
			sys.exit(1)
	if args.action == 'run' or args.action == 'buildrun':
		validAction = True
		response = requests.post(
			f"http://localhost:8866/run",
			json={'file': os.path.join(path, "init.lua"), 'asProj': True}
		)
		response.raise_for_status()
		json_response = response.json()
		if json_response.get("success"):
			print("Start running...")
		else:
			print("Failed to run.")
			sys.exit(1)
	if args.action == 'stop':
		validAction = True
		response = requests.post(
			f"http://localhost:8866/stop"
		)
		response.raise_for_status()
		json_response = response.json()
		if json_response.get("success"):
			print("Stoped running.")
		else:
			print("Failed to stop.")
			sys.exit(1)
	if not validAction:
		print("Invalid action.")
		sys.exit(1)

except Exception as e:
	print(f"An unexpected error occurred: {e}")
	sys.exit(1)
