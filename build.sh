#!/bin/bash -e

# Make sure there is a key in the SSH agent
if ! ssh-add -l > /dev/null; then
  echo "There are no SSH keys added to the SSH agent."
  echo "Run 'ssh-add'."
  exit 1
fi

# Print keys
echo "SSH keys forwarded:"
ssh-add -l
echo

# Kill socat when we're done
function cleanup {
  kill $(jobs -p)
}
trap cleanup EXIT

# Open the port
socat TCP-LISTEN:56789,bind=127.0.0.1,reuseaddr,fork UNIX-CLIENT:$SSH_AUTH_SOCK &

# Start the build
docker build -t ssh-agent-poc --build-arg SSH_AUTH_SOCK=/tmp/auth.sock .
