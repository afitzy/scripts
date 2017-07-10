#!/bin/bash

mork $@ | grep -ivE 'PopularityIndex|LastModifiedDate|RecordKey' | cat
