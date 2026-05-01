ARG BASE_IMAGE=docker.io/plugins/harness_ansible:latest
FROM ${BASE_IMAGE}

ARG TARGETARCH

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) aws_arch="x86_64" ;; \
      arm64) aws_arch="aarch64" ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    tmp_dir="$(mktemp -d)"; \
    cd "${tmp_dir}"; \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" -o "awscliv2.zip"; \
    unzip -q awscliv2.zip; \
    ./aws/install; \
    cd /; \
    rm -rf "${tmp_dir}"

