# Pro Git
In my day to day job I use Git very frequently, but I've never spent the time to properly get my head round the more complex parts, instead relying on muscle memory and StackOverflow for those occasions that I get stuck. 

I decided to read parts of Pro Git [git-scm.com/book/en/v2](https://git-scm.com/book/en/v2), going back to basics to learn a bit more about the internals and more advanced features of Git, and to solidify my understanding of this powerful but at times opaque tool.

## Notes
- Everything in Git is checksummed before it is stored, and referred to by that checksum (SHA-1)
- The staging area is used to mark modified files to go into the next commit (the three sections of a project are the working tree (where files can be _modified_), the staging area (where _staged_ files are) and the Git directory (where _committed_ files are))
  - The staging area is officially called the _index_
- Committing takes the contents of the index and saves it to a snapshot in the Git directory

### Config
- `git config --global --edit` to edit the global Git config file, `--system` for the system config (/etc/gitconfig), `--local` for the repository local file (which is the default config file Git will read from - stored in `.git/config` in a repository)
  - `git config --list --show-origin` to see the full list of config parameters and their origins
  - `git config --global core.editor vim` to set the editor for commit messages and stuff

___

- Files are _tracked_ by Git if they are in the last snapshot, or have been newly staged
  - Unmodified - exist in the last snapshot but not changed
  - Modified - existed in the last snapshot and have been changed
  - Staged - not existing in the last snapshot but have been added to the index
- When you commit all your staged files, they become unmodified in the context of the new, latest commit
- The `git status` command is used to see the state of files in your repository
- `git add <file>` to add files to the staging area (duh). Specifying a directory will add _all the files_ in that directory
- Up to Pg.30