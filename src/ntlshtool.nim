import libtlsh
import os
import strutils


type
  # CmpHash: compare with db. Require checking db first
  # ProcHash: generate hash of files
  WorkMode = enum
    CmpHash, ProcHash
  ScanOpt = object
    mode: WorkMode
    # db_path: string
    scan_target: seq[string]


proc ntlsh_scan_file(file_path: string) =
  var
    sig_name: string
  let
    diff_score = tlsh_scan_file(file_path, sig_name)
  if diff_score < 100 and not isEmptyOrWhitespace(sig_name):
    echo "[!] ", sig_name, " (diff ", diff_score, ") ", file_path


proc ntlsh_scan_dir(dir_path: string) =
  for path in walkDirRec(dir_path):
    ntlsh_scan_file(path)


proc ntlsh_help_banner() =
  echo "./" & getAppFilename() & " [scan|hash] path_1 path_2"


proc ntlsh_get_opts(): ScanOpt =
  var
    opt: ScanOpt
  let
    params = commandLineParams()
  if params[0] == "scan":
    opt.mode = CmpHash
  elif params[0] == "hash":
    opt.mode = ProcHash
  else:
    raise newException(ValueError, "Invalid option " & params[0])

  for i in 1 .. paramCount() - 1:
    opt.scan_target.add(params[i])

  return opt

proc main() =
  if paramCount() == 0:
    ntlsh_help_banner()
    return

  let
    opt = ntlsh_get_opts()
  if not fileExists(db_path) and opt.mode == CmpHash:
    raise newException(ValueError, "Invalid db path")
  for path in opt.scan_target:
    let
      abs_path = absolutePath(path)
      path_info = getFileInfo(abs_path)
    if path_info.kind == pcFile:
      ntlsh_scan_file(abs_path)
    elif path_info.kind == pcDir:
      ntlsh_scan_dir(abs_path)

main()

# test_hash("/home/dmknght/Desktop/MalwareLab/msf/meter1", "AED080331B0A51DEDED4023FA5B4599CD77B8977578966310860DC050C096055F52C75")
# test_hash("/home/dmknght/Desktop/MalwareLab/LinuxMalwareDetected/fbba7bc092f8f36da650dde4e3b1af6f6ac656f054bfb20738b2f864bceb4d5a_detected_detected", "FD866C0BF5A308ADC4AEC870465BD272A931B854423179BB7794DA301EA3F64973DFE1")
# test_hash("/tmp/test.text", "99E07D41C91B84F8B9F441517EA55D56930500DCA374B4E29C4B10C9926313E103E88C")
# TODO meterpreter generation failed
# TODO do not get hash from text. The core point is to use it as a struct then compare with db