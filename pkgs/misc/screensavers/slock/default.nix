{ stdenv, fetchurl, xproto, libX11, libXext, pam }:
stdenv.mkDerivation rec {
  name = "slock-1.1";
  src = fetchurl {
    url = "https://github.com/jackdoe/slock/archive/master.tar.gz";
    sha256 = "13s74j0kpnsvfxwp3fs6s0i8b09b4yh5a9lm9wxg4sh7zxpa5b6y";
  };
  buildInputs = [ xproto libX11 libXext pam ];
  installFlags = "DESTDIR=\${out} PREFIX=";
  meta = {
    homepage = http://tools.suckless.org/slock;
    description = "Simple X display locker";
    longDescription = ''
      Simple X display locker. This is the simplest X screen locker.
    '';
    license = "bsd";
    maintainers = with stdenv.lib.maintainers; [ astsmtl ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
