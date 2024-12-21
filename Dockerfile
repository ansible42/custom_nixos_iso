# The following information is from https://hub.docker.com/r/nixos/nix/tags
FROM nixos/nix:latest as image_builder

#########################################################
# Step 1: Prepare nixpkgs for deterministic builds
#########################################################
WORKDIR /build
# Apple M1 workaround
COPY /env/ /build/env
ENV NIX_USER_CONF_FILES=/build/env/nix.conf


#########################################################
# Step 2: Build docker image
#########################################################
COPY src/ /build/src
COPY iso.nix /build/iso.nix

# Build final artifact
RUN nix-build src/iso_configuration.nix
