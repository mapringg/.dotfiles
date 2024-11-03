# Setup Fish Shell

This guide will help you set up the Fish shell on your system.

## Steps

### For macOS:

1. **Add Fish to the list of valid login shells:**

   ```sh
   echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
   ```

2. **Change your default shell to Fish:**

   ```sh
   chsh -s /opt/homebrew/bin/fish
   ```

3. **Add common paths to Fish's PATH variable:**

   ```sh
   fish_add_path "/opt/homebrew/bin/"
   fish_add_path ~/.local/bin
   fish_add_path ~/scripts
   ```

4. **Update Fish completions:**

   ```sh
   fish_update_completions
   ```

### For Linux:

1. **Change your default shell to Fish:**

   ```sh
   chsh -s /usr/bin/fish
   ```

2. **Add common paths to Fish's PATH variable:**

   ```sh
   fish_add_path ~/.local/bin
   fish_add_path ~/scripts
   ```

3. **Update Fish completions:**

   ```sh
   fish_update_completions
   ```

## Additional Information

- **Fish Shell Documentation:** [Fish Shell](https://fishshell.com/docs/current/)
- **Homebrew Installation:** [Homebrew](https://brew.sh/)

By following these steps, you will have Fish shell set up and ready to use with the necessary paths and completions updated.
