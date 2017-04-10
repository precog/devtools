# devtools
Development tools for SlamData

## Merge Instructions
How to get up and running with `merge`.

1. Git clone the slamdata/devtools repo using: 

```
→ git clone https://github.com/slamdata/devtools.git
```

2. The `merge` script depends on [json](http://trentm.com/json/). You can install it using `sudo npm install -g json`.
NPM depends on [Node.js](https://nodejs.org).

3. You also need to exchange ssh keys with github. This requires two steps:
  * Generate ssh [keys](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
  * Exchage public key with [github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

4. In addition ensure the PR has a version label assigned to it.

5. Now run the `merge` script as follows:

```
→ merge -r "REPO-NAME PR-NUMBER"
```

replacing `REPO-NAME` by the name of a repository, for exapmle `quasar-analytics/quasar`.
