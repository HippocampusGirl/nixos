#!/usr/bin/env bash
# Adapted from
# https://github.com/distribution/distribution/issues/4470#issuecomment-2435337870

# Requirements:
# - perl >= 5.26.1
# - base64
# - sha256sum
# - openssl

input_cert=${1??'Missing certificate'}

# Helping hands from perl
# - Remove any newlines
# - Even the hex text length if length is odd
# - Split in groups of two chars
# - Get the integer value of the two hex chars (FF => 255)
# - Convert the integer value to a real byte
# - Print it all without separators
function hex_to_bytes {
  perl -00 -nwE 'chomp($_); $_ = "0".$_ if (length($_) % 2) == 1; print map { pack("C", $_) } map { hex($_) } ($_ =~ /(..)/g);'
}

# base64url means:
#   plus  => minus
#   slash => underscore
#   no padding (=)
function b64url {
  base64 -w0 | tr '+' '-' | tr '/' '_' | tr -d '='
}

# Find where the public key parameters section is
pubkey_offset=$(openssl asn1parse -in "${input_cert}" -strictpem -inform DER -i | sed -ne '/:rsaEncryption/,/BIT STRING/p' | tail -n1 | cut -f1 -d: | xargs)
pubkey_params=$(openssl asn1parse -in "${input_cert}" -strictpem -inform DER -strparse "${pubkey_offset}" -item RSAPublicKey)

# Extract modulus and exponent
modulus=$(echo "${pubkey_params}" | grep -Po "(?<=n: ).+" | hex_to_bytes | b64url)
exponent=$(echo -n "${pubkey_params}" | grep -Po "(?<=e: ).+" | hex_to_bytes | b64url)

# Build the Thumbprint for the KID
# https://datatracker.ietf.org/doc/html/rfc7638#section-3.1
#
# Parameter definitions from
# https://datatracker.ietf.org/doc/html/rfc7518#section-6.3.1
kid=$(printf '{"e":"%s","kty":"RSA","n":"%s"}' "${exponent}" "${modulus}" | sha256sum | perl -ae 'print $F[0]' | hex_to_bytes | b64url)

# Print the JWK to consume with distribution
printf '{ 
  "keys": [{
    "e": "%s",
    "kid": "%s",
    "kty":"RSA",
    "n":"%s"
  }]
}\n' "${exponent}" "${kid}" "${modulus}"
