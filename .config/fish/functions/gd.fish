function gd
    if not gum confirm "Remove worktree and branch?"
        return
    end

    set -l cwd (pwd)
    set -l worktree (basename $cwd)
    set -l root (string split -m1 -- '--' $worktree)[1]
    set -l branch (string split -m1 -- '--' $worktree)[2]

    if test "$root" != "$worktree"
        cd "../$root"
        git worktree remove "$worktree" --force
        git branch -D "$branch"
    end
end
