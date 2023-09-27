{ fetchFromGitHub }: {
  imagebuilder = fetchFromGitHub {
    owner = "hexdump0815";
    repo = "imagebuilder";
    rev = "56c8168bd925573ea20096ab3c8b54fa12fe667d";
    sha256 = "WXVyJqdIUFTUGAftfySWZUSw/roub3rhZP4uL3pNlbI=";
  };
  qrtr = fetchFromGitHub {
    owner = "andersson";
    repo = "qrtr";
    rev = "d0d471c96e7d112fac6f48bd11f9e8ce209c04d2";
    sha256 = "KF0gCBRw3BDJdK1s+dYhHkokVTHwRFO58ho0IwHPehc=";
  };
  qmic = fetchFromGitHub {
    owner = "andersson";
    repo = "qmic";
    rev = "4574736afce75aa5eec1e1069a19563410167c9f";
    sha256 = "0/mIg98pN66ZaVsQ6KmZINuNfiKvdEHMsqDx0iciF8w=";
  };
  rmtfs = fetchFromGitHub {
    owner = "andersson";
    repo = "rmtfs";
    rev = "7a5ae7e0a57be3e09e0256b51b9075ee6b860322";
    sha256 = "iyTIPuzZofs2n0aoiA/06edDXWoZE3/NY1vsy6KuUiw=";
  };
}
