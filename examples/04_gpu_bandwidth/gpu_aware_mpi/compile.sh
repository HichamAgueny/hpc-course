#!/bin/bash 

#load modules
module load CrayEnv
module load cuda/12.6
module load craype-accel-nvidia90

#compile
ftn -h acc -o gpuaware.olivia.exe gpuaware_bandwidth.f90
