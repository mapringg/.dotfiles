function img2jpg-small
    set -l img $argv[1]
    set -l base (string replace -r '\.[^.]+$' '' $img)
    set -l args $argv[2..-1]
    magick "$img" $args -resize '1080x>' -quality 95 -strip "$base-optimized.jpg"
end
