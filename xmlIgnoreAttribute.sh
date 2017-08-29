#!/bin/bash

# Ignore expanded attribute
cat $@ | | sed -e 's/expand="\(true\|false\)"//g'
