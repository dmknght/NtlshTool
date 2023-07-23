#[
  Binding of libtlsh-dev on Debian
  Requires to Compile with cpp instead of c when use Nim compiler
]#
import strutils
import posix

{.pragma: impTlsh, header: "tlsh.h".}
{.passL: "-ltlsh".}

const
  BUFF_SIZE = 512
  db_path* = "db/hashdb.txt"
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


proc tlsh_read_db_hash(lsh: var Tlsh, hash: string): bool =
  if lsh.fromTlshStr(cstring(hash)) == 0:
    return true
  return false


proc tlsh_calc_diff(lsh1, lsh2: var Tlsh, len_diff = true): int =
  return int(totalDiff(lsh1, addr(lsh2), len_diff))


proc tlsh_get_fp_hash(lsh: var Tlsh, path: string): bool =
  # Calculate TrendMicro's LSH from file path
  try:
    var
      buffer = newString(BUFF_SIZE)
      f = open(path, fmRead)
    while true:
      # ERROR ENDLESS LOOP?
      let
        read_bytes = f.readBuffer(addr(buffer[0]), BUFF_SIZE)

      discard lsh.update(cstring(buffer), cuint(read_bytes))
      if f.endOfFile():
        lsh.final()
        f.close()
        if isEmptyOrWhitespace($lsh.getHash()):
          return false
        # Python code has the prefix T1 because of the showversion
        # https://github.com/trendmicro/tlsh/blob/master/py_ext/tlshmodule.cpp#L448
        return true
  except:
    return false


proc tlsh_get_fd_hash(lsh: var Tlsh, fd: cint): bool =
  try:
    var buffer = newString(BUFF_SIZE)
    while true:
      let
        read_bytes = posix.read(fd, buffer.addr, BUFF_SIZE)

      if read_bytes == -1:
        lsh.final()
        discard fd.close()
        return true
      discard lsh.update(cstring(buffer), cuint(read_bytes))
  except:
    return false


proc tlsh_scan_fp*(file_path: string, sig_name: var string): int =
  # Generate hash from file
  # Compare with the db's hash
  # Calculate score
  var
    lsh1, lsh2: Tlsh

  if tlsh_get_fp_hash(lsh1, file_path):
    for line in lines(db_path):
      let
        sig_info = line.split(";")

      if lsh2.tlsh_read_db_hash(sig_info[1]):
        sig_name = sig_info[0]
        return int(tlsh_calc_diff(lsh1, lsh2))


proc tlsh_scan_fd*(fd: cint, sig_name: var string): int =
  var
    lsh1, lsh2: Tlsh

  if tlsh_get_fd_hash(lsh1, fd):
    for line in lines(db_path):
      let
        sig_info = line.split(";")

      if lsh2.tlsh_read_db_hash(sig_info[1]):
        sig_name = sig_info[0]
        return int(tlsh_calc_diff(lsh1, lsh2))


proc tlsh_hash_fp*(file_path: string): string =
  var
    lsh: Tlsh

  if tlsh_get_fp_hash(lsh, file_path):
    return $lsh.getHash()


proc tlsh_hash_fd*(fd: cint): string =
  var
    lsh: Tlsh
  if tlsh_get_fd_hash(lsh, fd):
    return $lsh.getHash()

# TODO support calculation using buffer isntead of file?