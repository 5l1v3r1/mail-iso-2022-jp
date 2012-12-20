# coding: utf-8

# Patches for Mail on Ruby 1.9.x or above
module Mail
  WAVE_DASH = "〜" # U+301C
  FULLWIDTH_TILDE = "～" # U+FF5E
  NKF_OPTIONS = "--oc=CP50220 -xjW --fb-subchar"

  class InvalidEncodingError < StandardError; end
end
