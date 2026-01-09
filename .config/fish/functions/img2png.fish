function img2png
    set -l img $argv[1]
    set -l base (string replace -r '\.[^.]+$' '' $img)
    set -l args $argv[2..-1]
    magick "$img" $args -strip \
        -define png:compression-filter=5 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        "$base-optimized.png"
end
