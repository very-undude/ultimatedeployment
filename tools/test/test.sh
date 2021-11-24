#!/bin/bash

./submit.sh storage/pub
./submit.sh system/ovftool
./submit.sh system/setvars
./submit.sh system/upgrade

#./submit.sh os/esx/esx7/create
#./submit.sh templates/esx/esx7_efi/create
#./submit.sh templates/esx/esx7_efi/configure
#./submit.sh templates/esx/esx7_efi/deploy
#./submit.sh templates/esx/esx7_efi/delete
#./submit.sh os/esx/esx7/delete

#./submit.sh os/windows/windows10x64/create/
#./submit.sh templates/windows/windows10/windows10x64_efi/create 
#./submit.sh templates/windows/windows10/windows10x64_efi/configure
#./submit.sh templates/windows/windows10/windows10x64_efi/deploy
#./submit.sh templates/windows/windows10/windows10x64_efi/delete
#./submit.sh os/windows/windows10x64/delete/

#./submit.sh os/windows/windows11x64/create/
#./submit.sh templates/windows/windows11/windows11x64/create 
#./submit.sh templates/windows/windows11/windows11x64/configure
#./submit.sh templates/windows/windows11/windows11x64/deploy
#./submit.sh templates/windows/windows11/windows11x64/delete
#./submit.sh os/windows/windows11x64/delete/

#./submit.sh os/centos/centos8x64/create
#./submit.sh os/centos/centos7x64/create

