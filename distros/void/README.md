# Void Linux

## Update list of packages

After installing additional packages, it is advised to update the list of packages in
"packages.txt".\
It is also advised to only list manually installed packages, and to do so without their
version. This is to allow the package manager to remove redundant dependencies, and to
install the latest version when installing packages using the list in "packages.txt".

```bash
xpkg -m > packages.txt
```
