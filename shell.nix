let
  hostPkgs = import <nixpkgs> {};
  pinnedPkgs = hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "ee28e35ba37ab285fc29e4a09f26235ffe4123e2";
    sha256 = "0a6xrqjj2ihkz1bizhy5r843n38xgimzw5s2mfc42kk2rgc95gw5";
  };
in { nixpkgs ? import pinnedPkgs {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, ansi-wl-pprint, base, containers, criterion
      , data-fix, deepseq, deriving-compat, directory, filepath, Glob
      , parsers, regex-tdfa, regex-tdfa-text, semigroups, split, stdenv
      , tasty, tasty-hunit, tasty-th, text, transformers, trifecta
      , unordered-containers, these, optparse-applicative, free
      , interpolate, process, exceptions, bytestring, mtl, monadlist
      , base16-bytestring, cryptohash, template-haskell, syb
      }:
      mkDerivation {
        pname = "hnix";
        version = "0.4.0";
        src = ./.;
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [
          ansi-wl-pprint base containers data-fix deepseq deriving-compat
          parsers regex-tdfa regex-tdfa-text semigroups text transformers
          trifecta unordered-containers these free process directory
          filepath exceptions bytestring mtl monadlist base16-bytestring
          cryptohash template-haskell syb
        ];
        executableHaskellDepends = [
          ansi-wl-pprint base containers data-fix deepseq optparse-applicative
          text transformers unordered-containers template-haskell
        ];
        testHaskellDepends = [
          base containers data-fix directory filepath Glob split tasty
          tasty-hunit tasty-th text transformers interpolate
        ];
        benchmarkHaskellDepends = [ base containers criterion text ];
        homepage = "http://github.com/jwiegley/hnix";
        description = "Haskell implementation of the Nix language";
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv