{ stdenv, fetchFromGitHub, qrtr, udev, qmic }:

stdenv.mkDerivation {
  pname = "rmtfs";
  version = "unstable-2021-08-09";

  src = fetchFromGitHub {
    owner = "andersson";
    repo = "rmtfs";
    rev = "b08ef6f98ec567876d7d45f15c85c6ed00d7c463";
    sha256 = "v7xcbo+KYPqUr0xNjj4IZrVmsMHx99Cmy2Sm5Z4WDaQ=";
  };

  /* rmtfs only works with an older version of qmic...
  prePatch = ''
    rm qmi_rmtfs.{c,h}
  '';
  */

  #nativeBuildInputs = [ qmic ];
  buildInputs = [ qrtr udev ];

  makeFlags = [ "prefix=$(out)" ];
}
