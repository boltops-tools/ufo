#!/bin/bash

cert_file=$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE' 2>/dev/null)
echo 'What is the uri to your organizations root certificate chain?'
read -p 'org_root_chain: ' org_root_chain
echo "$org_root_chain"
curl "$org_root_chain" -o org_chain.txt
cat org_chain.txt >> "$cert_file"
mkdir -p "${cert_file%/*}"
security find-certificate -a -p /Library/Keychains/System.keychain > "$cert_file"
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain >> "$cert_file"
