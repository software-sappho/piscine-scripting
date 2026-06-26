## hello-devops exercise — `echo` vs `printf`
 
The script:
```bash
#!/bin/bash
echo 'Hello from software-sappho!'
```
 
**When to use `echo` vs `printf`:**
 
- `echo` — always adds a trailing newline. Use it when the expected output ends with a newline (which is most of the time when printing to terminal).
- `printf 'text\n'` — only adds a newline if you explicitly write `\n`. More precise.
- `echo -n` — suppresses the newline. Use when the spec says the file contains something "and nothing else" with no newline.
Quick rule: if the checker's usage example shows a blank line after your output (like `$ bash script.sh` → `Hello!` → `$`), a newline is expected — plain `echo` is fine.
 
---
 
## nano — the text editor that isn't vim
 
Nano is a terminal text editor. The thing that gets everyone stuck: **it's not vim**. You don't type `:q` to exit.
 
### Basic workflow
```bash
nano filename.sh    # open or create a file
```
Type your code. Then:
```
Ctrl+X    # exit
Y         # yes, save
Enter     # confirm the filename
```
 
That's it. The bottom of the nano screen always shows available commands. `^` means Ctrl — so `^X` = Ctrl+X, `^O` = save without exiting.
 
### Commands worth knowing
| Keys | What it does |
|------|-------------|
| `Ctrl+X` | exit (prompts to save) |
| `Ctrl+O` | save without exiting |
| `Ctrl+K` | cut a line |
| `Ctrl+U` | paste a line |
| `Ctrl+W` | search |
| `Ctrl+G` | help |
 
If you're ever completely stuck inside nano: `Ctrl+X` gets you out. Always.
 
 
