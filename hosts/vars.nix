{
  desktop = rec {
    username = "michael";
    repo = "/home/${username}/.nixos";
  };
  sandbox = rec {
    username = "virt";
    repo = "/home/${username}/.nixos";
  };
}
