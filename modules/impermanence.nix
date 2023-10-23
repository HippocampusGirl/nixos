{
  environment.persistence."/persist" = {
    directories = [
      "/var/lib" # System service persistent data
      "/var/log" # The place that journald logs to
    ];
    files = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/machine-id"
    ];
  };
  users = {
    # Do not allow passwords to be changed
    mutableUsers = false;
  };
}
