{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "unyaffs";

  src = fetchFromGitHub {
    owner = "ehlers";
    repo = "unyaffs";
    rev = "8712423772b1cc4cbe5eeb0eb210973195897d63";
    sha256 = "11ap7lqdq2kbidjxssapb3mcx895qkga0zf7q2b2al7rhp9qv6wg";
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase"];

  installPhase = ''
    mkdir -p $out/bin
    cp unyaffs $out/bin
  '';

  meta = {
    homepage = "http://bernhard-ehlers.de/projects/unyaffs.html";
    description = "Extract files from YAFFS2 image files";
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
  };

}
