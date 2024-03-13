{
  services.shairport-sync = {
    enable = true;
    openFirewall = true;
    arguments = ''--name="escritorio" --verbose --output=alsa'';
  };
}
