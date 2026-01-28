{ pkgs, ... }:
let
  llama-cpp = pkgs.llama-cpp.override {
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
      url = "https://huggingface.co/ggml-org/Qwen3-Coder-30B-A3B-Instruct-Q8_0-GGUF/resolve/main/qwen3-coder-30b-a3b-instruct-q8_0.gguf";
      sha256 = "sha256-8imT4pMYtbnsICb2tlgCpcqZs4q0hEqrg67YomzgD/Y=";
    };
  };
}
