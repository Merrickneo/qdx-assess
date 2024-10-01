{
  description = "Image Classifier App with Rust, PyTorch, and Python dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = builtins.currentSystem;
    };

    # Define the Python environment with PyTorch and other libraries
    pythonEnv = pkgs.python310.withPackages (ps: with ps; [
      pillow
      torch
      torchvision
    ]);

  in {
    # Define the package output for different architectures (aarch64-darwin and x86_64-linux)
    packages.${pkgs.system} = pkgs.rustPlatform.buildRustPackage {
      pname = "image_classifier_app";
      version = "0.1.0";

      # Specify the correct source of your Rust project
      src = ./src;

      # Reference the Cargo.lock file to ensure reproducibility
      cargoLock = {
        lockFile = ./Cargo.lock;
      };

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

    # Define a devShell for both architectures (aarch64-darwin and x86_64-linux)
    devShell.${pkgs.system} = pkgs.mkShell {
      nativeBuildInputs = [
        pythonEnv
        pkgs.rustc
        pkgs.cargo
      ];
    };
  }
}
