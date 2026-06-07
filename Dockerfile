FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

# Build arg for GPU architectures
ARG CUDA_ARCHITECTURES="8.0;8.6;8.9;9.0"
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 1. Install system dependencies
RUN apt update && \
    apt install -y \
    python3 python3-pip git wget curl cmake ninja-build \
    libgl1 libglib2.0-0 ffmpeg build-essential && \
    apt clean

WORKDIR /workspace

# 2. Upgrade pip and install PyTorch for CUDA 12.8
RUN pip install --upgrade pip setuptools wheel
RUN pip install torch==2.10.0+cu128 torchvision==0.25.0+cu128 torchaudio==2.10.0+cu128 --index-url https://download.pytorch.org/whl/cu128

# 3. Copy and install requirements
COPY requirements.txt .
RUN pip install -r requirements.txt

# 4. Install SageAttention (optimized for WanGP)
ENV TORCH_CUDA_ARCH_LIST="${CUDA_ARCHITECTURES}"
ENV FORCE_CUDA="1"
RUN git clone https://github.com/thu-ml/SageAttention.git /tmp/sageattention && \
    cd /tmp/sageattention && \
    pip install . && \
    rm -rf /tmp/sageattention

# 5. Setup User
RUN useradd -u 1000 -ms /bin/bash user
RUN mkdir -p /home/user/.cache && chown -R user:user /home/user /workspace

# 6. Copy the WanGP code (v12.11)
# Note: large models are excluded by .dockerignore created previously
COPY --chown=user:user . .

# 7. Final setup
RUN chmod +x entrypoint.sh scripts/*.sh

# Port for Gradio
EXPOSE 7862

ENTRYPOINT ["/workspace/entrypoint.sh"]
