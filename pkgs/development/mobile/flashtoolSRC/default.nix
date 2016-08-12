{ stdenv, fetchFromGitHub, p7zip, jdk, libusb1, platformTools, gtk2, glib, libXtst, swt, makeWrapper, unyaffs, jna }:

assert stdenv.isLinux;

# TODO:
#
#   The FlashTool and FlashToolConsole scripts are messy and should probably we
#   replaced entirely. All these scripts do is try to guess the environment in
#   which to run the Java binary (and they guess wrong on NixOS).
#
#   The FlashTool scripts run 'chmod' on the binaries installed in the Nix
#   store. These commands fail, naturally, because the Nix story is (hopefully)
#   mounted read-only. This doesn't matter, though, because the build
#   instructions fix the executable bits already.

stdenv.mkDerivation rec {
  name = "flashtool";
  version = "0.9.22.3";

  src = fetchFromGitHub {
    owner = "Androxyde";
    repo = "Flashtool";
    rev = "ba0404400a256ee9c0debecdebecf3fec292ea64";
    sha256 = "115z1c1wqax2318azwvrykqa5zpf25ixw8hznzc1g6xb01p7yhkx";
  };

  buildInputs = [ p7zip jdk swt makeWrapper unyaffs jna ];

  meta = {
    homepage = "http://www.flashtool.net/";
    description = "S1 flashing software for Sony phones from X10 to Xperia Z Ultra";
    license = stdenv.lib.licenses.unfreeRedistributableFirmware; 
    platforms = stdenv.lib.platforms.linux;
    hydraPlatforms = stdenv.lib.platforms.none;
  };
}
