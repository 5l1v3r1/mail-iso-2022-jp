if RUBY_VERSION >= '1.9'
  require 'mail-iso-2022-jp/mail'
  require 'mail-iso-2022-jp/message'
else
  require 'mail-iso-2022-jp/ruby18/mail'
  require 'mail-iso-2022-jp/ruby18/message'
end

require 'mail-iso-2022-jp/header'
require 'mail-iso-2022-jp/patches'
