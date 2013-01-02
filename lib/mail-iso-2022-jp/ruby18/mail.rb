# coding: utf-8

# Patches for Mail on Ruby 1.8.7
module Mail
  NKF_OPTIONS = "--oc=CP50220 -xjW --fb-subchar"

  class InvalidEncodingError < StandardError; end
end
