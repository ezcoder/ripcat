# Contributing to RipCat

Thanks for your interest in contributing! 🐱🌊

## License

This project is licensed under the **MIT License**. By submitting a pull request or contribution, you agree that your contribution is licensed under the same MIT License.

## How Contributions Are Used

RipCat is an open-source tide prediction engine. The core library (`RipCatCore`) and CLI (`ripcat`) are free and open source.

We also offer paid iOS, watchOS, and macOS apps built on top of RipCatCore. **Contributions to this repository may be incorporated into those paid applications.** This is standard for MIT-licensed projects — the license explicitly permits commercial use.

## Getting Started

1. Fork the repo
2. Create a feature branch: `git checkout -b my-feature`
3. Make your changes
4. Run `swift build` to verify everything compiles
5. Submit a pull request

## Code Structure

```
Sources/
├── RipCatCore/      # Shared tide engine library (no ArgumentParser dependency)
└── ripcat-cli/      # CLI executable (depends on RipCatCore + ArgumentParser)
```

- **RipCatCore** is the shared library used by both the CLI and native apps
- **ripcat-cli** is the free command-line interface
- Keep RipCatCore free of CLI-specific dependencies

## Questions?

Open an issue — we're happy to help.
