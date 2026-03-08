#!/bin/bash


cropRatioPercent=100x73
#cropRatioPercent=100x100

pushd fronts
scanImgCrop.sh --verbose --force --output="fronts%s.pdf" $cropRatioPercent "*.png"
popd

pushd rears
scanImgCrop.sh --verbose --force --output="rears%s.pdf" $cropRatioPercent "*.png"
popd

pdftk A=fronts/fronts_compressed.pdf B=rears/rears_compressed.pdf shuffle A Bend-1 output collated.pdf
