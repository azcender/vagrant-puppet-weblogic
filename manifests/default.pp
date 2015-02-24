# Default node.
# At this time we do not want to use hostname to define a node. We can assign
# nodes through facts and variables. This default will set up any classes we
# want to be global.
node default {
  # notify {"Configured for r10k environment ::$environment":}
  Package {
    allow_virtual => true,
  }

  hiera_include('classes')
}

