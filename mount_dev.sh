#!/bin/bash

dev="${1}"
echo "mount dev $dev"
udisksctl mount -b "$dev"
