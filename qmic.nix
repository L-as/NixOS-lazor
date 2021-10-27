{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "qmic";
  version = "unstable-2021-10-04";

  src = fetchFromGitHub {
    owner = "andersson";
    repo = "qmic";
    rev = "ed896c97dc2b3b7edcba103e02fd0f3368b56ddd";
    sha256 = "llum30rTCtlxN4DlLk+buv4X6FR3KY5cwuODUenwzy4=";
  };

  makeFlags = [ "prefix=$(out)" ];
}
