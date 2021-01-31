<h1>From this repo:</h1>

https://github.com/appliedengineering/libzmq-static-build

---

This is a script that downloads and builds libzmq for iOS with libsodium support and arm64 support.

To compile on macOS:

Make sure you don't have any spaces in PATH, or else these scripts won't work.

# Get the repository
git clone https://github.com/appliedengineering/libzmq-ios.git
cd libzmq-ios

# Install Ruby using Homebrew (https://brew.sh)
brew install ruby

# Compile libzmq for iOS
cd ..			# Go up one directory to parent directory
ruby libzmq.rb

# Copy static libraries to ../SwiftyZeroMQ (optional)
# You could also just manually copy the *.a files out.
ruby copy.rb
