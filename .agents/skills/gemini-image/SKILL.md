---
name: gemini-image
description: Generate images using Gemini 3 Pro Image (Nano Banana Pro). Use this skill when the user asks to create, generate, or make an image, picture, illustration, artwork, mockup, or visual. Also use for image editing, transformation, or style transfer when a reference image is provided.
allowed-tools: Bash, Read
---

# Gemini Image Generation

Generate images using Gemini 3 Pro's image generation API.

## Prerequisites

- `GEMINI_API_KEY` environment variable
- `pngpaste` for clipboard capture

## Parameters

| Flag               | Default | Description                                       |
| ------------------ | ------- | ------------------------------------------------- |
| `-p, --prompt`     | -       | Text description of desired image (required)      |
| `-i, --image`      | -       | Reference image path (can be used multiple times) |
| `-c, --clipboard`  | -       | Capture clipboard image as reference              |
| `-a, --aspect`     | 16:9    | Aspect ratio: 1:1, 16:9, 9:16, 3:2, 4:5, 21:9     |
| `-r, --resolution` | 2K      | Resolution: 1K, 2K, 4K                            |
| `-o, --output`     | auto    | Output file path                                  |

Output: prints path to generated image, then opens it.

## Examples

### Text-to-image

```bash
scripts/generate.sh -p "A serene mountain landscape at golden hour"
```

### With reference image

```bash
scripts/generate.sh -p "Same scene but in winter" -i /path/to/summer.png
```

### From clipboard

```bash
scripts/generate.sh -c -p "Make this design more modern"
```

### Custom aspect/resolution

```bash
scripts/generate.sh -p "Cyberpunk cityscape" -a 21:9 -r 4K
```
