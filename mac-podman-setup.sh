# Install Podman
brew install podman podman-compose

# Initialize (one time)
podman machine init
podman machine start

# Create alias for muscle memory
echo 'alias docker="podman"' >> ~/.zshrc