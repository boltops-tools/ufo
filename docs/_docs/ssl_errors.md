---
Title: SSL Errors
# nav_order:
---

UFO uses the AWS Ruby SDK and the underlying default SSL certificate chain configured in your active Ruby and
OpenSSL to communicate to your AWS environment. This means that you _must correctly configure_ your Ruby and OpenSSL to have all the needed ROOT certificates for UFO to be able to communicate to AWS - _especially_ if you are behind a proxy or a corporate SSL-Proxy.

If you are behind a corporate SSL proxy and you have not updated system, OpenSSL and Ruby certificate chains to include the needed corporate root certificates, you will see errors, such as:

```
Seahorse::Client::NetworkingError: SSL_connect returned=1 errno=0 state=error: certificate verify failed (self signed certificate in certificate chain)
  ~/.rbenv/versions/2.6.0/lib/ruby/2.6.0/net/protocol.rb:44:in `connect_nonblock'
  ~/.rbenv/versions/2.6.0/lib/ruby/2.6.0/net/protocol.rb:44:in `ssl_socket_connect'
  ~/.rbenv/versions/2.6.0/lib/ruby/2.6.0/net/http.rb:996:in `connect'
  ~/.rbenv/versions/2.6.0/lib/ruby/2.6.0/net/http.rb:930:in `do_start'
  ~/.rbenv/versions/2.6.0/lib/ruby/2.6.0/net/http.rb:925:in `start'
```

## Helper Scripts

The `docs/utils` directory has a few scripts that should be able to help you resolve these issues and track down which certs are giving you problems.

- `ssl-doctor.rb` is from the very useful examples at <https://github.com/mislav/ssl-tools>, and it can help you find the missing ROOT cert in your certificate chain and give suggestion on getting OpenSSL working correctly.
- `update-cert-chains.sh` will help you update your Ruby and OpenSSL chains by adding in the missing ROOT cert and also pulling in the OSX System Root to your rbenv environment.
- `test-aws-api-access.rb` should now return a list of the S3 buckets for the current AWS profile that is active.

## Trouble-shooting

### Update Brew and OpenSSL

- `brew update`
- `brew upgrade openssl`

### Use the Helper Scripts to find the trouble spot

Once you have updated OpenSSL and your `brew` packages, use the helper scripts above to see if you can track down the missing certificate in your certificate chain.

The `update-cert-chain.sh` file was created using the suggestions from <https://gemfury.com/help/could-not-verify-ssl-certificate/>. Please review the information at <https://gemfury.com/help/could-not-verify-ssl-certificate/> if the `Helper Scripts` above do not fully resolve your issue.

The `test-aws-api-access.rb` uses examples from the <https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/quick-start-guide.html> for using and configuring the Ruby AWS SDK on your system.
