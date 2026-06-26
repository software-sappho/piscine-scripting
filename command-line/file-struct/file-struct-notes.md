# Bash Piscine — Session Notes
 
---
 
## The one mental model
 
Bash is **plumbing for text streams**. Every command does one of three things:
 
1. **Produces** text — `ls`, `find`, `curl`, `cat`, `echo`, `printf`
2. **Transforms** text — `grep`, `sed`, `cut`, `tr`, `wc`, `head`, `tail`, `sort`
3. **Acts** on the filesystem — `mkdir`, `cp`, `mv`, `rm`, `touch`, `tar`
Connect them with:
 
| Connector | Meaning | Example |
|-----------|---------|---------|
| `\|` (pipe) | feed left output into right command | `ls \| wc -l` |
| `>` (redirect) | write output into a file (overwrites) | `echo hi > file` |
| `&&` (and) | run right only if left succeeded | `cd dir && ls` |
 
---
 
## Exercise: file-struct (tar + tree)
 
**What it tested:** building a folder structure and packing it into a tar archive with the correct internal paths.
 
---
 
### Commands introduced
 
#### `tree`
Shows folder contents recursively with nesting visible.
 
```bash
tree struct/
# struct/
# ├── 0
# ├── 3
# │   └── text.txt   ← ls would never show you this
# └── 4
#     └── text2.txt
```
 
Use `tree` when you need to confirm files are in the right subfolders.
Use `ls` for a quick flat "what's here" check.
 
#### `tar`
Packs multiple files/folders into one single file. Like a box — doesn't compress, just combines.
 
**The four flags:**
 
| Flag | Means | What it does |
|------|-------|--------------|
| `-c` | create | make a new archive |
| `-t` | table of contents | peek inside without unpacking |
| `-x` | extract | unpack the archive |
| `-f` | file | "the archive is called this" — always required |
 
`-f` always pairs with one of `-c`, `-t`, or `-x`.
 
**Examples:**
 
```bash
# Create an archive from specific files/folders
tar -cf mybox.tar file1 file2 folder1
 
# Pack everything in current folder
tar -cf mybox.tar *
 
# Peek inside without unpacking (use this before every submission)
tar -tf mybox.tar
 
# Unpack
tar -xf mybox.tar
```
 
---
 
### The critical gotcha: where you run tar determines the archive's top level
 
```bash
# Standing INSIDE struct/:
tar -cf archive.tar *
# archive contains: 0/  1/  3/  3/text.txt ...  ✓
 
# Standing OUTSIDE struct/:
tar -cf archive.tar struct/
# archive contains: struct/0/  struct/1/  struct/3/text.txt ...  ✗
```
 
The checker unpacks and looks for `0/` at the top level.
If it finds `struct/0/` instead — it fails.
**Always `cd` into the folder first, then tar.**
 
---
 
### The solution
 
```bash
#!/bin/bash
 
mkdir struct
cd struct
mkdir 0 1 2 3 4 5 6 7 8 9 A
touch 3/text.txt
touch 4/text2.txt
touch A/text3.txt
tar -cf file-struct.tar *
mv file-struct.tar ..
```
 
**Why `mv file-struct.tar ..` at the end:**
The tar gets created inside `struct/`. The checker wants just the tar file, not the whole folder. Move it one level up.
 
---
 
### Verify before submitting
 
```bash
tar -tf file-struct.tar
```
 
Correct output looks like:
```
0/
1/
2/
3/
3/text.txt
4/
4/text2.txt
5/
6/
7/
8/
9/
A/
A/text3.txt
```
 
No `struct/` prefix. No stray files like `file-struct.sh` or `file-struct.tar` inside.
 
---
 
### Recurring traps (apply to every exercise)
 
- **Trailing newline:** `echo` adds one, `printf` doesn't. If checker says `\ No newline at end of file` — switch to `printf`.
- **Separators:** `ls -m` gives comma-SPACE. Checkers often want comma-only. Fix: `tr '\n' ','` then `sed 's/,$//'`.
- **The `total N` line:** `ls -l` prints a summary line first on non-empty dirs. Strip with `grep -v '^total'` when line position matters.
- **Display vs actual path:** a `tree` diagram in the instructions is just a picture. The checker's own `ls`/`tar` commands are the ground truth.
- **curl progress bar:** always use `curl -s` in scripts.
- **Order sensitivity:** `find` returns traversal order, not alphabetical. If contents are right but test fails, pipe through `sort`.
- **Local "No such file" errors:** the checker supplies the input file. Submit anyway if the in-script path matches the spec.
- **Shebang:** `#!/bin/bash` not `#!bin/bash`. Missing the `/` means the script can't find its interpreter.
---
 
### `tree` vs `ls` — summary
 
| | `ls` | `tree` |
|---|---|---|
| Shows current folder | ✓ | ✓ |
| Shows nested contents | ✗ | ✓ |
| Use when | quick flat check | verifying files are in right subfolders |
 
---
 
### Why tar exists (the plain English version)
 
You can't hand a checker 11 loose folders over the internet — servers transfer files, not raw directories. Tar bundles everything into one file the checker can receive, unpack, and test. Your OS does the same thing when you email a folder — it zips it automatically. Tar is Linux's version of that.
 