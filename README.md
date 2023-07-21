Tlsh tool with Nim and Tlsh (Cpp) library

Requires: `nim` >= 1.6.1, `libtlsh-dev` to compile. Runtime requires `libtlsh0`
# Known issue:

Debian's version is 3.4.4 (update 2015) so the lib was very old. The min length required to procedure hash is 256 therefore it failed to generate hash of small file. The latest library version requires min len 50