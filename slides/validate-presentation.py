#!/usr/bin/env python3
"""Validate the redesigned Yhar Bid M3 presentation"""

from pptx import Presentation
import sys

def validate_presentation(pptx_path):
    """Validate PPTX structure and extract metadata"""
    try:
        prs = Presentation(pptx_path)

        print(f"[OK] Presentation loaded successfully: {pptx_path}")
        print(f"\nPresentation Metadata:")
        print(f"   Slides: {len(prs.slides)}")
        print(f"   Slide width: {prs.slide_width / 914400:.1f} inches ({prs.slide_width / 914400 * 2.54:.1f} cm)")
        print(f"   Slide height: {prs.slide_height / 914400:.1f} inches ({prs.slide_height / 914400 * 2.54:.1f} cm)")
        print(f"   Aspect ratio: {prs.slide_width / prs.slide_height:.2f}:1")

        print(f"\nSlide Overview:")
        for idx, slide in enumerate(prs.slides, 1):
            shapes_count = len(slide.shapes)
            text_shapes = sum(1 for shape in slide.shapes if hasattr(shape, 'text'))

            # Try to get title
            title = "Untitled"
            if slide.shapes.title:
                title = slide.shapes.title.text[:50]

            print(f"   Slide {idx:2d}: {shapes_count} shapes ({text_shapes} text) - {title}")

        print(f"\n[OK] Validation complete - all {len(prs.slides)} slides accessible")
        return True

    except Exception as e:
        print(f"[ERROR] Error validating presentation: {e}", file=sys.stderr)
        return False

if __name__ == "__main__":
    pptx_file = "demo-slides.pptx"
    success = validate_presentation(pptx_file)
    sys.exit(0 if success else 1)
