#coding:utf-8
require 'test_helper'

require File.dirname(__FILE__) + '/../init'

class MailTest < ActiveSupport::TestCase
  test "should send with ISO-2022-JP encoding" do
    mail = Mail.new(:charset => 'ISO-2022-JP') do
      from '山田太郎 <taro@example.com>'
      sender 'X事務局 <info@example.com>'
      reply_to 'X事務局 <info@example.com>'
      to '佐藤花子 <hanako@example.com>'
      cc 'X事務局 <info@example.com>'
      resent_from '山田太郎 <taro@example.com>'
      resent_sender 'X事務局 <info@example.com>'
      resent_to '佐藤花子 <hanako@example.com>'
      resent_cc 'X事務局 <info@example.com>'
      subject '日本語件名'
      body '日本語本文'
    end
    assert_equal 'ISO-2022-JP', mail.charset
    assert_equal NKF::JIS, NKF.guess(mail.subject)
    assert_equal "From: =?ISO-2022-JP?B?GyRCOzNFREJATzobKEI=?= <taro@example.com>\r\n", mail[:from].encoded
    assert_equal "Sender: =?ISO-2022-JP?B?WBskQjt2TDM2SRsoQg==?= <info@example.com>\r\n", mail[:sender].encoded
    assert_equal "Reply-To: =?ISO-2022-JP?B?WBskQjt2TDM2SRsoQg==?= <info@example.com>\r\n", mail[:reply_to].encoded
    assert_equal "To: =?ISO-2022-JP?B?GyRCOjRGIzJWO1IbKEI=?= <hanako@example.com>\r\n", mail[:to].encoded
    assert_equal "Cc: =?ISO-2022-JP?B?WBskQjt2TDM2SRsoQg==?= <info@example.com>\r\n", mail[:cc].encoded
    assert_equal "Resent-From: =?ISO-2022-JP?B?GyRCOzNFREJATzobKEI=?= <taro@example.com>\r\n", mail[:resent_from].encoded
    assert_equal "Resent-Sender: =?ISO-2022-JP?B?WBskQjt2TDM2SRsoQg==?= <info@example.com>\r\n", mail[:resent_sender].encoded
    assert_equal "Resent-To: =?ISO-2022-JP?B?GyRCOjRGIzJWO1IbKEI=?= <hanako@example.com>\r\n", mail[:resent_to].encoded
    assert_equal "Resent-Cc: =?ISO-2022-JP?B?WBskQjt2TDM2SRsoQg==?= <info@example.com>\r\n", mail[:resent_cc].encoded
    assert_equal "Subject: =?ISO-2022-JP?B?GyRCRnxLXDhsN29MPhsoQg==?=\r\n", mail[:subject].encoded
    assert_equal NKF::JIS, NKF.guess(mail.body.encoded)
  end

  test "should send with UTF-8 encoding" do
    mail = Mail.new do
      from '山田太郎 <taro@example.com>'
      to '佐藤花子 <hanako@example.com>'
      cc '事務局 <info@example.com>'
      subject '日本語件名'
      body '日本語本文'
    end
    assert_equal 'UTF-8', mail.charset
    assert_equal NKF::UTF8, NKF.guess(mail.subject)
    assert_equal "From: =?UTF-8?B?5bGx55Sw5aSq6YOO?= <taro@example.com>\r\n", mail[:from].encoded
    assert_equal "To: =?UTF-8?B?5L2Q6Jek6Iqx5a2Q?= <hanako@example.com>\r\n", mail[:to].encoded
    assert_equal "Cc: =?UTF-8?B?5LqL5YuZ5bGA?= <info@example.com>\r\n", mail[:cc].encoded
    assert_equal "Subject: =?UTF-8?Q?=E6=97=A5=E6=9C=AC=E8=AA=9E=E4=BB=B6=E5=90=8D?=\r\n", mail[:subject].encoded
    assert_equal NKF::UTF8, NKF.guess(mail.body.encoded)
  end
  
  # The thunderbird handle them like this. 
  test "should handle fullwidth tildes and wave dashes correctly" do
    fullwidth_tilde = "～"
    assert_equal [0xef, 0xbd, 0x9e], fullwidth_tilde.unpack("C*")
    wave_dash = "〜"
    assert_equal [0xe3, 0x80, 0x9c], wave_dash.unpack("C*")
    
    text1 = "#{fullwidth_tilde}#{wave_dash}"
    text2 = "#{wave_dash}#{wave_dash}"

    mail = Mail.new(:charset => 'ISO-2022-JP') do
      from 'taro@example.com'
      to 'hanako@example.com'
      subject text1
      body text1
    end
    
    if RUBY_VERSION >= '1.9'
      assert_equal "Subject: #{text2}\r\n", NKF.nkf('-mw', mail[:subject].encoded)
    else
      # Ruby 1.8.7 ではうまく行かない。
    end
    assert_equal text2, NKF.nkf('-w', mail.body.encoded)
  end
  
  test "should handle numbers in circle correctly" do
    text = "①②③④⑤⑥⑦⑧⑨"
    
    mail = Mail.new(:charset => 'ISO-2022-JP') do
      from 'taro@example.com'
      to 'hanako@example.com'
      subject text
      body text
    end
    
    assert_equal "Subject: #{text}\r\n", NKF.nkf('-mw', mail[:subject].encoded)
    assert_equal text, NKF.nkf('-w', mail.body.encoded)
  end
  
  test "should handle 'hashigodaka' and 'tatsusaki' correctly" do
    text = "髙﨑"

    mail = Mail.new(:charset => 'ISO-2022-JP') do
      from 'taro@example.com'
      to 'hanako@example.com'
      subject text
      body text
    end
    
    if RUBY_VERSION >= '1.9'
      assert_equal "Subject: #{text}\r\n", NKF.nkf('-mw', mail[:subject].encoded)
      assert_equal "Subject: =?ISO-2022-JP?B?GyRCfGJ5dRsoQg==?=\r\n", mail[:subject].encoded
    else
      # Ruby 1.8.7 ではうまく行かない。
    end
    assert_equal text, NKF.nkf('-w', mail.body.encoded)
  end
end