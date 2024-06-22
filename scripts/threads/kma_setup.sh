#!/bin/sh 

if test -f $(pwd)/no_kma; then
    mv no_kma yes_kma

    # kma is first downloaded
    git clone https://bitbucket.org/genomicepidemiology/kma.git

    # enter folder, edit flags and compile
    cd kma
    sed -i 's/CFLAGS ?= -Wall -O3/CFLAGS ?= -Wall -O3 -g -march=native/g' Makefile
    sed -i 's/CFLAGS += -std=c99/LDFLAGS ?= -flto/g' Makefile
    /usr/bin/time -v -o ../kma_O3_compile.txt make

    # move bin to env bin folder
    mv kma ~/miniconda3/envs/metagenomics/bin/
    cd ..
elif test -f $(pwd)/yes_kma; then
    while test ! -f ~/miniconda3/envs/metagenomics/bin/kma; do
        sleep 60
    done
fi
