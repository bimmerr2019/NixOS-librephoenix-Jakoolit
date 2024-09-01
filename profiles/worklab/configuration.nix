{ userSettings, ... }:

{
  imports = [ ../homelab/base.nix
      ( import ../../system/security/sshd.nix {
        authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6XzwFsmivjtgReSAGJc1VZiHoi4ANMC7fG8Lg4V5VzpuV23VyBZJxh/Vp7//9qxt7jxqhcmgCe+x+5tQGiirgaJ4220UpSnDoYMdKiXNT/Dzv9wh68BYXy/uKQItSZUf12YUG3E5oSHL1UILd4AYCSE3hxSNJwOoUBZJ+kVqTqz9nTlfd1a9HmrgLHfW6l6tgv8omAH58H8qqBDxjbzwbUPNSvKhedysWiuoTsCoPEErZARrhL1afYIfKXVhKSbf9F1Nt3zeXcXNkZ9VorCHLOnDx3hV5woPLty3NMUGey8qFy25MMtY/gyYf05DjnDcWfDRikmfWXDGA9Hjt2IGcbJaXFTLYGFAaLMx5S/XWHwilZMcepVywrluViR52FlFdZFnuVtZzm8NK0JRP8SO7koBh0fVHHZgwFiJzTcp7CsLQ4qACp6c2YJxGZHvngit9+6O+jPh34anI2PE/+cxR/YnCy+9cTs6lATJt0gNEpxiGO1skAVs/b5lhlEgUZUgFP1/0mIltYsDdYPuCUG17IqGiXrG4ggiuwAWYTXubC+h1RQVdvREQgW8qbtEyHf9PUXZlcIzOkJUHNCMfcvoEuTtrWzXBwWQMK1Ol0ZOjNuxS/qD4qhO+Y+gNUdXbyBfMkyql+5LY9172c9z68kcdO6UMtldeY7OZEtdR0D60vw== cardno:18 094 693"];
        inherit userSettings; })
            ];
}
