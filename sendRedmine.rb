#!/usr/bin/env ruby

require "nkf"
require "net/smtp"
require 'rubygems'
require 'tmail'
require 'cgi'

# ARGV[0] = author
# ARGV[1] = from
# ARGV[2] = to

def readmail()
	email = TMail::Mail.parse(STDIN.read)
	body = <<EOT
email_to: #{email.to}
email_from: #{email.from}
email_cc: #{email.cc}

https://mail.google.com/mail/?ui=2&shva=1&zx=2ndwgns76rvo#advanced-search/subject=#{CGI.escape(email.subject.toutf8)}&subset=all

#{email.body.toutf8}
EOT
return email.subject , body
end

def sendmail(from, to, subject, body, host = "localhost", port = 25)
	subject_converted = subject
	header = ""
	if /管理番号:([0-9]+)/ =~ body 
		subject_converted = "[#{$1}] " + subject_converted
	else
		header = <<EOT
Project: gtd
Tracker: タスク
Priority: 高め
Category: inbox
Assigned to: #{ARGV[0]}
期日: #{Time.now.strftime("%Y-%m-%d")}
予定工数: 0.5
EOT
	end

	body = <<EOT
#{header}

#{body}
EOT

body = <<EOT
From: #{from}
To: #{to.to_a.join(",\n ")}
Subject: #{NKF.nkf("-WMm0", subject_converted)}
Date: #{Time::now.strftime("%a, %d %b %Y %X %z")}
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

#{NKF.nkf("-Wjm0", body)}
EOT

Net::SMTP.start(host, port) do |smtp|
	smtp.send_mail body, from, to
end
end

subject , body = readmail()
sendmail(ARGV[1],ARGV[2],subject,body)
