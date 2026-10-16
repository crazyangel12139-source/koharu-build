$ErrorActionPreference = 'Stop'

function Normalize-Lf([string]$text) {
    return $text -replace "`r`n", "`n"
}

$path = 'koharu/crates/koharu-renderer/src/text_renderer.rs'
$s = Normalize-Lf (Get-Content -Raw -LiteralPath $path)

$old1 = Normalize-Lf @'
        let bounds = if is_bubble_text {
            inset(frame, descriptor.text_inset)
        } else {
            frame
        };
'@
$new1 = Normalize-Lf @'
        let text_inset = if is_bubble_text {
            adaptive_text_inset(frame, descriptor.text_inset)
        } else {
            descriptor.text_inset
        };
        if text_inset != descriptor.text_inset {
            tracing::warn!(
                entity = %descriptor.entity,
                width = descriptor.width,
                height = descriptor.height,
                original = ?descriptor.text_inset,
                adjusted = ?text_inset,
                "clamped oversized text inset"
            );
        }
        let bounds = if is_bubble_text {
            inset(frame, text_inset)
        } else {
            frame
        };
'@
if (-not $s.Contains($old1)) { throw 'Could not find bounds patch target' }
$s = $s.Replace($old1, $new1)

$old2 = Normalize-Lf @'
            let [top, _, _, left] = descriptor.text_inset;
            let contour = contour.iter().map(|&(x, y)| (x - left, y - top)).collect();
            layout = layout.with_comic_balloon(
                bounds.width,
                bounds.height,
                contour,
                descriptor.text_inset.into_iter().fold(0.0, f32::max),
            );
'@
$new2 = Normalize-Lf @'
            let [top, _, _, left] = text_inset;
            let contour = contour.iter().map(|&(x, y)| (x - left, y - top)).collect();
            layout = layout.with_comic_balloon(
                bounds.width,
                bounds.height,
                contour,
                text_inset.into_iter().fold(0.0, f32::max),
            );
'@
if (-not $s.Contains($old2)) { throw 'Could not find contour patch target' }
$s = $s.Replace($old2, $new2)

$marker = 'fn inset(rect: LayoutBox, [top, right, bottom, left]: [f32; 4]) -> LayoutBox {'
$helper = Normalize-Lf @'
fn adaptive_text_inset(rect: LayoutBox, inset: [f32; 4]) -> [f32; 4] {
    let [mut top, mut right, mut bottom, mut left] =
        inset.map(|value| if value.is_finite() { value.max(0.0) } else { 0.0 });

    clamp_inset_axis(&mut left, &mut right, rect.width);
    clamp_inset_axis(&mut top, &mut bottom, rect.height);

    [top, right, bottom, left]
}

fn clamp_inset_axis(first: &mut f32, second: &mut f32, extent: f32) {
    if !extent.is_finite() || extent <= 0.0 {
        *first = 0.0;
        *second = 0.0;
        return;
    }

    let total = *first + *second;
    let maximum_total = extent * 0.5;
    if total > maximum_total && total > 0.0 {
        let scale = maximum_total / total;
        *first *= scale;
        *second *= scale;
    }
}

'@
if (-not $s.Contains($marker)) { throw 'Could not find inset helper insertion point' }
$s = $s.Replace($marker, $helper + $marker)

[System.IO.File]::WriteAllText($path, $s, [System.Text.UTF8Encoding]::new($false))
Write-Host 'Koharu text inset patch applied.'
