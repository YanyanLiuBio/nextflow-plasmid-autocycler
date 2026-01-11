# Dockerfile for Autocycler environment
FROM mambaorg/micromamba:1.5.5

# Set environment variables
ENV MAMBA_DOCKERFILE_ACTIVATE=1 \
    PATH=/opt/conda/envs/autocycler/bin:$PATH

# Set working directory
WORKDIR /data

# Copy the environment YAML
COPY autocycler.yml /tmp/environment.yml

# Create the environment using micromamba
RUN micromamba create -y -f /tmp/environment.yml && \
    micromamba clean --all --yes
# Note: leaving /tmp/environment.yml is safe and avoids permission issues

# Set default shell to bash
SHELL ["bash", "-c"]

# Activate the environment by default
RUN echo "micromamba activate autocycler" >> ~/.bashrc

# Default command
CMD ["bash"]
