FROM codercom/enterprise-base:ubuntu

# Remove the LC_ALL environment variable.
USER root
ENV LANG=en_US.UTF-8
RUN echo "unset LC_ALL" >> /etc/profile.d/unset-locale.sh
USER coder

# Install Nix.
USER root
RUN apt update \
    && apt install -y curl xz-utils \
    && mkdir /nix \
    && chown coder /nix \
    && apt clean
USER coder
ENV PATH="/home/coder/.nix-profile/bin:${PATH}"
RUN curl -sL https://nixos.org/nix/install | sh -s -- --no-daemon

# Enable Flakes.
RUN mkdir -p /home/coder/.config/nix \
    && echo "experimental-features = nix-command flakes" >> /home/coder/.config/nix/nix.conf

# Copy the ./tools Nix configuration into the container.
COPY --chown=coder:coder . /home/coder/template

# Install the tools into the default profile.
RUN cd /home/coder/template && nix profile install .#default

# Backup the contents of the default profile into another directory.
RUN sudo cp -r /home/coder /home/coder-home \
    && sudo chown -R coder:coder /home/coder-home

# Copy the VSIX extensions into the container.
USER root
RUN mkdir -p /vsix
COPY --chown=coder:coder ./vsix /vsix
USER coder
