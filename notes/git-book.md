# Pro Git
In my day to day job I use Git very frequently, but I've never spent the time to properly get my head round the more complex parts, instead relying on muscle memory and StackOverflow for those occasions that I get stuck. 

I decided to read parts of Pro Git ([git-scm.com/book/en/v2](https://git-scm.com/book/en/v2)), going back to basics to learn a bit more about the internals and more advanced features of Git, and to solidify my understanding of this powerful but at times opaque tool.

## Notes
- Everything in Git is checksummed before it is stored, and referred to by that checksum (SHA-1)
- The staging area is used to mark modified files to go into the next commit (the three sections of a project are the working tree (where files can be _modified_), the staging area (where _staged_ files are) and the Git directory (where _committed_ files are))
  - The staging area is officially called the _index_
- Committing takes the contents of the index and saves it to a snapshot in the Git directory

### Config
- `git config --global --edit` to edit the global Git config file, `--system` for the system config (/etc/gitconfig), `--local` for the repository local file (which is the default config file Git will read from - stored in `.git/config` in a repository)
  - `git config --list --show-origin` to see the full list of config parameters and their origins
  - `git config --global core.editor vim` to set the editor for commit messages and stuff

### Adding, Diffing, Committing, Removing
- Files are _tracked_ by Git if they are in the last snapshot, or have been newly staged
  - Unmodified - exist in the last snapshot but not changed
  - Modified - existed in the last snapshot and have been changed
  - Staged - not existing in the last snapshot but have been added to the index
- When you commit all your staged files, they become unmodified in the context of the new, latest commit
- The `git status` command is used to see the state of files in your repository
  - `git status -s` for a shorthand easier to parse status
    - There are two columns, one for the working tree and the other for the index (staging area)
- `git add <file>` to add files to the staging area (duh). Specifying a directory will add _all the files_ in that directory
- The gitignore file has a few features:
  - Globs
  - Starting with `/` to avoid recursivity (patterns are recursive by default) (basically specifying the project root) - ending with `/` specifies a directory
  - Negate a pattern with `!`, e.g. if you ignore `*.a` but you want `lib.a` you'd use `!lib.a`
  - `**` to match nested directories, e.g. `a/**/z` matches `a/b/z`, `a/b/c/z` etc.
- `git diff` with no args shows files _changed but not staged_
- `git diff --staged` shows staged files (`--cached` is a synonym)
- `git commit -a` skips the need to `git add .`
- `git rm` is used to remove a file from the staging area, and will also remove it from the working directory
- `git rm --cached` (or `--staged`) removes a file from the staging area without removing it from the working directory
  - You can glob `git rm` commands but must make sure to include a `\` before a `*` to disable shell filename expansion
- Git doesn't explicitly track file movement but it will be smart and figure that out after the fact

### Viewing Commits
- `git log` is used to view the commit history in reverse chronological order
  - `-p` to show the difference (patch output) in each commit
  - `-n` for a number `n` to show the last `n` commits
  - `--pretty` is used to change the log output, e.g. `--pretty=oneline` prints single line logs with the hash and commit message. A custom format can also be created with `--pretty=format:` (see man page for more)
  - `--graph` shows the branch and merge history
  - Other flags include `--author` and `--grep` to filter for specific authors and for specific keywords in commit messages respectively
  - `-S` (pickaxe) takes a string and shows only commits that changed the number of occurrences of that string (e.g. adding or removing references to method calls)
  - `--no-merges` to hide merge commits
  - Finally, you can specify a path or file to limit to only commits that introduced changes to those files or files in that directory. 
    - Normally preceded with `--` to separate from other options. In fact it is the default last argument

### Undoing Things
- If you committed too early, you can amend the commit with new (staged) changes with `git commit --amend` (without changes staged it will just allow changing the commit message)
- To remove a file from the staging area, do `git reset HEAD <file>` 
- To unmodify a modified file, checkout the file with `git checkout -- <file>`, Git will replace your working directory version with the last staged or committed version