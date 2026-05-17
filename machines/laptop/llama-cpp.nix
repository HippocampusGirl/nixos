{ pkgs, ... }:
let
  llama-cpp = pkgs.unstable.llama-cpp.override {
    # rocmSupport = true;
    vulkanSupport = true;
  };
in
{
  environment.systemPackages = [ llama-cpp pkgs.amdgpu_top ];
  services.llama-cpp = {
    enable = true;
    port = 13414;

    package = llama-cpp;

    model = pkgs.fetchurl {
      url = "https://huggingface.co/unsloth/Qwen3.5-35B-A3B-GGUF/resolve/main/Qwen3.5-35B-A3B-Q8_0.gguf";
      sha256 = "sha256-OAiGbAFqsCtK2ya4c/cAiizdLAcEo5cEBQEZqwYx20Y=";
    };

    extraFlags = [
      "--no-mmap"
      "--no-warmup"
      "--ctx-size"
      "65536"
      "--n-gpu-layers"
      "65536"
      "--flash-attn"
      "on"
    ];
  };

  systemd.services.llama-cpp = {
    environment = {
      HSA_OVERRIDE_GFX_VERSION = "11.5.1"; # Strix Halo
      HOME = "/var/lib/llama-cpp";
      XDG_CACHE_HOME = "/var/cache/llama-cpp";
      TMPDIR = "/run/llama-cpp";
    };
    serviceConfig = {
      StateDirectory = "llama-cpp";
      CacheDirectory = "llama-cpp";
      RuntimeDirectory = "llama-cpp";
    };
  };
}
