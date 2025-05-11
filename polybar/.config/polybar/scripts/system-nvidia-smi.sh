#!/bin/sh

nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ print "%{F#F0C674}GPU","%{F-}"$1"%"}'
