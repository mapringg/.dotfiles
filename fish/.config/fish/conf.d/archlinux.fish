if string match -q "*arch*" (uname -r)
    alias gnomeless 'comm -23 (begin; pacman -Qeq | sort; end | psub) (begin; pacman -Qqg gnome | sort; end | psub)'
    alias gnome 'comm -23 (begin; pacman -Sg gnome | awk "{print \$2}" | sort; end | psub) (begin; pacman -Qq | sort; end | psub)'
    alias packages 'expac -H M "%011m\t%-20n\t%10d" (comm -23 (pacman -Qqen | sort | psub) (echo (pacman -Qqg xorg; expac -l \'\n\' \'%E\' base) | sort -u | psub) | sort -n)'
    alias mirrors 'sudo reflector --protocol https --verbose --latest 25 --sort rate --country "Thailand,Singapore," --save /etc/pacman.d/mirrorlist'
end
