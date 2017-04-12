# Contribution Guidelines

## Prerequisites

By contributing, you assert that:

* The contribution is your own original work.
* You have the right to assign the copyright for the work (it is not owned by your employer, or you have been given copyright assignment in writing).
* You [license] the contribution under the terms applied to the rest of the code.
* You agree to follow the [code of conduct] from the Cake project.

## Contributing process

This repository uses [GitFlow] with default configuration.
Development is happening on `develop` branch.

To contribute:

* Fork this repository.
* Create a feature branch from `develop`.
* Implement your changes.
* Push your feature branch.
* Create a pull request.

## Build

To build this package we are using Cake.

On Windows PowerShell run:

```powershell
./build
```

On OSX/Linux run:

```bash
./build.sh
```

## Release

See [Cake.Recipe documentation] how to create a new release of this addin.

[license]: LICENSE
[code of conduct]: https://github.com/cake-build/cake/blob/develop/CODEOFCONDUCT.md
[GitFlow]: (http://nvie.com/posts/a-successful-git-branching-model/)
[Cake.Recipe documentation]: https://cake-contrib.github.io/Cake.Recipe/docs/usage/creating-release