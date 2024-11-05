
# Stylesheets

[Original repo](https://github.com/TEIC/Stylesheets)

## Differences

- Simple web server that exposes `bin/*` transformations
  ```
  curl -X POST http://localhost:7979/markdowntotei -F file=@testfile.md
  ```
- Nix flake with Stylesheet dependencies
- Docker image build (via Nix) for running the web server
