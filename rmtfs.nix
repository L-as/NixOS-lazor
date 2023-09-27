{ stdenv, fetchFromGitHub, qrtr, udev, qmic }:

stdenv.mkDerivation {
  pname = "rmtfs";
  version = "unstable";

  src = (import ./sources.nix { inherit fetchFromGitHub; }).rmtfs;

  nativeBuildInputs = [ qmic ];
  buildInputs = [ qrtr udev ];

  makeFlags = [ "prefix=$(out)" ];
}
