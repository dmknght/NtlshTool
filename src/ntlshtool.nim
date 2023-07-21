import libtlsh
import os


proc ntlsh_scan_dir(dir_path: string) =
  for path in walkDirRec(dir_path):
    ntlsh_scan_file(path)


proc main() =
  if not fileExists(db_path):
    return
  let
    # TODO use args
    # TODO get absolute path
    test_path = "/home/dmknght/Desktop/MalwareLab/LinuxMalwareDetected/"
    path_info = getFileInfo(test_path)
  if path_info.kind == pcFile:
    ntlsh_scan_file(test_path)
  elif path_info.kind == pcDir:
    ntlsh_scan_dir(test_path)


main()

# test_hash("/home/dmknght/Desktop/MalwareLab/msf/meter1", "AED080331B0A51DEDED4023FA5B4599CD77B8977578966310860DC050C096055F52C75")
# test_hash("/home/dmknght/Desktop/MalwareLab/LinuxMalwareDetected/fbba7bc092f8f36da650dde4e3b1af6f6ac656f054bfb20738b2f864bceb4d5a_detected_detected", "FD866C0BF5A308ADC4AEC870465BD272A931B854423179BB7794DA301EA3F64973DFE1")
# test_hash("/tmp/test.text", "99E07D41C91B84F8B9F441517EA55D56930500DCA374B4E29C4B10C9926313E103E88C")
# TODO meterpreter generation failed
# TODO do not get hash from text. The core point is to use it as a struct then compare with db