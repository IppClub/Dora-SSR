'''
Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'''

import argparse
import requests
import subprocess
import os
from glob import glob
import sys

try:
	# Initialize the argument parser
	parser = argparse.ArgumentParser(description="Compile Rust project and upload .wasm file to Dora SSR")

	# Add command line arguments
	parser.add_argument('upload_url', type=str, help='Server IP address')
	parser.add_argument('target_path', type=str, help='Upload target file path')

	# Parse command line arguments
	args = parser.parse_args()

	# Compile the Rust project
	print("Compiling Rust project...")
	try:
		subprocess.run(["cargo", "build", "--release", "--target", "wasm32-wasip1"], check=True)
		print("Compilation complete.")
	except subprocess.CalledProcessError as e:
		print(f"Error during compilation.")
		sys.exit(1)

	# Find the latest .wasm file
	build_directory = "target/wasm32-wasip1/release/"
	wasm_files = glob(os.path.join(build_directory, "**/*.wasm"), recursive=True)

	if not wasm_files:
		raise FileNotFoundError("No .wasm file found. Please check if the compilation was successful.")

	# Assume we want to upload the latest .wasm file
	latest_wasm_file = max(wasm_files, key=os.path.getmtime)
	print(f"Found .wasm file: {latest_wasm_file}")

	# Construct the full URL and query parameters
	upload_url = args.upload_url
	target_path = args.target_path
	url = f"http://{upload_url}:8866/upload"
	params = {'path': args.target_path}

	# Send the request
	with open(latest_wasm_file, 'rb') as f:
		files = {'file': (os.path.basename(latest_wasm_file), f)}
		print("Uploading .wasm file...")
		try:
			response = requests.post(url, params=params, files=files)
			response.raise_for_status()
		except requests.RequestException as e:
			print(f"Failed to upload file.")
			sys.exit(1)

		print("File uploaded.")
		try:
			response = requests.post(
				f"http://{upload_url}:8866/run",
				json={
					'file': os.path.join(args.target_path, os.path.basename(latest_wasm_file)),
					'asProj': False
				}
			)
			response.raise_for_status()
			if response.json().get("success"):
				print("Started running.")
			else:
				print("Failed to run.")
				sys.exit(1)
		except requests.RequestException as e:
			print(f"Error during run request.")
			sys.exit(1)
		except ValueError as e:
			print(f"Invalid response format.")
			sys.exit(1)

except Exception as e:
	print(f"An unexpected error occurred: {e}")
	sys.exit(1)

