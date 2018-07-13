# This demonstrates a way to let the docker build process use your SSH agent, meaning there is no risk of accidentally persisting an SSH key in the image layers.
#
# The output of building this Dockerfile will include something like this:
# Hi stefansundin! You've successfully authenticated, but GitHub does not provide shell access.
#
# Make sure "ssh-add -l" works on localhost and shows the key you want the to use in the docker build.
# Add a single key to the SSH agent with:
# ssh-add ~/.ssh/id_ed25519
#
# First open the TCP socket on your computer:
# socat TCP-LISTEN:56789,bind=127.0.0.1,reuseaddr,fork UNIX-CLIENT:$SSH_AUTH_SOCK
#
# Then build with:
# docker build -t ssh-agent-poc --build-arg SSH_AUTH_SOCK=/tmp/auth.sock .

FROM debian

RUN apt-get update && apt-get install -y socat ssh

ARG SSH_AUTH_SOCK
RUN /bin/sh -c '[ -n "$SSH_AUTH_SOCK" ] && socat UNIX-LISTEN:$SSH_AUTH_SOCK,unlink-early,mode=777,fork TCP:host.docker.internal:56789 &' && \
    mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts && \
    ssh git@github.com

# The build will fail because ssh exits with a non-zero exit code
# You can change it to this to make it succeed:
# ssh git@github.com || exit 0
