# SpellExport

This is a simple addon to export the wow spell tooltips for [wow-spell-tooltips-code](https://github.com/elvador/wow-spell-tooltips-code).

Here is how you use it:

1. Download and install this as a normal WoW addon
2. Login with any character (preferably a lvl 1 tauren warrior, to avoid stat changes)
3. Type `/spellexport request`. Wait.
4. Type `/spellexport retry`. Wait.
5. Type `/spellexport export`.
6. Reload your UI to update the SavedVariables
7. Execute this on your (linux) command line in the SavedVariables directory:
  ```bash
  grep "\"" SpellExport.lua | sed -e 's/^\s\"//g' | sed -e "s/\", -- \[.*$//g" | sed -e 's/\\"/""/g' | sed -e 's/~~/\"/g'  > SpellData.csv
  ```
8. Update the SpellData.csv in the wow-spell-tooltips-code directory
9. [Optional] Type `/spellexport clear` to keep your SavedVariables folder clean

