{
  services.jellyfin.enable = true;
  services.samba = {
    enable = true;
    nmbd.enable = false;

    settings = {
      global = {
        "map to guest" = "never";
        "bind interfaces only" = "yes";
        "interfaces" = "lo";
        "smb ports" = 445;
        "server min protocol" = "SMB3_11";
        "guest ok" = "no";
        "writeable" = "yes";
        "browseable" = "yes";
      };
      audio-books.path = "/z/audio-books";
      movies.path = "/z/movies";
      shows.path = "/z/shows";
    };
  };
  users.extraUsers.johannes = {
    isNormalUser = true;
    createHome = false;
  };
}
