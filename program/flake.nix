{
  description = "Image Classifier App with Rust, PyTorch, and Python dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux"; # or "aarch64-linux", depending on your system architecture
    };

    # Define the Python environment
    pythonEnv = pkgs.python310.withPackages (ps: with ps; [
      pillow
      torch
      torchvision
    ]);

  in {
    packages.x86_64-linux.image_classifier_app = pkgs.rustPlatform.buildRustPackage {
      pname = "image_classifier_app";
      version = "0.1.0";
      
      # Specify the source of your Rust project
      src = ./src;

      # Specify any native build dependencies
      nativeBuildInputs = [
        pythonEnv
        pkgs.pkgconfig
      ];

      # Add Python environment as a runtime dependency
      buildInputs = [ pythonEnv ];

      cargoBuildFlags = ["--release"];

      installPhase = ''
        mkdir -p $out/bin
        cp target/release/image_classifier_app $out/bin/
      '';
    };

    devShell.x86_64-linux = pkgs.mkShell {
      nativeBuildInputs = [
        pythonEnv
        pkgs.rustc
        pkgs.cargo
      ];
    };
  }
}
