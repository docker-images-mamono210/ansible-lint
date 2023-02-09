FROM python:3.11.2-slim-buster as builder

# Install required packages
RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && pip3 install --upgrade pip \
  && apt-get install -y \
    apt ca-certificates curl git locales openssh-client sudo unzip

# Copy requirements.txt
COPY requirements.txt /tmp/

# Install Ansible lint and Ansible
RUN pip3 install --no-cache-dir --no-compile -r /tmp/requirements.txt

FROM python:3.11.2-slim-buster as production

# Install required packages
RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && pip3 install --upgrade pip \
  && apt-get install -y git

COPY --from=builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.10/site-packages/
COPY --from=builder /usr/local/bin/ansible-lint /usr/local/bin/ansible-lint
COPY --from=builder /usr/local/bin/ansible /usr/local/bin/ansible
COPY --from=builder /usr/local/bin/ansible-config /usr/local/bin/ansible-config
COPY --from=builder /usr/local/bin/ansible-connection /usr/local/bin/ansible-connection
COPY --from=builder /usr/local/bin/ansible-galaxy /usr/local/bin/ansible-galaxy
COPY --from=builder /usr/local/bin/ansible-playbook /usr/local/bin/ansible-playbook

# Remove caches
RUN find /usr/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
  && find /usr/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

WORKDIR /data
ENTRYPOINT ["ansible-lint"]
ENV ANSIBLE_FORCE_COLOR='1' PY_COLORS='1'
CMD ["--version"]
