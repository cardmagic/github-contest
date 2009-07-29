print "Enter password: "
$stdout.flush
pass = gets.strip

`openssl enc -aes-256-cbc -salt -in #{File.dirname(__FILE__)}/secret.rb -out #{File.dirname(__FILE__)}/secret.enc -pass pass:#{pass}`
