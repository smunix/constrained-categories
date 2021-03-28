{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
  }; 
  outputs =
    { self, nixpkgs, flake-utils,
      ...
    }:
    with flake-utils.lib;
    with nixpkgs.lib;
    eachSystem [ "x86_64-linux" ] (system:
      let version = "${substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
          overlay = self: super:
            with self;
            with haskell.lib;
            with haskellPackages.extend(self: super:
              let manifoldsGitHub = fetchFromGitHub {
                    owner = "leftaroundabout";
                    repo = "manifolds";
                    rev = "6f4d3ed71497074ad4cef2874a2d9fe73a14a377";
                    sha256 = "0ck5k7nh372b7ca0cq22j77vigachl54xngnz6abijr91a52fnx5";
                  };
              in
                {
                  trivial-constraint =
                    super.callCabal2nix "trivial-constraint" (fetchFromGitHub {
                      owner = "leftaroundabout";
                      repo = "trivial-constraint";
                      rev = "8ad79abb16a8f04916f7ac004a7c850d3e1c300e";
                      sha256 = "0vc9qg127929rzix0x25nm65adj1ibj0v7rwnsks3z1g10w7lz7q";
                    }) {};              
                });
            {
              constrained-categories = rec {
                package = overrideCabal (callCabal2nix "constrained-categories" ./. {}) (o: { version = "${o.version}-${version}"; });
              };
            };
          overlays = [ overlay ];
      in
        with (import nixpkgs { inherit system overlays; });
        rec {
          packages = flattenTree (recurseIntoAttrs { constrained-categories = constrained-categories.package; });
          defaultPackage = packages.constrained-categories;
        });
}
