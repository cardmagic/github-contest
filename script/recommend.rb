print "Enter password (github employees can request access by emailing lucas@rufy.com from their github email address): "
$stdout.flush
pass = gets.strip

code = `openssl enc -d -aes-256-cbc -in #{File.dirname(__FILE__)}/secret.enc -pass pass:#{pass}`

File.open(File.dirname(__FILE__) + '/secret.rb', "w"){|f| f << code}

require File.dirname(__FILE__) + '/secret'
