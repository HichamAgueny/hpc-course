#!/bin/bash -l
#SBATCH --job-name=gpuaware_olivia_IPC_disabled
#SBATCH --account=nn14000k
#SBATCH --time=00:10:00
#SBATCH --partition=accel
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --gpus=2
#SBATCH --gpus-per-node=2
#SBATCH --mem-per-gpu=20G #CPU memory that should be allocated per GPU
#SBATCH -o %x-%j.out
##SBATCH --exclusive

#Load the Olivia software stack
module load CrayEnv
module load cuda/12.6
module load craype-accel-nvidia90
module load craype-network-ofi

#To enable GPU-aware MPI
export MPICH_GPU_SUPPORT_ENABLED=1

#To disable Interprocess Communication (IPC) mechanisms 
#GPU-to-GPU memory traffic is staged through host memory.
export MPICH_GPU_IPC_ENABLED=0

# Set this to enable high-speed GPU-to-GPU transfers
#export MPICH_RDMA_ENABLED_CUDA=1

# Binding option
CPU_BIND="map_cpu:1,73"

time srun ./gpuaware.olivia.exe

echo
