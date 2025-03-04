# Base
alias g='git'
alias gss='git status -s'
alias gst='git status'
alias gsb='git status -sb'

# Add
alias ga='git add'
alias gaa='git add --all'
alias gau='git add --update'
alias gapa='git add --patch'
alias grm='git rm'
alias grmc='git rm --cached'
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'

# Bisect
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

# Branch
alias gb='git branch -vv'
alias gba='git branch -a -v'
alias gban='git branch -a -v --no-merged'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbda='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
alias gbage='git for-each-ref --sort=committerdate refs/heads/ --format="%(refname:short) %(committerdate:relative)"'
alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias grename='git branch -m'

# Checkout
alias gco='git checkout'
alias gcod='git checkout develop'
alias gcom='git checkout $(git_default_branch)'
alias gcb='git checkout -b'

# Commit
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcv='git commit -v --no-verify'
alias gcav='git commit -a -v --no-verify'
alias gcav!='git commit -a -v --no-verify --amend'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcs='git commit -S'
alias gscam='git commit -S -a -m'
alias gcfx='git commit --fixup'

# Diff
alias gd='git diff'
alias gdca='git diff --cached'
alias gds='git diff --stat'
alias gdsc='git diff --stat --cached'
alias gdt='git diff --name-only'
alias gdw='git diff --word-diff'
alias gdwc='git diff --word-diff --cached'
alias gdto='git difftool'
alias gdg='git diff --no-ext-diff'
alias gdv='git diff | view -'

# Flow
alias gfb='git flow bugfix'
alias gff='git flow feature'
alias gfr='git flow release'
alias gfh='git flow hotfix'
alias gfs='git flow support'
alias gfbs='git flow bugfix start'
alias gffs='git flow feature start'
alias gfrs='git flow release start'
alias gfhs='git flow hotfix start'
alias gfss='git flow support start'
alias gfbt='git flow bugfix track'
alias gfft='git flow feature track'
alias gfrt='git flow release track'
alias gfht='git flow hotfix track'
alias gfst='git flow support track'
alias gfp='git flow publish'

# Log
alias gcount='git shortlog -sn'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glo='git log --oneline --decorate --color'
alias gloo='git log --pretty=format:"%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s" --date=short'
alias glog='git log --oneline --decorate --color --graph'
alias gloga='git log --oneline --decorate --color --graph --all'
alias glom='git log --oneline --decorate --color $(git_default_branch)..'
alias glod='git log --oneline --decorate --color develop..'
alias glp='git log'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'

# Push & Pull
alias gl='git pull'
alias ggl='git pull origin $(git_current_branch)'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash -v'
alias glr='git pull --rebase'
alias gp='git push'
alias gp!='git push --force-with-lease'
alias gpo='git push origin'
alias gpo!='git push --force-with-lease origin'
alias gpv='git push --no-verify'
alias gpv!='git push --no-verify --force-with-lease'
alias ggp='git push origin $(git_current_branch)'
alias ggp!='git push origin $(git_current_branch) --force-with-lease'
alias gpu='git push origin $(git_current_branch) --set-upstream'
alias gpoat='git push origin --all && git push origin --tags'
alias ggpnp='git pull origin $(git_current_branch) && git push origin $(git_current_branch)'

# Rebase
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbm='git rebase $(git_default_branch)'
alias grbmi='git rebase $(git_default_branch) --interactive'
alias grbmia='git rebase $(git_default_branch) --interactive --autosquash'
alias grbom='git fetch origin $(git_default_branch) && git rebase FETCH_HEAD'
alias grbomi='git fetch origin $(git_default_branch) && git rebase FETCH_HEAD --interactive'
alias grbomia='git fetch origin $(git_default_branch) && git rebase FETCH_HEAD --interactive --autosquash'
alias grbd='git rebase develop'
alias grbdi='git rebase develop --interactive'
alias grbdia='git rebase develop --interactive --autosquash'
alias grbs='git rebase --skip'
alias ggu='git pull --rebase origin $(git_current_branch)'

# Remote
alias gr='git remote -vv'
alias gra='git remote add'
alias grmv='git remote rename'
alias grpo='git remote prune origin'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grup='git remote update'
alias grv='git remote -v'

# Stash & WIP
alias gsta='git stash'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gtest='git stash -u && git stash apply &&'
alias gwip='git add -A && git commit -m "WIP"'
alias gunwip='git log -n 1 | grep -q -c "WIP" && git reset HEAD^'

# Tags
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gtl='git tag -l'

# Worktree
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtlo='git worktree lock'
alias gwtmv='git worktree move'
alias gwtpr='git worktree prune'
alias gwtulo='git worktree unlock'

# GitLab-specific
alias gmr='git push origin $(git_current_branch) -o merge_request.create'
alias gmwps='git push origin $(git_current_branch) -o merge_request.create -o merge_request.merge_when_pipeline_succeeds'

# Everything Else
alias gap='git apply'
alias gbl='git blame -b -w'
alias gcf='git config --list'
alias gcl='git clone'
alias gclean='git clean -di'
alias gclean!='git clean -dfx'
alias gclean!!='git reset --hard && git clean -dfx'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep ^h'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfm='git fetch origin $(git_default_branch) --prune && git merge FETCH_HEAD'
alias gfo='git fetch origin'
alias gm='git merge'
alias gmt='git mergetool --no-prompt'
alias gmom='git merge origin/$(git_default_branch)'
alias grev='git revert'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grhpa='git reset --patch'
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'
alias gsh='git show'
alias gsd='git svn dcommit'
alias gsr='git svn rebase'
alias gsu='git submodule update'
alias gsur='git submodule update --recursive'
alias gsuri='git submodule update --recursive --init'
alias gsw='git switch'
alias gswc='git switch --create'
alias gunignore='git update-index --no-assume-unchanged'

# Helper functions for dynamic branch names
git_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

git_default_branch() {
    local default_branch=$(git config --get init.defaultBranch)
    if [[ -n "$default_branch" && $(git branch --list "$default_branch") ]]; then
        echo "$default_branch"
    elif git branch --list main; then
        echo "main"
    else
        echo "master"
    fi
}
