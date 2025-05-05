#!/bin/bash
python3 powerPole.py \
    http://example.com:8080/upload.php \
    -f payload.php \
    -p image \
    -sm "success"
exit 0