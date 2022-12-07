#!/bin/bash

filename="$1"

cd /mnt
tar cvf $filename.tar quanta
