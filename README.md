# 🐱 RipCat

The funky cool tide application that the cool cats use. Developed in conjunction with my daughter and our cat Rip.

## What Is It?

RipCat is a tide prediction tool powered by NOAA data. It finds your nearest tide station, fetches predictions, and can render beautiful tide charts.

- **Free CLI** — open source, free as in beer
- **Paid Apps** — iOS, watchOS, macOS (coming soon) — cheap enough that it's easier to buy than build

## Install & Build

```bash
git clone https://github.com/ezcoder/ripcat.git
cd ripcat
swift build
```

The CLI binary lands at `.build/debug/ripcat`.

## Usage

```bash
# By city name
ripcat --city "Santa Barbara, CA"

# By coordinates
ripcat --lat 34.4208 --lon -119.6982

# Text output instead of JSON
ripcat --city "Santa Barbara, CA" --format text

# Generate a tide chart
ripcat --city "Santa Barbara, CA" --chart tides.png --theme nautical --current
```

### Chart Themes

`light` · `dark` · `coastal` · `nautical`

## Project Structure

```
Sources/
├── RipCatCore/      # Shared tide engine library (MIT)
│   ├── Models.swift
│   ├── NOAAClient.swift
│   ├── StationFinder.swift
│   ├── OutputFormatter.swift
│   ├── TideChartRenderer.swift
│   ├── ChartTheme.swift
│   └── GeocoderService.swift
└── ripcat-cli/      # CLI executable
    └── RipCat.swift
```

**RipCatCore** is a standalone Swift library with no CLI dependencies — perfect for embedding in native apps.

## License

MIT — see [LICENSE](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Contributions welcome! 🌊
