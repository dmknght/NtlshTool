#[
  Binding of libtlsh-dev on Debian
  Requires to Compile with cpp instead of c when use Nim compiler
]#

{.pragma: impTlsh, header: "tlsh.h".}
{.passL: "-ltlsh".}

const
  BUFF_SIZE = 512
type
  Tlsh* {.importcpp: "Tlsh".} = object

# Allow the user to add data in multiple iterations
# void update(const unsigned char* data, unsigned int len);
proc update(tlsh: Tlsh, data: cstring, len: cuint): cint {.importcpp, impTlsh.}

# To signal the class there is no more data to be added
# void final(const unsigned char* data = NULL, unsigned int len = 0);
proc final(tlsh: Tlsh, data: cstring = nil, len: cuint = 0): void {.importcpp, impTlsh.}

# To get the hex-encoded hash code
# const char* getHash() const ;
proc getHash(tlsh: Tlsh): cstring {.importcpp, impTlsh.}

# To get the hex-encoded hash code without allocating buffer in TlshImpl - bufSize should be TLSH_STRING_BUFFER_LEN */
# const char* getHash(char *buffer, unsigned int bufSize) const;
# NOTICE: look like this method is used when the fromTlshStr is called. And the buffer is the variable that contains hash from text
proc getHash(tlsh: Tlsh, buffer: cstring, size: uint): cstring {.importcpp, impTlsh.}

# To bring to object back to the initial state */
# void reset();
proc reset(tlsh: Tlsh): void {.importcpp, impTlsh.}

# Calculate difference
# int totalDiff(const Tlsh *, bool len_diff=true) const;
proc totalDiff(tlsh: Tlsh, compare_hash: ptr Tlsh, len_diff: bool = true): cint {.importcpp, impTlsh.}

# Validate TrendLSH string and reset the hash according to it */
# int fromTlshStr(const char* str);
proc fromTlshStr(tlsh: Tlsh, data: cstring): cint {.importcpp, impTlsh.}

# Return the version information used to build this library
# static const char *version();
proc version(tlsh: Tlsh): cstring {.importcpp, impTlsh.}


proc tlsh_get_fp_hash*(path: string, hash: var string): bool =
  # Calculate TrendMicro's LSH from file path
  try:
    var
      th: Tlsh
      buffer = newString(BUFF_SIZE)
      f = open(path, fmRead)
    while true:
      let
        read_bytes = f.readBuffer(addr(buffer[0]), BUFF_SIZE)

      discard th.update(cstring(buffer), cuint(read_bytes))
      if f.endOfFile():
        th.final()
        f.close()
        hash = $th.getHash()
        return true

  except:
    hash = ""
    return false