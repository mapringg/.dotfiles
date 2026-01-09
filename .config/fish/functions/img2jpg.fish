function img2jpg
    set -l img $argv[1]
    set -l base (string replace -r '\.[^.]+$' '' $img)
    set -l args $argv[2..-1]
    magick "$img" $args -quality 95 -strip "$base-optimized.jpg"
end
