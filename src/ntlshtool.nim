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
    # db_path: string # Custom db path?
    scan_target: seq[string]


proc ntlsh_calc_hash(file_path: string) =
  let
    tlsh = tlsh_get_hash(file_path)
  if not isEmptyOrWhitespace(tlsh):
    echo tlsh_get_hash(file_path), " ", file_path
  else:
    echo "TNULL ", file_path


proc ntlsh_check_hash(file_path: string) =
  var
    sig_name: string
  let
    diff_score = tlsh_scan_file(file_path, sig_name)
  if diff_score < 100 and not isEmptyOrWhitespace(sig_name):
    echo "[!] ", sig_name, " (diff ", diff_score, ") ", file_path


proc ntlsh_scan_file(file_path: string, mode: WorkMode) =
  if mode == CmpHash:
    ntlsh_check_hash(file_path)
  else:
    ntlsh_calc_hash(file_path)


proc ntlsh_scan_dir(dir_path: string, mode: WorkMode) =
  for path in walkDirRec(dir_path):
    ntlsh_scan_file(path, mode)


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
      ntlsh_scan_file(abs_path, opt.mode)
    elif path_info.kind == pcDir:
      ntlsh_scan_dir(abs_path, opt.mode)

main()

# TODO meterpreter generation failed
