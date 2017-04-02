# devtools
Development tools for SlamData

## Instructions
How to get up and running with `merge`.

0. Before using merge you must first approve the pull request you have been assinged. 
You can do this under the `Files Changed` tab of Github's PR page. Then click the green `Review Changes` button on the left.

1. Git clone the slamdata/devtools repo using: 

```
→ git clone https://github.com/slamdata/devtools.git
```

2. The `merge` script depends on [json](http://trentm.com/json/). You can install it using `sudo npm install -g json`.
NPM depends on [Node.js](https://nodejs.org).

3. You also need to exchanged ssh keys with github. This requires two steps:
  * Generate ssh [keys](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
  * Exchage public key with [github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

4. Now from wihtin the `devtools` directory execute merge as follows:

```
→ bin/merge <github-repo-name> <PR-number>
```

replacing `<github-repo-name>` by the name of a repository, for exapmle `quasar-analytics/quasar`.
