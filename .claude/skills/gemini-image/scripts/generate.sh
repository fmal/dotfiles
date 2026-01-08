#!/bin/bash
# nano-banana - Generate images using Gemini 3 Pro Image (Nano Banana Pro)
# Requires: GEMINI_API_KEY environment variable, jq, base64

set -e

usage() {
  cat <<EOF
Usage: nano-banana [options] -p "prompt"

Generate images using Gemini 3 Pro Image (Nano Banana Pro).

Options:
  -p, --prompt      Image generation prompt (required)
  -i, --image       Reference image path (can be used multiple times)
  -c, --clipboard   Capture image from clipboard as reference (requires pngpaste)
  -a, --aspect      Aspect ratio: 1:1, 16:9, 9:16, 3:2, 4:5, 21:9 (default: 16:9)
  -r, --resolution  Resolution: 1K, 2K, 4K (default: 2K)
  -o, --output      Output file path (default: /tmp/nano-banana-{timestamp}.{ext})
  -h, --help        Show this help message

Environment:
  GEMINI_API_KEY    Google AI API key (required)

Examples:
  nano-banana -p "A futuristic dashboard UI with glassmorphism"
  nano-banana -p "Mobile app login screen" -a 9:16 -r 2K
  nano-banana -p "Hero image for blog post" -a 21:9 -o hero.png
  nano-banana -c -p "Make this design more modern"
  nano-banana -i reference.png -p "Similar style but with blue tones"
EOF
  exit 0
}

# Defaults
ASPECT="16:9"
RESOLUTION="2K"
OUTPUT=""
PROMPT=""
MODEL="gemini-3-pro-image-preview"
IMAGES=()
USE_CLIPBOARD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--prompt) PROMPT="$2"; shift 2 ;;
    -i|--image) IMAGES+=("$2"); shift 2 ;;
    -c|--clipboard) USE_CLIPBOARD=true; shift ;;
    -a|--aspect) ASPECT="$2"; shift 2 ;;
    -r|--resolution) RESOLUTION="$2"; shift 2 ;;
    -o|--output) OUTPUT="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# Validate
if [[ -z "$PROMPT" ]]; then
  echo "Error: prompt is required (-p)" >&2
  exit 1
fi

if [[ -z "$GEMINI_API_KEY" ]]; then
  echo "Error: GEMINI_API_KEY environment variable not set" >&2
  exit 1
fi

# Capture clipboard image if requested
if [[ "$USE_CLIPBOARD" == true ]]; then
  if ! command -v pngpaste &> /dev/null; then
    echo "Error: pngpaste not installed (brew install pngpaste)" >&2
    exit 1
  fi
  CLIPBOARD_IMG="/tmp/nano-banana-clipboard-$(date +%s).png"
  if pngpaste "$CLIPBOARD_IMG" 2>/dev/null; then
    IMAGES+=("$CLIPBOARD_IMG")
    echo "Captured clipboard image: $CLIPBOARD_IMG" >&2
  else
    echo "Warning: No image in clipboard, proceeding without" >&2
  fi
fi

# Set default output path (extension determined after response)
if [[ -z "$OUTPUT" ]]; then
  TIMESTAMP=$(date +%s)
  OUTPUT="/tmp/nano-banana-${TIMESTAMP}"
  AUTO_EXT=true
else
  AUTO_EXT=false
fi

# Build parts array with images and text
build_parts() {
  local parts="["
  local first=true

  # Add reference images
  for img in "${IMAGES[@]}"; do
    [[ ! -f "$img" ]] && continue
    local mime="image/png"
    [[ "$img" == *.jpg || "$img" == *.jpeg ]] && mime="image/jpeg"
    [[ "$img" == *.webp ]] && mime="image/webp"
    local b64=$(base64 -i "$img" | tr -d '\n')
    [[ "$first" != true ]] && parts+=","
    first=false
    parts+="{\"inlineData\":{\"mimeType\":\"$mime\",\"data\":\"$b64\"}}"
  done

  # Add text prompt
  [[ "$first" != true ]] && parts+=","
  parts+="{\"text\":$(echo "$PROMPT" | jq -Rs '.')}"
  parts+="]"
  echo "$parts"
}

# Build request JSON
PARTS=$(build_parts)
REQUEST=$(jq -n \
  --argjson parts "$PARTS" \
  --arg aspect "$ASPECT" \
  --arg resolution "$RESOLUTION" \
  '{
    contents: [{
      parts: $parts
    }],
    generationConfig: {
      responseModalities: ["TEXT", "IMAGE"],
      imageConfig: {
        aspectRatio: $aspect,
        imageSize: $resolution
      }
    }
  }')

# Make API request
RESPONSE=$(curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$REQUEST")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
  echo "API Error:" >&2
  echo "$RESPONSE" | jq -r '.error.message // .error' >&2
  exit 1
fi

# Extract image data and mime type
IMAGE_PART=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[] | select(.inlineData)' 2>/dev/null)
IMAGE_DATA=$(echo "$IMAGE_PART" | jq -r '.inlineData.data' 2>/dev/null)
MIME_TYPE=$(echo "$IMAGE_PART" | jq -r '.inlineData.mimeType' 2>/dev/null)

if [[ -z "$IMAGE_DATA" || "$IMAGE_DATA" == "null" ]]; then
  echo "No image in response. Text response:" >&2
  echo "$RESPONSE" | jq -r '.candidates[0].content.parts[] | select(.text) | .text' >&2
  exit 1
fi

# Add extension based on mime type if auto
if [[ "$AUTO_EXT" == true ]]; then
  case "$MIME_TYPE" in
    image/jpeg) OUTPUT="${OUTPUT}.jpg" ;;
    image/png) OUTPUT="${OUTPUT}.png" ;;
    image/webp) OUTPUT="${OUTPUT}.webp" ;;
    *) OUTPUT="${OUTPUT}.jpg" ;;
  esac
fi

# Decode and save image
echo "$IMAGE_DATA" | base64 -d > "$OUTPUT"

echo "$OUTPUT"

# Always open for user to view
open "$OUTPUT"
