#!/bin/bash

# mork $@ | grep -ivE 'PopularityIndex|LastModifiedDate|RecordKey' | cat
cat $@ | grep -ivE ' expand="(true|false)"'
