# The following information is from https://hub.docker.com/r/nixos/nix/tags
FROM nixos/nix:latest as image_builder
ARG NIXPKGS_COMMIT_SHA
#########################################################
# Step 1: Prepare nixpkgs for deterministic builds
#########################################################
WORKDIR /build
# Apple M1 workaround
COPY /env/ /build/env
ENV NIX_USER_CONF_FILES=/build/env/nix.conf

RUN if [-z "$NIXPKGS_COMMIT_SHA"]; then\
        echo "No NIXPKGS_COMMIT_SHA specified using latest"\
        nix-env -i git && \
            mkdir -p /build/nixpkgs && \
            cd nixpkgs && \
            git init && \
            git remote add origin https://github.com/NixOS/nixpkgs.git && \
            git fetch --depth 1 origin && \
            git checkout FETCH_HEAD && \
            cd ../ ;\
    else \
        nix-env -i git && \
            mkdir -p /build/nixpkgs && \
            cd nixpkgs && \
            git init && \
            git remote add origin https://github.com/NixOS/nixpkgs.git && \
            git fetch --depth 1 origin ${NIXPKGS_COMMIT_SHA} && \
            git checkout FETCH_HEAD && \
            cd ../ ;
    fi
ENV NIX_PATH=nixpkgs=/build/nixpkg

#########################################################
# Step 2: Build docker image
#########################################################
COPY src/ /build/src

# Build final artifact
RUN nix-build src/iso_configuration.nix
