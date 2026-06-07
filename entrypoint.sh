#!/usr/bin/env bash
export HOME=/home/user
export PYTHONUNBUFFERED=1
export HF_HOME=/home/user/.cache/huggingface

# Optimize performance
export OMP_NUM_THREADS=$(nproc)
export MKL_NUM_THREADS=$(nproc)

echo "🚀 Starting WanGP v12.11..."
echo "🔍 Checking for GPUs..."
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

# Run as the 'user' account for better compatibility with RunPod volumes
# Default port is 7862
exec su -p user -c "python3 wgp.py --listen --server-port 7862 $*"
