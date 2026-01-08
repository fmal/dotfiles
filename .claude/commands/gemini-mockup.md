---
description: Generate UX/UI mockups and design concepts using Gemini 3 Pro Image
argument-hint: <mockup_description>
allowed-tools: Glob, Grep, Read, Skill(gemini-image)
---

Generate a UX/UI mockup: $ARGUMENTS

## Workflow

### 1. Gather Context

Check for:

- User-provided reference images or existing UI screenshots/mockups
- Style guides, design tokens, brand assets
- Color palettes in CSS/config files
- Component libraries or design systems

### 2. Build Prompt

Construct a comprehensive design prompt including:

- **Design goal**: What the user wants to create/redesign
- **Style context**: Colors, typography, theme
- **Component requirements**: Specific UI elements needed
- **Technical constraints**: Resolution, aspect ratio, platform (web/mobile)
- **Reference notes**: What reference images show and how to use them

### 3. Generate

Invoke `/gemini-image` skill and generate the mockup with:
- The constructed prompt
- Appropriate aspect ratio (see table)
- Any reference image paths
- Clipboard image flag if applicable

### 4. Summarize

Read the generated image and summarize what was generated and key design decisions.

## Aspect Ratios

| Ratio | Use Case                           |
| ----- | ---------------------------------- |
| 16:9  | Desktop, dashboards, landing pages |
| 21:9  | Hero sections, banners             |
| 9:16  | Mobile app screens                 |
| 1:1   | Icons, avatars                     |
