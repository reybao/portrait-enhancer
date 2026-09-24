#!/bin/bash
# enhance_portrait: Input -> Action (Codex) -> Output
# Usage: source enhance.sh && enhance_portrait <portrait_image> [output_path]

enhance_portrait() {
  # ================= INPUT =================
  local input="$1"
  local output="$2"

  if [[ -z "$input" ]]; then
    echo "Usage: enhance_portrait <portrait_image> [output_path]" >&2
    return 1
  fi
  if [[ ! -f "$input" ]]; then
    echo "Error: file not found: $input" >&2
    return 1
  fi
  if ! command -v codex >/dev/null 2>&1; then
    echo "Error: codex CLI is not installed" >&2
    return 1
  fi

  local dir base ext abs_input
  dir="$(cd "$(dirname "$input")" && pwd)"
  base="$(basename "${input%.*}")"
  ext="${input##*.}"
  abs_input="$dir/$(basename "$input")"

  if [[ -z "$output" ]]; then
    output="$dir/${base}_enhanced.${ext}"
  elif [[ "$output" != /* ]]; then
    output="$PWD/$output"
  fi

  # ================= ACTION =================
  local prompt="The attached image is a portrait photo located at: $abs_input

Task: create a more attractive, professionally retouched version of this portrait
and save it to exactly this path: $output

Requirements:
- Preserve the person's identity: do not change face shape, features, proportions, or expression.
- Keep it natural, like a skilled photo retoucher's work, not a filter or cartoon.
- Improve exposure, white balance, and contrast.
- Apply subtle skin smoothing while keeping skin texture.
- Slightly sharpen the eyes and reduce noise.
- Do NOT modify or overwrite the original file.
- If you write code, use Python with Pillow or OpenCV.
- When finished, print the output path and a one-line summary of the edits."

  echo "Enhancing: $abs_input"
  codex exec \
    --sandbox workspace-write \
    --skip-git-repo-check \
    -C "$dir" \
    -i "$abs_input" \
    -- "$prompt"

  # ================= OUTPUT =================
  if [[ -f "$output" ]]; then
    echo "Done. Enhanced portrait saved to: $output"
  else
    echo "Codex finished, but no output file was found at: $output" >&2
    return 1
  fi
}
