# SpellExport

This is a simple addon to export the wow spell tooltips for [wow-spell-tooltips](https://github.com/elvador/wow-spell-tooltips).

Here is how you use it:

1. Download and install this as a normal WoW addon
2. Login with any character (preferably a lvl 1 warrior, to avoid stat changes)
3. Type `/spellexport export`
4. Reload your UI to update the SavedVariables
5. Execute this on your (linux) command line in the SavedVariables directory:
  `grep "\"" SpellExport.lua | cut -d'"' -f2 > SpellData.csv`
6. Update the SpellData.csv in the wow-spell-tooltips/assets directory
7. [Optional] Type `/spellexport clear` to keep your SavedVariables folder clean

