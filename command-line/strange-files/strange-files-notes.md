# Bash Piscine — Strange Files Exercise Notes

---

## Why special characters are special — what they actually do

The shell reads your command before anything touches the filesystem. These characters mean something to the shell, so if you use them unescaped, the shell acts on them instead of passing them literally:

| Character | What the shell does with it | Example of the problem |
|-----------|----------------------------|------------------------|
| `"` | starts/ends a double-quoted string | `"medium_File!"` → shell thinks it's a quoted string, not a filename |
| `'` | starts/ends a single-quoted string | same idea — shell sees a quote, not a character |
| `\` | escapes the next character | a lone `\` makes the shell wait for the next character to escape |
| `?` | glob wildcard — matches exactly ONE character | `file?` matches `file1`, `filea`, etc. — shell expands it to matching filenames |
| `*` | glob wildcard — matches ZERO or more characters | `*.txt` expands to every .txt file in the directory |
| `$` | variable expansion — reads a variable's value | `$HOME` becomes `/home/andy`; `$*` expands to all script arguments |
| `!` | history expansion — replaces with a previous command | `!ls` re-runs your last `ls` command |
| `space` | argument separator — splits your command into parts | `touch my file` creates TWO files: `my` and `file` |

So when a filename contains any of these, the shell intercepts them. Escaping tells the shell: "no, treat this as plain text."

---

## Escaping with `\`

Prefix any special character with `\` to make it literal:

| Character | Escaped | 
|-----------|---------|
| `"` | `\"` |
| `\` | `\\` (the `\` itself needs escaping) |
| `?` | `\?` |
| `$` | `\$` |
| `*` | `\*` |
| `'` | `\'` |
| `!` | `\!` |

Example — filename `"\?$*'Hard_file'*$?\"` becomes:
```bash
\"\\\?\$\*\'Hard_file\'\*\$\?\\\"
```

Walk through the first few characters:
- `"` → `\"`
- `\` → `\\`
- `?` → `\?`
- `$` → `\$`

The `\\` is the most common slip — people forget the backslash itself is special and needs escaping too.

### Alternative: single quotes `'...'`
Everything inside single quotes is 100% literal — no exceptions. Easier than backslashing everything:
```bash
touch '"medium_File!"'   # works fine
```
**The one limitation:** you cannot put a `'` inside single quotes at all. So for Hard_file (which contains `'` characters), you're forced to use backslash escaping throughout.

---

## `echo`, builtins, and the shell vs command distinction

### Is `echo` part of bash?

Sort of. There are two versions:
- **bash builtin `echo`** — built into bash itself, runs when you type `echo`
- **`/bin/echo`** — a separate standalone program on disk

When you type `echo` in bash, you get the builtin. But the key mental model is:

**The shell is plumbing. Commands produce text.**

```bash
echo -n "Random text inside!" > firstFile
```

- **Shell handles:** `>` — opens/creates `firstFile`, wires `echo`'s output into it
- **`echo` handles:** printing `Random text inside!` to its output stream

They're separate concerns. The shell connects things; commands do the actual work. This matters when you build pipelines — every `|` is the shell connecting one command's output to another's input.

### The `-n` flag

`echo` appends a trailing newline `\n` by default:

```bash
echo "hello"     # writes: hello\n  (6 bytes)
echo -n "hello"  # writes: hello    (5 bytes, no newline)
```

`-n` suppresses it. Use it when the spec says a file contains something "and nothing else" — that means no newline either.

If you forget and the checker does byte-exact comparison, you'll see:
```
\ No newline at end of file
```
That marker = trailing newline mismatch = switch to `echo -n` or `printf`.

---

## `#!/bin/bash` — the shebang

`#!` on line 1 of a script is called the **shebang**. It looks like a comment but it isn't — the kernel reads it, not bash.

It tells the kernel which interpreter to use when you run the file directly:

```bash
./script.sh     # kernel reads #!/bin/bash → runs it with bash
bash script.sh  # you're explicitly telling bash to run it → shebang ignored
```

So technically, for the piscine checker (which likely runs `bash script.sh`), you don't need it. But always include it — it's what makes a script self-contained and runnable anywhere.

`Permission denied` when running `./script.sh`? You need `chmod +x script.sh` to give the file execute permission. Or just use `bash script.sh` which doesn't require it.

---

## `ls` — list directory contents

```bash
ls           # list files in current directory (alphabetical)
ls -l        # long format (permissions, size, date)
ls -a        # show hidden files (dotfiles starting with .)
ls -m        # comma-space separated output
ls -t        # sort by modification time, newest first
```

Watch out: `ls -l` on a non-empty directory prints a `total N` line first. This shifts line numbers if you're doing anything line-position-sensitive. Strip it with `grep -v '^total'`.

---

## `cat -e` — your byte microscope

`cat` prints file contents. `-e` marks the end of every line with `$`, making invisible characters visible:

```bash
cat -e firstFile
# Random text inside!$      ← $ at end = there IS a trailing newline
# Random text inside!       ← no $ = NO trailing newline
```

**Run `cat -e` before every submission.** It's how you catch byte-level differences before the checker does.

```bash
ls | cat -e    # verify filenames look exactly right
```

---

## The `>` redirect

`>` writes a command's output into a file:

```bash
echo -n "Random text inside!" > firstFile
```

- Creates `firstFile` if it doesn't exist
- Overwrites it if it does
- Use `>>` to append instead of overwrite