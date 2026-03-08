{
  fileSystems =
    let
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "x-systemd.idle-timeout=3600"
        "noauto"
      ];
    in
    {
      "/work" = {
        inherit options;
        device = "laptop.dzo-owl.ts.net:/work";
      };
      "/scratch" = {
        inherit options;
        device = "laptop.dzo-owl.ts.net:/scratch";
      };
    };
}
