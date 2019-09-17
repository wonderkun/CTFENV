#!/bin/bash

virtualenv --system-site-packages --always-copy python
. ./python/bin/activate

python debug.py
sleep infinity