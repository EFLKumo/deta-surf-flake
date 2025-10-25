# deta-surf-flake

Flake for [Deta Surf](https://deta.surf/). Packaged from AppImage and populating dependencies.

The source is kept up-to-date by GitHub Actions.

```
deta-surf = {
  url = "github:EFLKumo/deta-surf-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```
inputs.deta-surf.packages."${pkgs.system}".surf
```
