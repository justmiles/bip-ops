#!/bin/bash

TS=$(date +"%Y%m%d_%H%M%S")
tar -czf /backups/$TS.tar.gz /userdata/Saves
