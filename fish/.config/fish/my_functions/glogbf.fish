# ~/.config/fish/config.fish or ~/.config/fish/functions/glogbf.fish

function glogbf --description "Show git log with patches from where the current branch forked off a base branch (default: main) to HEAD."
    # Define options using argparse
    # -b or --base to specify the base branch
    # -h or --help for help
    set -l options 'h/help' 'b/base=?'
    argparse $options -- $argv
    or return # Exit if argparse failed (e.g., invalid option)

    if set -q _flag_h
        echo "Usage: glogbf [-b | --base <base_branch_name>] [-- <git_log_options_or_paths>]"
        echo "Shows git log with patches (-p) from where the current branch forked off a base branch up to HEAD."
        echo "If no base branch is specified, 'main' is used as the default."
        echo "Any arguments after '--' (or if no options are given, all arguments) are passed to 'git log'."
        echo ""
        echo "Examples:"
        echo "  glogbf                 # Diff against 'main'"
        echo "  glogbf -b develop      # Diff against 'develop'"
        echo "  glogbf -- src/         # Diff against 'main', only for 'src/' directory"
        echo "  glogbf -b develop -- --stat README.md # Diff against 'develop', show stat for README.md"
        return 0
    end

    set -l base_branch main # Default base branch
    if set -q _flag_base
        if test -n "$_flag_base" # Ensure a value was provided if -b was used
            set base_branch $_flag_base
        else
            echo "Error: --base option requires an argument." >&2
            return 1
        end
    end

    set -l current_branch (git symbolic-ref --short HEAD 2>/dev/null)

    if test -z "$current_branch"
        echo "Error: Not on a branch (detached HEAD state)." >&2
        return 1
    end

    if [ "$current_branch" = "$base_branch" ]
        echo "Currently on '$base_branch'. To see changes on this branch, you might want:" >&2
        echo "  git log -p -1 # Last commit" >&2
        echo "  Or specify a different base branch if this is a feature branch based off itself (unlikely)." >&2
        return 1 # Or show last commit: git log -p -1 HEAD -- $argv; return 0
    end

    # Find the merge base (the commit where the current branch forked from the base_branch)
    set -l merge_base (git merge-base $base_branch HEAD 2>/dev/null)

    if test $status -ne 0 -o -z "$merge_base"
        echo "Error: Could not find a common ancestor between '$base_branch' and HEAD ('$current_branch')." >&2
        echo "Ensure '$base_branch' exists and is related to the current branch." >&2
        return 1
    end

    # $argv will contain any arguments not consumed by argparse (e.g., file paths for git log)
    # The '..' syntax means "from merge_base (exclusive) to HEAD (inclusive)"
    # which is exactly "commits on HEAD since merge_base"
    echo "Showing 'git log -p $merge_base..HEAD' (changes on '$current_branch' since forking from '$base_branch')"
    git log -p $merge_base..HEAD -- $argv # Pass remaining arguments to git log
end

# Optional: if you save it as glogbf.fish, you don't need to source it in config.fish.
# Fish automatically loads functions from ~/.config/fish/functions/