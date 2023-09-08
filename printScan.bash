#!/bin/bash

printer="hpaio:/net/HP_LaserJet_CM1415fnw?ip=192.168.1.96"

# Copy-machine mode. Scan and print immediately as black and white.
alias printCopyBW="hp-scan --device=\"${printer}\" --dest=print"
