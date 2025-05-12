FROM ghcr.io/coder/coder:latest

# Copy config that triggers provider install.
COPY --chown=coder:coder main.tf /home/coder/main.tf

# Pre-populate plugin cache.
RUN terraform providers mirror /home/coder/.terraform.d/plugins

# Configure Terraform to use the cache.
COPY --chown=coder:coder .terraformrc /home/coder/.terraformrc
ENV TF_CLI_CONFIG_FILE=/home/coder/.terraformrc

# Delete config.
RUN rm /home/coder/main.tf
