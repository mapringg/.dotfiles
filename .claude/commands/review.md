Perform code review on uncommitted changes

1. Run coderabbit --prompt-only --type uncommitted in the background, let it take as long as it needs, and check on it periodically.
2. Evaluate the fixes and considerations. Fix major issues only, or fix any critical issues and ignore the nits.
3. Once those changes are implemented, run CodeRabbit CLI one more time to make sure we addressed all the critical issues and didn't introduce any additional bugs.
4. Only run the loop twice. If on the second run you don't find any critical issues, ignore the nits and you're complete. Give me a summary of everything that was completed and why.
